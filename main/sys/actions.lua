local pack = require "utils.pack"
local list = require "utils.list"
local objects = require "main.objects.objects"
local hashes = require "utils.hashes"

local M = {}

M.expire_tick = 0

M.ACTION_TYPE = {
	SPAWN_OBJECT = 1,
	MOVE_OBJECT = 2,
	INTERACT = 3,
	TICK = 4,
	BUTTON_PRESS = 5,
	DESTROY_OBJECT = 6,
	NPC_INTERACT = 7,
	SET_MODEL_PROPERTY = 8,
	NPC_PICK_ITEM = 9,
	NPC_DROP_ITEM = 10,
	UPDATE_MINER_SETTINGS = 11,
	EXTRACT_ITEM_FROM_LOCATION = 12,
	SYS_SHOW_FOUNDATIONS = 13,
}

function M.new(pid)
	return {
		actions = list.new(),
		pid = pid,
	}
end

function M.size(action_handler)
	return list.size(action_handler.actions)
end

function M.last(action_handler)
	return list.get_last(action_handler.actions)
end

function M.first(action_handler)
	return list.get_first(action_handler.actions)
end

function M.add_action(action_handler, action, location_id)
	assert(location_id or action.location_id, "location_id is not set")
	action.location_id = location_id or action.location_id
	list.pushright(action_handler.actions, action)
end

function M.send_action(action, location_id, is_action_local)
	msg.post(".", hashes.ACTIONS_MSG, {action = action, location_id = location_id, is_action_local = is_action_local})
end

function M.on_message(message_id, message, sender)
	return message.action, message.location_id, message.model
end

function M.is_empty(action_handler)
	return list.get_first(action_handler.actions) > list.get_last(action_handler.actions)
end

function M.get(action_handler, i)
	return action_handler.actions.values[i]
end

function M.set_expire(action_handler, action_id)
	while list.get_first(action_handler.actions) <= action_id do
		list.popleft(action_handler.actions)
	end
end

function M.merge(action_handler, other_handler)
	if M.is_empty(other_handler) then
		return
	end
	while not M.is_empty(other_handler) do
		local v = list.popleft(other_handler.actions)
		M.add_action(action_handler, v)
	end
end

function M.spawn_player(position, player_id, reletive_offset)

	--if reletive_offset is set, we will spawn player in providet offset from portal to provided location
	if not (reletive_offset and reletive_offset.offset and reletive_offset.from_location_id) then
		reletive_offset = nil
	end
	pprint("reletive_offset: ", reletive_offset)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		player_id = player_id,
		object_type = objects.TYPES.PLAYER,
		reletive_offset = reletive_offset,
	}
	return action
end

function M.delete_player(uid, pid)
	local action = {
		type = M.ACTION_TYPE.DESTROY_OBJECT,
		pid = pid,
		uid = uid,
		object_type = objects.TYPES.PLAYER,
	}
	return action
end

function M.move_object(uid, delta)
	local action = {
		type = M.ACTION_TYPE.MOVE_OBJECT,
		delta = delta,
		uid = uid
	}
	return action
end

function M.spawn_object(position, element_name)
	if element_name == nil then
		element_name = "object"
	end
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.ITEM,
		element_name = element_name
	}
	return action
end

function M.spawn_recipe(position, recipe_name)
	if recipe_name == nil then
		print("no recipe name")
		return nil
	end
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.RECIPE,
		element_name = recipe_name
	}
	return action
end

function M.npc_interact(player_id)
	local action = {
		type = M.ACTION_TYPE.NPC_INTERACT,
		player_id = player_id,
	}
	return action
end

function M.interact(player_id)
	local action = {
		type = M.ACTION_TYPE.INTERACT,
		player_id = player_id,
	}
	return action
end

function M.spawn_stand(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.STAND,
	}
	return action
end

function M.spawn_shop(position, item_create_action)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.SHOP,
		item_create_action = item_create_action,
	}
	return action
end

function M.spawn_factory(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.FACTORY,
	}
	return action
end

function M.spawn_sell_point(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.SELL_POINT,
	}
	return action
end

function M.spawn_workbench(position, recipe_name)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.WORKBENCH,
		recipe_name = recipe_name,
	}
	return action
end

function M.spawn_button(position, to_location, sprite)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.BUTTON,
		to_location = to_location,
		sprite = sprite,
	}
	return action
end

function M.spawn_source(position, source_name)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.SOURCE,
		source_name = source_name
	}
	return action
end

function M.spawn_recipe_stand(position, recipe_name)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.RECIPE_STAND,
		recipe_name = recipe_name
	}
	return action
end

function M.spawn_reserved_stand(position, element_name)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.RESERVED_STAND,
		element_name = element_name
	}
	return action
end

function M.spawn_foundation(position, foundation_tag, foundation_cfg)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.FOUNDATION,
		foundation_tag = foundation_tag,
		foundation_cfg = foundation_cfg
	}
	return action
end

function M.spawn_trashcan(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.TRASHCAN,
	}
	return action
end

function M.spawn_zone(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.ZONE,
	}
	return action
end

function M.spawn_sprite(position, sprite, is_underground)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.SPRITE,
		sprite = sprite,
		is_underground = is_underground,
	}
	return action
end

function M.spawn_point(position)
	local action = {
		type = M.ACTION_TYPE.SPAWN_OBJECT,
		position = position,
		object_type = objects.TYPES.POINT,
	}
	return action
end

function M.set_td_start_point(position)
	local action = {
		type = M.ACTION_TYPE.SET_MODEL_PROPERTY,
		props = {td_start_point = position},
	}
	return action
end

function M.set_td_end_point(position)
	local action = {
		type = M.ACTION_TYPE.SET_MODEL_PROPERTY,
		props = {td_end_point = position},
	}
	return action
end

function M.set_model_props(props)
	local action = {
		type = M.ACTION_TYPE.SET_MODEL_PROPERTY,
		props = props,
	}
	return action
end

function M.tick(uid)
	local action = {
		type = M.ACTION_TYPE.TICK,
		uid = uid
	}
	return action
end

function M.npc_pick_item(uid, element_name)
	local action = {
		type = M.ACTION_TYPE.NPC_PICK_ITEM,
		uid = uid,
		element_name = element_name,
	}
	return action
end

function M.npc_drop_item(uid)
	local action = {
		type = M.ACTION_TYPE.NPC_DROP_ITEM,
		uid = uid,
	}
	return action
end

function M.update_miner_settings(uid, steps)
	local action = {
		type = M.ACTION_TYPE.UPDATE_MINER_SETTINGS,
		uid = uid,
		steps = steps,
	}
	return action
end

function M.extract_item_from_location(from_location_id, element_name) --uid should be set in action processing
	local action = {
		type = M.ACTION_TYPE.EXTRACT_ITEM_FROM_LOCATION,
		from_location_id = from_location_id,
		element_name = element_name,
	}
	return action
end

function M.show_foundations()
	local action = {
		type = M.ACTION_TYPE.SYS_SHOW_FOUNDATIONS,
	}
	return action
end

function M.destroy_object(uid)
	local action = {
		type = M.ACTION_TYPE.DESTROY_OBJECT,
		uid = uid
	}
	return action
end

return M
