local npc_object = require "main.npc.npc_object"
local actions = require "main.sys.actions"
local pack = require "utils.pack"
local stand_object = require "main.objects.stand_object"
local sell_point_object = require "main.objects.sell_point_object"
local objects = require "main.objects.objects"
local npc_queue = require "main.npc.npc_queue"
local pathfinder = require "main.collision_manager.pathfinder"
local settings = require "main.settings"

local M = {}

local function distance2(pos1, pos2)
    return math.sqrt(math.pow((pos1.x - pos2.x) / (settings.player_speed_x), 2) + math.pow((pos1.z - pos2.z) / (settings.player_speed_y), 2))
end

local function find_stand_with(model, item_name, uid)
    local filled_stands = {}
    local wrong_stands = {}
    for k,v in pairs(model.objects) do
        if v.type == objects.TYPES.STAND or v.type == objects.TYPES.RESERVED_STAND then
            local item_uid = stand_object.get_item(k, model)
            if item_uid and model.objects[item_uid].name == item_name then
                table.insert(filled_stands, k)
            elseif v.type == objects.TYPES.RESERVED_STAND and v.element_name == item_name then
                table.insert(wrong_stands, k)
            end
        end
    end
    if #filled_stands > 0 then
        return filled_stands[uid % #filled_stands + 1], true
    end
    if #wrong_stands > 0 then
        return wrong_stands[uid % #wrong_stands + 1], false
    end
    return nil, true
end

local left_sided_queue = {
    stone_shield = true,
    iron_shield = true,
    stone_sword = true,
    iron_sword = true,
}

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

function M.simulate(uid, model)
    local object = model.objects[uid]

    object.execution_context.state = object.execution_context.state or 2

    if object.health <= 0 then
        npc_queue.remove_ticket(uid)
        object.execution_context.state = 4
    end
    
    if object.interact_requested_from then
        npc_object.player_hit(uid, model)
        object.interact_requested_from = nil
        -- return
    end
    
    if object.execution_context.state == 1 then
        object.execution_context.timer = object.execution_context.timer + 1
        if object.execution_context.timer > -100 then
            object.execution_context.state = 2
            object.execution_context.timer = 0
        end
    elseif object.execution_context.state == 2 then
        object.execution_context.icon_name = "evil_face"
        local target_stand, is_full_stand = find_stand_with(model, object.execution_context.wanted_item, uid)
        local target_position = model.objects[target_stand].position

        local place_in_queue = npc_queue.get_ticket(target_stand, uid)
        if place_in_queue ~= 1 then
            is_full_stand = false
        end
        local offset = vmath.vector3(0,0,-128) * (place_in_queue - 1) + vmath.vector3(-16, 0, -80)

        if left_sided_queue[object.execution_context.wanted_item] then
            offset = vmath.vector3(-128,0, 0) * (place_in_queue - 1) + vmath.vector3(-80, 0, -16)
        end
        
        if target_stand then
            if distance2(object.position, target_position + offset) * object.speed > 1 then
                -- WITH PATHFINDING
                -- local step_target = pathfinder.get_path_target(object.position, model, target_position + offset)
                -- local dif, delta = move_to(uid, model, step_target)

                -- WITHOUT
                local dif, delta = move_to(uid, model, target_position + offset)
                
                npc_object.apply_action(model, actions.move_object(uid, delta))
            elseif is_full_stand then
                npc_object.apply_action(model, actions.npc_interact(uid))
                if object.item_uid then
                    npc_queue.remove_ticket(uid)
                    object.execution_context.state = 3
                    object.execution_context.wait_point_index = 1
                    object.execution_context.timer = 0
                end
            end
        end
    elseif object.execution_context.state == 3 then
        object.execution_context.icon_name = "smile_face"
        if distance2(object.position, go.get_position("destroy_point")) * object.speed > 1 then
            -- WITH PATHFINDING
            -- local step_target = pathfinder.get_path_target(object.position, model, go.get_position("destroy_point"))
            -- local dif, delta = move_to(uid, model, step_target)

            -- WITHOUT
            local dif, delta = move_to(uid, model, go.get_position("destroy_point"))
            
            npc_object.apply_action(model, actions.move_object(uid, delta))
        else
            npc_object.apply_action(model, actions.destroy_object(uid))
        end
    elseif object.execution_context.state == 4 then
        object.execution_context.icon_name = "guilty_face"
        if object.item_uid then
            npc_object.try_remove_item(uid, model)
        end
        if distance2(object.position, go.get_position("destroy_point")) * object.speed > 1 then
            -- WITH PATHFINDING
            -- local step_target = pathfinder.get_path_target(object.position, model, go.get_position("destroy_point"))
            -- local dif, delta = move_to(uid, model, step_target)

            -- WITHOUT
            local dif, delta = move_to(uid, model, go.get_position("destroy_point"))
            
            npc_object.apply_action(model, actions.move_object(uid, delta))
        else
            npc_object.apply_action(model, actions.destroy_object(uid))
        end
    end
end

function M.spawn(uid, model)
    local object = model.objects[uid]
    object.execution_context = object.execution_context or {}
    object.execution_context.state = 1
    object.vanted_sprite = "element_stone"
end

return M