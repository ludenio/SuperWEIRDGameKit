local pack = require "utils.pack"
local cu = require "utils.common_utils"
local settings = require "main.settings"


local M = {}

function M.new()
	return {
		ptw = {}, -- player to world link
		money = settings.init_money,
		locations = {
			{
			uid_max = 0, --default location is always with id 1
			tick = 0,
			objects = {},
			player_object_uids = {},
			items = {},
			buildings = {},
			money = 0,
			player_object_next_skin = 0,
			foundations_unlocked = settings.foundation_revealed_count,
			foundations = {},
			health = settings.init_health,
			id = 1,
			block_interact = {},
			}
		},
	}
end

function M.add_location(model, location_id)
	model.locations[location_id] = {
		uid_max = 0,
		tick = model.locations[1].tick,
		objects = {},
		player_object_uids = {},
		items = {},
		buildings = {},
		money = 0,
		player_object_next_skin = 0,
		foundations_unlocked = settings.foundation_revealed_count,
		foundations = {},
		health = settings.init_health,
		id = location_id,
		block_interact = {},
	}
end

function M.get_location(model, location_id)
	if model and location_id and model.locations then
		return model.locations[location_id]
	end
	return nil
end

function M.create_object(location, factory, position)
	location.uid_max = location.uid_max + 1
	location.objects[location.uid_max] = {
		factory = factory,
		position = position,
		uid = location.uid_max,
		location_id = location.id,
	}
	return location.uid_max
end

function M.clone_object(location, uid)
	location.uid_max = location.uid_max + 1
	location.objects[location.uid_max] = cu.copy_table(location.objects[uid])
	return location.uid_max
end

function M.delete_object(location, uid)
	location.objects[uid] = nil
end

return M
