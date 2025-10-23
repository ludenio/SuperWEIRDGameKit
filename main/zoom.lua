local light = require "main.lights"

local zoomable_objects = {}
local zoomable_object_flipped = {}

local M = {}

local HORIZONTAL_OFFSET = 1000
local camera_offset = vmath.vector3(0, 1500, HORIZONTAL_OFFSET)
local camera_rotation = math.atan2(camera_offset.y, camera_offset.z)
local camera_target = nil
local CAMERA_OFFSET_Y_LIMITS = {
	MIN = 200,
	MAX = 2000,
	DELTA = 100,
	TOGGLE_DELTA_PER_SEC = 2000,
}

local camera_offset_y_target = 800
local camera_horizontal_step = 0
local camera_horizontal_step_target = 0

local camera_pos = camera_offset

function M.register_object(url)
	zoomable_objects[url.path] = true
	M.update_item_rotation(url)
	light.update_rotations()
end

function M.register_object_list(list)
	for _, name in pairs(list) do
		M.register_object(msg.url(name))
	end
end

function M.remove_object(name)
	zoomable_objects[msg.url(name).path] = nil
end

local FLIP_ROT = vmath.quat_rotation_y(math.pi)

function M.update_item_rotation(url)
	if not go.exists(url) then
		zoomable_objects[url] = nil
		return
	end
	if zoomable_object_flipped[url] then
		go.set_rotation(M.get_camera_rotation() * FLIP_ROT, url)
	else
		go.set_rotation(M.get_camera_rotation(), url)
	end
end


function M.set_flipped(url, flipped)
	zoomable_object_flipped[url.path] = flipped
	M.update_item_rotation(url.path)
end

function M.is_flipped(url)
	return zoomable_object_flipped[url.path]
end

function M.set_camera_offset_y(offset)
	camera_offset.y = offset
	camera_rotation = math.atan2(camera_offset.y, camera_offset.z)
	go.set_rotation(M.get_camera_rotation(), "camera")
	for url, _ in pairs(zoomable_objects) do
		M.update_item_rotation(url)
	end
	light.update_rotations()
end

local camera_target_change_progress = 0
local camera_target_old = nil

function M.set_camera_target(id)
	if camera_target ~= nil and camera_target ~= id then
		camera_target_old = camera_target
		camera_target_change_progress = 0
		-- TODO: make transition work properly. For now it is off.
		-- camera_target_change_progress = 1
	end
	camera_target = id
end

function M.get_camera_rotation()
	return vmath.quat_rotation_y(camera_horizontal_step * math.pi / 4) * vmath.quat_rotation_x(-camera_rotation)
end

function M.get_camera_horizontal_step()
	return camera_horizontal_step_target
end

function M.get_horizontal_rotation()
	return vmath.quat_rotation_y(camera_horizontal_step * math.pi / 4)
end

function M.zoom_in()
	camera_offset_y_target = math.max(camera_offset_y_target - CAMERA_OFFSET_Y_LIMITS.DELTA, CAMERA_OFFSET_Y_LIMITS.MIN)
end

function M.zoom_out()
	camera_offset_y_target = math.min(camera_offset_y_target + CAMERA_OFFSET_Y_LIMITS.DELTA, CAMERA_OFFSET_Y_LIMITS.MAX)
end

function M.rotate_left()
	camera_horizontal_step_target = camera_horizontal_step_target - 1
end

function M.rotate_right()
	camera_horizontal_step_target = camera_horizontal_step_target + 1
end


function M.zoom_in_dt(dt)
	camera_offset_y_target = math.max(camera_offset_y_target - CAMERA_OFFSET_Y_LIMITS.TOGGLE_DELTA_PER_SEC * dt, CAMERA_OFFSET_Y_LIMITS.MIN)
end

function M.zoom_out_dt(dt)
	camera_offset_y_target = math.min(camera_offset_y_target + CAMERA_OFFSET_Y_LIMITS.TOGGLE_DELTA_PER_SEC * dt, CAMERA_OFFSET_Y_LIMITS.MAX)
end

local zoom_in = false
local zoom_out = false

function M.toggle_zoom_in()
	zoom_in = true
end

function M.toggle_zoom_out()
	zoom_out = true
end

function M.set_zoom_target(target)
	camera_offset_y_target = target
end

function M.get_zoom_target()
	return camera_offset_y_target
end

function M.set_zoom_progress_target(progress)
	M.set_zoom_target(CAMERA_OFFSET_Y_LIMITS.MIN + (CAMERA_OFFSET_Y_LIMITS.MAX - CAMERA_OFFSET_Y_LIMITS.MIN) * progress)
end

function M.update(dt)
	if camera_target and go.exists(camera_target) then
		if zoom_in and not zoom_out then
			M.zoom_in_dt(dt)
			zoom_in = false
		elseif zoom_out then
			M.zoom_out_dt(dt)
			zoom_out = false
		end
		
		local y = (camera_offset.y * (0.1 / dt) + camera_offset_y_target) / (0.1 / dt + 1)
		camera_horizontal_step = (camera_horizontal_step * (0.1 / dt) + camera_horizontal_step_target) / (0.1 / dt + 1)
		M.set_camera_offset_y(y)

		local target_pos = go.get_position(camera_target)
		if camera_target_change_progress > 0 and go.exists(camera_target_old) then
			target_pos = target_pos * (1 - camera_target_change_progress) + go.get_position(camera_target_old) * camera_target_change_progress
			camera_target_change_progress = camera_target_change_progress - 2 * dt
		end
		
		go.set_position(target_pos + vmath.rotate(M.get_horizontal_rotation(), camera_offset) + vmath.rotate(M.get_camera_rotation(), vmath.vector3(0, 64, 0)), "camera")
	end
end

return M