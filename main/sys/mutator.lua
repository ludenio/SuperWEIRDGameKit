local data = require "main.data"
local settings = require "main.settings"
local actions = require "main.sys.actions"
local pack = require "utils.pack"
local md = require "main.sys.model"
local collision_manager = require "main.collision_manager.collision_manager"
local objects = require "main.objects.objects"


local item_slot_object = require "main.objects.item_slot_object"
local stand_object = require "main.objects.stand_object"
local shop_object = require "main.objects.shop_object"
local player_object = require "main.objects.player_object"
local item_object = require "main.objects.item_object"
local sell_point_object = require "main.objects.sell_point_object"
local recipe_object = require "main.objects.recipe_object"
local workbench_object = require "main.objects.workbench_object"
local button_object = require "main.objects.button_object"
local source_object = require "main.objects.source_object"
local recipe_stand_object = require "main.objects.recipe_stand_object"
local npc_object = require "main.npc.npc_object"
local reserved_stand_object = require "main.objects.reserved_stand_object"
local foundation_object = require "main.objects.foundation_object"
local trashcan_object = require "main.objects.trashcan_object"
local guard_object = require "main.objects.guard_object"
local coin_object = require "main.objects.coin_object"
local next_wave_zone = require "main.objects.next_wave_zone"
local sprite_object = require "main.objects.sprite_object"
local diggable_tile_object = require "main.objects.diggable_tile_object"
local point_object = require "main.objects.point_object"

local function router(type)
	if type == objects.TYPES.PLAYER then
		return player_object
	elseif type == objects.TYPES.NPC then
		return npc_object
	elseif type == objects.TYPES.ITEM then
		return item_object
	elseif type == objects.TYPES.STAND then
		return stand_object
	elseif type == objects.TYPES.SHOP then
		return shop_object
	elseif type == objects.TYPES.SELL_POINT then
		return sell_point_object
	elseif type == objects.TYPES.ITEM_SLOT then
		return item_slot_object
	elseif type == objects.TYPES.RECIPE then
		return recipe_object
	elseif type == objects.TYPES.WORKBENCH then
		return workbench_object
	elseif type == objects.TYPES.BUTTON then
		return button_object
	elseif type == objects.TYPES.SOURCE then
		return source_object
	elseif type == objects.TYPES.RECIPE_STAND then
		return recipe_stand_object
	elseif type == objects.TYPES.RESERVED_STAND then
		return reserved_stand_object
	elseif type == objects.TYPES.FOUNDATION then
		return foundation_object
	elseif type == objects.TYPES.TRASHCAN then
		return trashcan_object
	elseif type == objects.TYPES.GUARD then
		return guard_object
	elseif type == objects.TYPES.COIN then
		return coin_object
	elseif type == objects.TYPES.ZONE then
		return next_wave_zone
	elseif type == objects.TYPES.SPRITE then
		return sprite_object
	elseif type == objects.TYPES.DIGGABLE_TILE then
		return diggable_tile_object
	elseif type == objects.TYPES.POINT then
		return point_object
	end
end


local M = {}

-- local objects_router_factory = require "main.objects.objects_router"
-- local objects_router = objects_router_factory.new_router()
local function sync_money_in(model, location_id)
	local location = model.locations[location_id]

	location.money = model.money
end

local function sync_money_out(model, location_id)
	local location = model.locations[location_id]
	model.money = location.money
end

function M.apply_action(model, action)
	sync_money_in(model, action.location_id)
	local location = model.locations[action.location_id]

	if action.type == actions.ACTION_TYPE.SET_MODEL_PROPERTY then
		for k,v in pairs(action.props) do
			location[k] = v
		end
		return
	elseif action.type == actions.ACTION_TYPE.EXTRACT_ITEM_FROM_LOCATION then
		local from = action.from_location_id
		for uid, object in pairs(location.objects) do --looking up for portal in new location
			if object.to_location == from then
				action.uid = uid
				break
			end
		end
	elseif action.type == actions.ACTION_TYPE.SYS_SHOW_FOUNDATIONS then
		for uid, object in pairs(location.objects) do --looking up for portal in new location
			if object.type == objects.TYPES.FOUNDATION then
				foundation_object.build(uid, location)
			end
		end
	elseif action.type == actions.ACTION_TYPE.SPAWN_OBJECT and action.reletive_offset then
		pprint("action.reletive_offset: ", action.reletive_offset)
		for k,object in pairs(location.objects) do
			if object.type == objects.TYPES.BUTTON and object.to_location == action.reletive_offset.from_location_id then
				action.position = object.position + action.reletive_offset.offset
				print("action.offset: ", action.offset)
				break
			end
		end
	end

	
	local actor_type = action.object_type or action.uid and location.objects[action.uid] and location.objects[action.uid].type
		or action.player_id and objects.TYPES.PLAYER


	local handle_module = router(actor_type)


	if actor_type == objects.TYPES.PLAYER and action.player_id then --update world for every player
		model.ptw[action.player_id] = action.location_id
	end
	if handle_module then
		--print("location: ", location)
		handle_module.apply_action(location, action)
	end
	sync_money_out(model, action.location_id)
end

function M.apply_actions(model, actions_instance, target_location_id)
	if actions.is_empty(actions_instance) then
		return
	end
	for i = actions.first(actions_instance), actions.last(actions_instance) do
		local action = actions.get(actions_instance, i)
		if not target_location_id or action.location_id == target_location_id then
			M.apply_action(model, action)
		end
	end
end

local function tick(model, location_id)
	sync_money_in(model, location_id)
	local location = model.locations[location_id]

	model.locations[location_id].tick = model.locations[location_id].tick + 1

	
	for uid, _ in pairs(location.objects) do
		local action = actions.tick(uid)
		action.location_id = location_id
		M.apply_action(model, action)
	end
	sync_money_out(model, location_id)
end

function M.mutate(model, target_location_id)
	if target_location_id then
		tick(model, target_location_id)
	else
		for location_id, _ in pairs(model.locations) do
			tick(model, location_id)
		end
	end

	-- for uid, _ in pairs(model.objects) do
	-- 	M.apply_action(model, {
	-- 		type = actions.ACTION_TYPE.TICK,
	-- 		uid = uid
	-- 	})
	-- end
end

function M.mutate_to_tick(model, tick)
	while model.tick < tick do
		M.mutate(model)
	end
end

return M
