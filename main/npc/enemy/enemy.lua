local npc_object = require "main.npc.npc_object"
local actions = require "main.sys.actions"
local pack = require "utils.pack"
local stand_object = require "main.objects.stand_object"
local sell_point_object = require "main.objects.sell_point_object"
local objects = require "main.objects.objects"
local npc_queue = require "main.npc.npc_queue"
local coin_object = require "main.objects.coin_object"
local pathfinder = require "main.collision_manager.pathfinder"
local settings = require "main.settings"

local M = {}

local function distance2(pos1, pos2)
    return math.pow((pos1.x - pos2.x) / (settings.player_speed_x), 2) + math.pow((pos1.z - pos2.z) / (settings.player_speed_y), 2)
end

local function move_to(uid, model, position)
    local object = model.objects[uid]
    local a = (uid * 2377) % 720 / 2
    local offset = vmath.rotate(vmath.quat_rotation_y(a), vmath.vector3(1, 0, 0))
    offset.x = offset.x * settings.player_speed_x / 2
    offset.z = offset.z * settings.player_speed_y / 2

    local dif = (position + offset - object.position)
    -- instead dividing we cross-multiply
    dif.x = dif.x * settings.player_speed_y * object.speed
    dif.z = dif.z * settings.player_speed_x * object.speed
    local direction = vmath.normalize(dif)
    direction.x, direction.y, direction.z = direction.x or 0, direction.y or 0, direction.z or 0
    direction.x = direction.x * settings.player_speed_x * object.speed
    direction.z = direction.z * settings.player_speed_y * object.speed
    local new_position = object.position + direction
    local delta = new_position - object.position
    delta.y = 0
    return dif, delta
end

local PROCESS_COINS_LENGTH = 15

local function create_coins(uid, model, n)
    local object = model.objects[uid]
    object.execution_context.coins_pos = {}
    object.execution_context.coins_uid = {}
    local rand = uid % 2551
    local v = vmath.vector3(1, 0, 0)
    for i = 1, n do
        rand = rand * 2377 % 2551
        local pos = vmath.rotate(vmath.quat_rotation_y(rand % 360), v)
        pos.x = pos.x * settings.player_speed_x * object.speed * 12
        pos.z = pos.z * settings.player_speed_y * object.speed * 12
        table.insert(object.execution_context.coins_pos, pos)
        local coin_uid = coin_object.spawn(model, object.position)
        local coin_obj = model.objects[coin_uid]
        coin_obj.interactable = false
        table.insert(object.execution_context.coins_uid, coin_uid)
    end
end

local function process_coins(uid, model, n)
    local object = model.objects[uid]
    
    local p = object.execution_context.timer / PROCESS_COINS_LENGTH
    local y = math.abs(math.sin(p * math.pi * 3)) * (1 - p * p) * 128
    local y_offset = vmath.vector3(0, y, 0)

    local q = 1 - p
    local c = (1 - q * q)
    for i, coin_uid in ipairs(object.execution_context.coins_uid) do
        local coin_obj = model.objects[coin_uid]
        coin_obj.position = object.position + object.execution_context.coins_pos[i] * c + y_offset
    end
end

local function process_coins_end(uid, model, n)
    local object = model.objects[uid]
    
    for i, coin_uid in ipairs(object.execution_context.coins_uid) do
        local coin_obj = model.objects[coin_uid]
        coin_obj.position = object.position + object.execution_context.coins_pos[i]
        coin_obj.interactable = true
    end
end

function M.simulate(uid, model)
    local object = model.objects[uid]

    object.execution_context.state = object.execution_context.state or 1
    
    if object.execution_context.state == 1 then
        if object.health <= 0 then
            object.execution_context.state = 2
            return
        end
        local dif, delta = move_to(uid, model, pathfinder.get_path_target(object.position, model))
        
        if distance2(object.position, model.td_end_point) * object.speed > 1 then
            npc_object.apply_action(model, actions.move_object(uid, delta))
        else
            model.health = model.health - 1
            if model.health <= 0 then
                model.lose = true
                model.game_stop = true
            end
            npc_object.apply_action(model, actions.destroy_object(uid))
        end
    elseif object.execution_context.state == 2 then
        if object.reward then
            create_coins(uid, model, object.reward)
        end
        object.interactable = false
        object.execution_context.timer = 0
        object.execution_context.state = 3
    elseif object.execution_context.state == 3 then

        object.execution_context.timer = object.execution_context.timer + 1

        if object.execution_context.timer > PROCESS_COINS_LENGTH then
            if object.reward then
                process_coins_end(uid, model, object.reward)
            end
            object.execution_context.state = 4
            return
        end
        
        if object.reward then
            process_coins(uid, model, object.reward)
        end
    elseif object.execution_context.state == 4 then
        npc_object.apply_action(model, actions.destroy_object(uid))
    end
end

function M.spawn(uid, model)
    local object = model.objects[uid]
    object.execution_context = object.execution_context or {}
    object.execution_context.state = 1
end

return M