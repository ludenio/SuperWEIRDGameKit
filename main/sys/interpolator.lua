local view = require "main.view.view"
local list = require "utils.list"
local data = require "main.data"

local M = {}

local DRAW_DELAY = 0.075
-- local DRAW_DELAY = 0.1

local snapshots = list.new()

local last_update = -1

function M.try_to_remove_generated_model()
	local model_to_replace = nil
	if (list.get_last(snapshots) - 1) - list.get_first(snapshots) > 0 then
		model_to_replace = snapshots.values[list.get_last(snapshots) - 1]
	end
	if model_to_replace and model_to_replace.is_model_generated then
		print("REMOVING GENERATED MODEL")
		local time = model_to_replace.time
		list.remove(snapshots, list.get_last(snapshots) - 1)
		snapshots.values[list.get_last(snapshots)].time = time
	end
end

function M.change_last_snapshot(model)
	snapshots.values[list.get_last(snapshots)].model = model
end



function M.load_snapshot(model, time, is_model_generated)
	list.pushright(snapshots, {model = model, time = time, is_model_generated = is_model_generated})
	last_update = time
end

local function interpolate(snapshot1, snapshot2, time)


	if snapshot1 == nil then
		print("INTERPOLATION: empty")
		return
	end

	local current_location_id = snapshot1.model.ptw[data.player_id]

	if not snapshot1.model.locations[current_location_id] then
		print("INTERPOLATION: wrong world in first snapshot")
		return
	end

	if snapshot2 == nil then
		print("INTERPOLATION: missing second snapshot")
		view.update_view(snapshot1.model.locations[current_location_id])
		return
	end

	local next_location_id = snapshot2.model.ptw[data.player_id]
	
	if not snapshot2.model.locations[next_location_id] then
		print("INTERPOLATION: wrong world in second snapshot")
		view.update_view(snapshot1.model.locations[current_location_id])
		return
	end

	local progress = 0
	if snapshot2.time ~= snapshot1.time then
		progress = (time - snapshot1.time) / (snapshot2.time - snapshot1.time)
	end
	view.update_intrpolate(snapshot1.model.locations[current_location_id], snapshot2.model.locations[next_location_id], progress)
end

function M.get_last_update()
	return last_update
end

function M.update(time)
	time = time - DRAW_DELAY
	while snapshots.values[list.get_first(snapshots) + 1] and snapshots.values[list.get_first(snapshots) + 1].time < time do
		list.popleft(snapshots)
	end
	interpolate(snapshots.values[list.get_first(snapshots)], snapshots.values[list.get_first(snapshots) + 1], time)
end

return M
