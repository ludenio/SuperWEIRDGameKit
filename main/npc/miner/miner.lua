local npc_object = require "main.npc.npc_object"
local actions = require "main.sys.actions"
local pack = require "utils.pack"
local stand_object = require "main.objects.stand_object"
local sell_point_object = require "main.objects.sell_point_object"
local objects = require "main.objects.objects"
local npc_queue = require "main.npc.npc_queue"
local settings = require "main.settings"
local pathfinder = require "main.collision_manager.pathfinder"
local data = require "main.data"

local M = {}

local function distance2(pos1, pos2)
    return math.sqrt(math.pow((pos1.x - pos2.x) / (settings.player_speed_x), 2) + math.pow((pos1.z - pos2.z) / (settings.player_speed_y), 2))
end

local function find_resource(model, uid, element_name)
    local self = model.objects[uid]
    local result_uid = nil
    local result_pos = nil
    local result_dist = nil
    for k,v in pairs(model.objects) do
        if v.type == objects.TYPES.ITEM and v.interactable and v.owner_uid == nil and v.name == element_name and not v.npc_dropped then
            if result_dist == nil or result_dist > distance2(v.position, self.position) then
                result_uid = k
                result_pos = v.position
                result_dist = distance2(v.position, self.position)
            end
        elseif v.type == objects.TYPES.DIGGABLE_TILE and v.drop_name == element_name and pathfinder.get_path_target(self.position, model, v.position) then
            if result_dist == nil or result_dist > distance2(v.position, self.position) then
                result_uid = k
                result_pos = v.position
                result_dist = distance2(v.position, self.position)
            end
        end
    end
    return result_uid, result_pos
end

local function find_point(model, uid, type)
    local self = model.objects[uid]
    local result_uid = nil
    local result_pos = nil
    local result_dist = nil
    for k,v in pairs(model.objects) do
        if v.type == type then
            if result_dist == nil or result_dist > distance2(v.position, self.position) then
                result_uid = k
                result_pos = v.position
                result_dist = distance2(v.position, self.position)
            end
        end
    end
    return result_uid, result_pos
end

local function move_to(uid, model, position)
    local object = model.objects[uid]
    local a = (uid * 2377) % 720 / 2
    local offset = vmath.rotate(vmath.quat_rotation_y(a), vmath.vector3(1, 0, 0))
    local speed = object.speed or 1
    offset.x = offset.x * settings.player_speed_x / 2
    offset.z = offset.z * settings.player_speed_y / 2

    local dif = (position + offset - object.position)
    -- instead dividing we cross-multiply
    dif.x = dif.x * settings.player_speed_y * speed
    dif.z = dif.z * settings.player_speed_x * speed
    local direction = vmath.normalize(dif)
    direction.x, direction.y, direction.z = direction.x or 0, direction.y or 0, direction.z or 0
    direction.x = direction.x * settings.player_speed_x * speed
    direction.z = direction.z * settings.player_speed_y * speed
    local new_position = object.position + direction
    local delta = new_position - object.position
    delta.y = 0
    return dif, delta
end

function M.simulate(uid, model)
    local object = model.objects[uid]
    object.execution_context.state = object.execution_context.state or 1
    if object.execution_context.state == 0 then
        if object.open_miner_settings_menu ~= true then
            -- object.interactable = true
            object.interact_requested_from = nil
            object.execution_context.state = 1
            return
        end
    elseif object.steps[object.execution_context.state] then
        if object.interact_requested_from then
            -- object.interactable = false
            model.block_interact[object.interact_requested_from] = true
            object.execution_context.state = 0
            object.open_miner_settings_menu = true
            return
        end
        local step = object.steps[object.execution_context.state]
        if step.value == data.NPC_PROG_OPTIONS.MINE then
            if object.item_uid then
                object.execution_context.state = (object.execution_context.state) % #object.steps + 1
                return
            end
            local result_uid, result_pos = find_resource(model, uid, step.param)
            if result_uid and result_pos then
                npc_object.apply_action(model, actions.npc_pick_item(uid, step.param))
                if object.item_uid then
                    object.execution_context.state = 2
                else
                    local step_target = pathfinder.get_path_target(object.position, model, result_pos)
                    if step_target then
                        local dif, delta = move_to(uid, model, step_target)
                        npc_object.apply_action(model, actions.move_object(uid, delta))
                    end
                end
            end
        elseif step.value == data.NPC_PROG_OPTIONS.TAKE_FROM then
            if object.item_uid then
                object.execution_context.state = (object.execution_context.state + 1) % #object.steps
                return
            end
            local result_uid, result_pos = find_point(model, uid, step.param)

            if result_uid and result_pos then
                if distance2(object.position, result_pos) * object.speed > 1 then
                    local step_target = pathfinder.get_path_target(object.position, model, result_pos)
                    local dif, delta = move_to(uid, model, step_target)
                    npc_object.apply_action(model, actions.move_object(uid, delta))
                else
                    npc_object.apply_action(model, actions.npc_interact(uid))
                    object.execution_context.state = 1
                end
            end
        elseif step.value == data.NPC_PROG_OPTIONS.PUT_IN then
            if not object.item_uid then
                object.execution_context.state = (object.execution_context.state + 1) % #object.steps
                return
            end
            local result_uid, result_pos = find_point(model, uid, step.param)

            if result_uid and result_pos then
                if distance2(object.position, result_pos) * object.speed > 1 then
                    local step_target = pathfinder.get_path_target(object.position, model, result_pos)
                    local dif, delta = move_to(uid, model, step_target)
                    npc_object.apply_action(model, actions.move_object(uid, delta))
                else
                    npc_object.apply_action(model, actions.npc_interact(uid))
                    object.execution_context.state = 1
                end
            end
        else
            object.execution_context.state = (object.execution_context.state + 1) % #object.steps
            return
        end
    end
end

function M.spawn(uid, model)
    local object = model.objects[uid]
    object.execution_context = object.execution_context or {}
    object.execution_context.state = 1
end

return M
