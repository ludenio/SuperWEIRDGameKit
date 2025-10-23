local M = {}
local visual_settings = require "main.visual_settings"

function M.detach_item()
end

function M.interpolate_item_parent(id, new_parent, offset, progress)
-- 	local init_position = go.get_world_position(id)
-- 	local init_rotation = go.get_world_rotation(id)
-- 	local end_position = go.get_world_position(new_parent) + offset
-- 	local end_rotation = go.get_world_rotation(new_parent)
-- 
-- 	go.set_parent(id, go.get_id("/root"))
-- 	go.set_position(vmath.lerp(progress, init_position, end_position), id)
-- 	go.set_rotation(vmath.slerp(progress, init_rotation, end_rotation), id)
end

return M
