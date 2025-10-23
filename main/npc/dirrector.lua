local M = {}
local objects = require("main.objects.objects")
local source_object = require("main.objects.source_object")
local recipe_stand_object = require("main.objects.recipe_stand_object")
local reserved_stand_object = require("main.objects.reserved_stand_object")
local foundation_object = require("main.objects.foundation_object")
local guard_object = require "main.objects.guard_object"


local npc_processor = require("main.npc.npc_processor")
local pack = require "utils.pack"
local data = require("main.data")

local function router(type)
    if type == objects.TYPES.RESERVED_STAND then
        return reserved_stand_object
    end
end
--"stone",
--"iron",
--"wood",
--"iron_sword",
--"stone_sword",
--"stone_shield",
--"iron_shield"
local config = {
    
    count_per_source = 0.8,
    sources_multiplier = {
        stone = 4,
        iron = 4,
        wood = 4,
        iron_sword = 1,
        stone_sword = 1,
        stone_shield = 1,
        iron_shield = 1,
    },
    min_spawn_dellay = 23,
    max_with_same_item = 4,

    thief_spawn_recharge = 500,
    thief_spawn_per_source = 0.3
}

local sources = {}

local function calc_souces(model)
    sources = {}
    local counted = {}
    for k,v in pairs(model.objects) do
        local handle = router(v.type)
        if handle and handle.get_production_type and handle.get_production_type(k, model) then
            if not counted[handle.get_production_type(k, model)] then
                for i = 1, config.sources_multiplier[handle.get_production_type(k, model)] do
                    table.insert(sources, handle.get_production_type(k, model))
                end
                counted[handle.get_production_type(k, model)] = true
            end
        end
    end
end

-- local npcs = {}
-- local thiefs = {}
-- local enemies = {}
-- local fakes = {}
local cache = {
    {
        npcs = {},
        enemies = {},
        fakes = {},
        thiefs = {},
    },
}

local last_thief_spawn_time = 0
local last_enemy_spawn_time = 0

local function check_npcs(model)
    local cur_cache = cache[model.id]
    for k,v in pairs(cur_cache.npcs) do
        if not model.objects[v] then
            table.remove(cur_cache.npcs, k)
        end
    end
end

local function check_enemies(model)
    local cur_cache = cache[model.id]
    for k,v in pairs(cur_cache.enemies) do
        if not model.objects[v] then
            table.remove(cur_cache.enemies, k)
        end
    end
end

local function check_fakes(model)
    local cur_cache = cache[model.id]
    for k,v in pairs(cur_cache.fakes) do
        if not model.objects[v] then
            table.remove(cur_cache.fakes, k)
        end
    end
end

local function check_thiefs(model, timer)
    local cur_cache = cache[model.id]
        for k,v in pairs(cur_cache.thiefs) do
        if not model.objects[v] then
            last_thief_spawn_time = timer
            table.remove(cur_cache.thiefs, k)
        end
    end
end

local function get_target_npc_count()
    return #sources * config.count_per_source
end

local function get_target_enemy_count()
    return 1
end

