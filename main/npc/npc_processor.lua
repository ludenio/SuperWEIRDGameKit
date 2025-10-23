local npc_object = require "main.npc.npc_object"
local buyer_script = require "main.npc.buyer.buyer"
local thief_script = require "main.npc.thief.thief"
local enemy_script = require "main.npc.enemy.enemy"
local fake_script = require "main.npc.fake.fake"
local miner_script= require "main.npc.miner.miner"
local data= require "main.data"

local measure = require "utils.measure"

local M = {}

M.NPC_TYPES = { --TODO: move to config
    BUYER = {factory = "/root#buyer_factory", script = buyer_script},
    THIEF = {factory = "/root#buyer_factory", script = thief_script},
    ENEMY = {factory = "/root#buyer_factory", script = enemy_script},
    FAKE = {factory = "/root#fake_factory", script = fake_script},
    MINER = {factory = "/root#buyer_factory", script = miner_script},
}


function M.tick(model)
    for location_id, location in pairs(model.locations) do
        for uid, object in pairs(location.objects) do
            if object.npc_type then --TODO: save a list of spawned NPCs
                local npc_type = M.NPC_TYPES[object.npc_type]
                measure.profile_function("npc_type.script.simulate ".. npc_type.factory, npc_type.script.simulate, uid, location)
            end
        end
    end
end

function M.spawn(model, position, npc_type, npc_params)
    if not M.NPC_TYPES[npc_type] then
        return
    end
    local uid = npc_object.spawn(model, position, npc_type, M.NPC_TYPES[npc_type].factory, npc_params.skin, {
        interactable = npc_params.interactable,
        drop_item = npc_params.drop_item,
        max_health  = npc_params.max_health,
        speed  = npc_params.speed,
        reward  = npc_params.reward,
        fake  = npc_params.fake,
        steps = {
            {value = data.NPC_PROG_OPTIONS.MINE, param = npc_params.target_1_element_name},
            {value = data.NPC_PROG_OPTIONS.PUT_IN, param = npc_params.target_2_type},
        },
    })

    model.objects[uid].execution_context.wanted_item = npc_params.wanted_item
    model.objects[uid].execution_context.timer = 0


    M.NPC_TYPES[npc_type].script.spawn(uid, model)

    return uid
end

return M