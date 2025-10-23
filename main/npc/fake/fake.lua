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

local function distance(pos1, pos2)
    return math.sqrt(math.pow((pos1.x - pos2.x) / (settings.player_speed_x), 2) + math.pow((pos1.z - pos2.z) / (settings.player_speed_y), 2))
end

local function move_to(uid, model, position)
    local object = model.objects[uid]

    local dif = (position - object.position)
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

    object.execution_context.state = object.execution_context.state or 1
    
    if object.execution_context.state == 1 then
        local dif, delta = move_to(uid, model, pathfinder.get_path_target(object.position, model))
        
        if distance(object.position, model.td_end_point) * object.speed > 1 then
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
end

return M