local function get_target_thief_count()
    return math.floor((#sources * config.thief_spawn_per_source))
end


local function get_wanted_item(model, timer)
    local counters = {}
    local cur_cache = cache[model.id]
    for k,v in pairs(cur_cache.npcs) do
        if model.objects[v] and model.objects[v].execution_context.wanted_item then
            local item = model.objects[v].execution_context.wanted_item
            counters[item] = (counters[item] or 0) + 1
        end
    end

    local item_name = nil
    for i = 0, 100 do
        item_name = sources[((timer + i) % #sources) + 1]
        if item_name and (not counters[item_name] or counters[item_name] < config.max_with_same_item) then
            return item_name
        end
    end


    return sources[(timer % #sources) + 1]
end

local function get_target_position(timer)
    return go.get_position("spawn_point") + vmath.vector3(timer % 70, 0, timer % 100)
end

local function get_thief_target_position(timer)
    return go.get_position("spawn_point") + vmath.vector3(timer % 500, 0, timer % 100)
end

local function get_thief_spawn_recharge()
    local count = get_target_thief_count()
    return config.thief_spawn_recharge / math.pow((count > 0 and count or 1), 2) 
end

local timer = 0
local last_spawn_timer = 0
local timer_module = 10007

local WAVE_STATUS = {
    PREPARE = 0,
    SPAWNING = 1,
    POST_SPAWN = 2,
    ENDED = 3,
}

local CYCLE_WAVES = false

local function setup_next_wave(model)
    if not model.wave then
        model.wave = 0
    end
    local wave_n = model.wave + 1

    if wave_n > #data.waves then
        if CYCLE_WAVES  then
            wave_n = 1
        else
            model.win = true
            model.game_stop = true
            model.wave = nil
            model.wave_status = nil
            return
        end
    end

    model.wave = wave_n
    model.wave_tick = -60
    model.wave_status = WAVE_STATUS.PREPARE
end

local function check_if_available_actions(model)
    for uid, object in pairs(model.objects) do
        if object.type == objects.TYPES.FOUNDATION and object.visible and object.cost <= model.money then
            return true
        end
        if object.type == objects.TYPES.COIN then
            return true
        end
        if object.type == objects.TYPES.GUARD and guard_object.is_empty(uid, model) then
            return true
        end

        if object.type == objects.TYPES.SOURCE and source_object.is_empty(uid, model) then
            return true
        end
    end
    return false
end

local function spawn_enemy(model, name)
    local cur_cache = cache[model.id]
    local enemy_data = data.enemies[name]
    if enemy_data == nil then
        return
    end
    local uid = npc_processor.spawn(model, vmath.vector3(model.td_start_point), "ENEMY", {skin = enemy_data.skin, interactable = true, max_health = enemy_data.health, speed = enemy_data.speed , reward = enemy_data.reward})
    table.insert(cur_cache.enemies, uid)

    last_enemy_spawn_time = timer
end

local function spawn_fake(model)
    local cur_cache = cache[model.id]
    local uid = npc_processor.spawn(model, vmath.vector3(model.td_start_point), "FAKE", {fake = true, speed = 0.5})
    table.insert(cur_cache.fakes, uid)

    last_enemy_spawn_time = timer
end

local function handle_wave(model)
    if model.next_wave_requested then
        model.next_wave_requested = nil
        setup_next_wave(model)
    end
    if model.wave_status == WAVE_STATUS.ENDED and model.wave == #data.waves then
        setup_next_wave(model)
        return
    end
    if check_if_available_actions(model) == false and (not model.wave or model.wave_status == WAVE_STATUS.ENDED) then
        setup_next_wave(model)
    end
    
    if model.wave and model.wave > 2 and (not last_enemy_spawn_time or timer > last_enemy_spawn_time + 5) then
        spawn_fake(model)
    end

    if not model.wave or model.wave > #data.waves or model.wave_status == WAVE_STATUS.ENDED then
        -- if model.wave and model.wave > -1 and (not last_enemy_spawn_time or timer > last_enemy_spawn_time + 5) then
        return
    end

    local wave_info = data.waves[model.wave]

    if model.wave_status == WAVE_STATUS.PREPARE then
        model.wave_tick = model.wave_tick + 1
        if model.wave_tick >= 0 then
            model.wave_status = WAVE_STATUS.SPAWNING
        end
    end
    if model.wave_status == WAVE_STATUS.SPAWNING then
        model.wave_tick = model.wave_tick + 1
        if model.wave_tick > wave_info.length then
            model.wave_status = WAVE_STATUS.POST_SPAWN
        elseif wave_info.enemies[model.wave_tick] then
            spawn_enemy(model, wave_info.enemies[model.wave_tick])
        end
    end
    if model.wave_status == WAVE_STATUS.POST_SPAWN then
        check_enemies(model)
        if #enemies == 0 then
            model.wave_status = WAVE_STATUS.ENDED
        end
    end
    
end

local function _tick(location)
    cache[location.id] = cache[location.id] or {
        npcs = {},
        enemies = {},
        fakes = {},
        thiefs = {},
    }
    local cur_cache = cache[location.id]

    timer = (timer + 1) % timer_module
    
    calc_souces(location)
    check_npcs(location)
    check_enemies(location)
    check_fakes(location)
    check_thiefs(location, timer)

    local target_npc_count = get_target_npc_count()
    local target_enemy_count = get_target_enemy_count()

--     if #cur_cache.thiefs < get_target_thief_count() and math.abs(timer - last_thief_spawn_time) >= get_thief_spawn_recharge() then
--         local target_position = get_thief_target_position(timer)
--         local wanted_item = get_wanted_item(location, timer)
-- 
--         local uid = npc_processor.spawn(location, target_position, "THIEF", {wanted_item = wanted_item, drop_item = "stone", skin = 10, interactable = true, max_health = 1})
--         table.insert(cur_cache.thiefs, uid)
-- 
--         last_thief_spawn_time = timer
--     end

    -- if #enemies < target_enemy_count and math.abs(timer - last_enemy_spawn_time) >= config.min_spawn_dellay then
    --     local uid = npc_processor.spawn(model, vmath.vector3(model.td_start_point), "ENEMY", {skin = 10, interactable = true})
    --     table.insert(enemies, uid)
    --     
    --     last_enemy_spawn_time = timer
    -- end
    -- handle_wave(model)
    
    if #cur_cache.npcs < target_npc_count and math.abs(timer - last_spawn_timer) >= config.min_spawn_dellay then
        local wanted_item = get_wanted_item(location, timer)
        local target_position = get_target_position(timer)
        local uid = npc_processor.spawn(location, target_position, "BUYER", {wanted_item = wanted_item, skin = 10})
        table.insert(cur_cache.npcs, uid)

        last_spawn_timer = timer
    end
end


function M.tick(model) 
    local working_locations = {}
    working_locations[1] = true
    for location_id, location in pairs(model.locations) do
        if working_locations[location_id] then
            _tick(location)
        end
    end
end

return M