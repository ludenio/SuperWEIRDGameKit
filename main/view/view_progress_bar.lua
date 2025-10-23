local M = {}

local progress_bars = {}
local max_id = 0

function M.init_progress_bar(position, parent)
	max_id = max_id + 1
	progress_bars[max_id] = {
		canvas = factory.create("root#progress_bar_canvas"),
		progress = factory.create("root#progress_bar_progress"),
		position = position,
		hide_delay_handle = nil,
	}
	go.set_parent(progress_bars[max_id].canvas, parent)
	go.set_parent(progress_bars[max_id].progress, parent)
	msg.post(msg.url("main", progress_bars[max_id].canvas, "sprite"), "disable")
	msg.post(msg.url("main", progress_bars[max_id].progress, "sprite"), "disable")
	return max_id
end

local hb_i_sz = 112
local hb_progress_y_size = 14
local hb_min_sz = 10

function M.set_progress_bar(id, value, hide_delay)
	if not progress_bars[id] then
		return
	end

	local progress_bar = progress_bars[id]
	
	local x_size = value * (hb_i_sz - hb_min_sz) + hb_min_sz
	local x_dpos = (x_size - hb_i_sz) / 2

	local canvas_pos = progress_bar.position
	local progress_pos = progress_bar.position + vmath.vector3(x_dpos, 0, 5)

	if progress_bar.hide_delay_handle ~= nil then
		timer.cancel(progress_bar.hide_delay_handle)
		progress_bar.hide_delay_handle = nil
	end

	if value <= 0 or value >= 1 then
		msg.post(msg.url("main", progress_bar.canvas, "sprite"), "disable")
		msg.post(msg.url("main", progress_bar.progress, "sprite"), "disable")
		return
	else
		msg.post(msg.url("main", progress_bar.canvas, "sprite"), "enable")
		msg.post(msg.url("main", progress_bar.progress, "sprite"), "enable")
	end

	local image_id = hash("progress_green")
	if x_size <= hb_i_sz / 3 then
		image_id = hash("progress_red")
	elseif x_size <= hb_i_sz * 2 / 3 then
		image_id = hash("progress_yellow")
	end
	msg.post(msg.url("main", progress_bar.progress, "sprite"), "play_animation", {id = image_id})
	go.set(msg.url("main", progress_bar.progress, "sprite"), "size", vmath.vector3(x_size, hb_progress_y_size, 0))
	go.set(msg.url("main", progress_bar.canvas, ""), "position", canvas_pos)
	go.set(msg.url("main", progress_bar.progress, ""), "position", progress_pos)

	if hide_delay ~= nil then
		progress_bar.hide_delay_handle = timer.delay(hide_delay, false, function()
			M.set_progress_bar(id, 0)
		end)
	end
end

function M.delete_progress_bar(id)
	go.delete(progress_bars[id].canvas)
	go.delete(progress_bars[id].progress)
	progress_bars[id] = nil
	return
end

return M
