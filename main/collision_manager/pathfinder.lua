local collision_manager = require "main.collision_manager.collision_manager"
local list = require "utils.list"
local measure = require "utils.measure"
local objects = require "main.objects.objects"

local M = {}

local paths_to_endpoint = {}
local last_calculated_model_sns = {}

-- call this when something is built
function M.recalculate_paths_target(model, target)
	local tx, ty = target.x, target.y
	if not paths_to_endpoint then
		paths_to_endpoint = {}
	end
	if not paths_to_endpoint[model.id] then
		paths_to_endpoint[model.id] = {}
	end
	if not paths_to_endpoint[model.id][tx] then
		paths_to_endpoint[model.id][tx] = {}
	end
	paths_to_endpoint[model.id][tx][ty] = {}

	local queue = list.new()

	local next_target_to_endpoint = paths_to_endpoint[model.id][tx][ty]
	next_target_to_endpoint[tx] = {}
	next_target_to_endpoint[tx][ty] = {x = tx, y = ty}
	list.pushright(queue, {x = tx, y = ty})
	while not list.empty(queue) do
		local node = list.popleft(queue)
		local x, y = node.x, node.y
		local nbs = {{x = x + 1, y = y}, {x = x - 1, y = y}, {x = x, y = y + 1}, {x = x, y = y - 1}}
		for _, nb in pairs(nbs) do
			if not next_target_to_endpoint[nb.x] then
				next_target_to_endpoint[nb.x] = {}
			end
			if next_target_to_endpoint[nb.x][nb.y] == nil then
				next_target_to_endpoint[nb.x][nb.y] = {x = x, y = y}
				if not collision_manager.get_tile_collision(nb.x, nb.y, model) then
					list.pushright(queue, {x = nb.x, y = nb.y})
				end
			end
		end
	end
end

function M.reset_paths(model)
	paths_to_endpoint[model.id] = nil
	last_calculated_model_sns[model.id] = nil
end

local function get_sn(model)
	local sn = 0
	for k, object in pairs(model.objects) do
		if objects.is_affecting_pathfinder[object.type] then
			sn = sn + k
		end
	end
	return sn
end

local function check_sn(model)
	local sn = get_sn(model)

	if not last_calculated_model_sns[model.id] then
		last_calculated_model_sns[model.id] = 0
	end

	print(sn, last_calculated_model_sns[model.id])
	local result = sn == last_calculated_model_sns[model.id]
	last_calculated_model_sns[model.id] = sn
	return result
end

function M.get_path_target(position, model, target)
	measure.profile_scope_begin("get_path_target")
	if get_sn(model) ~= last_calculated_model_sns[model.id] then
		print("reset_paths")
		M.reset_paths(model)
	end

	local x, y = collision_manager.pos_to_tile(position.x, position.z)
	local tx, ty = collision_manager.pos_to_tile(target.x, target.z)
	if not (paths_to_endpoint and paths_to_endpoint[model.id] and paths_to_endpoint[model.id][tx] and paths_to_endpoint[model.id][tx][ty]) then
		M.recalculate_paths_target(model, {x = tx, y = ty})
	end
	local next_target_to_endpoint = paths_to_endpoint[model.id][tx][ty]
	if not (next_target_to_endpoint[x] and next_target_to_endpoint[x][y]) then
		measure.profile_scope_end()
		return nil
	end
	local target_tile = next_target_to_endpoint[x][y]
	local wx, wz = collision_manager.tile_to_pos(target_tile.x, target_tile.y)

	last_calculated_model_sns[model.id] = get_sn(model)
	measure.profile_scope_end()
	return vmath.vector3(wx, 0, wz)
end

return M