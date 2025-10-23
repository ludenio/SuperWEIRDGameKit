local view_data = require "main.view.view_data"
local visual_settings = require "main.visual_settings"

local M = {}

local BASE_GRID_SIZE = {4, 1}

local offset_y = vmath.vector3(0, 32, 2)
local offset_x = vmath.vector3(64, 0, 0)

local function get_position(stack, i)
	i = i - 1
	local y = i % stack.grid_size[1]
	local x = math.floor(i / stack.grid_size[1])
	return y * stack.offset_y + x * stack.offset_x
end

function M.draw_item(stack, parent_node, parnet_offset, rotation, i)
	local item_uid = stack.item_uids[i]
	if view_data.instances[item_uid] then
		local position = vmath.rotate(rotation, get_position(stack, i)) + parnet_offset
		go.set_rotation(rotation, view_data.instances[item_uid])
		go.set_position(position, view_data.instances[item_uid])
		go.set_parent(view_data.instances[item_uid], parent_node)
		if stack.scale ~= nil then
			go.set_scale(vmath.vector3(stack.scale, stack.scale, 1), view_data.instances[item_uid])
		end
	end
end

function M.update_view(stack, stack_new, parent_node, parnet_offset, rotation)
	if M.is_empty(stack) then
		return
	end
	rotation = rotation or vmath.quat()
	for i = 1, #stack.item_uids do
		M.draw_item(stack, parent_node, parnet_offset, rotation, i)
	end
end

function M.create(grid_size, settings)
	local stack = {}
	stack.item_uids = {}
	stack.grid_size = grid_size or BASE_GRID_SIZE
	stack.capacity = stack.grid_size[1] * stack.grid_size[2]
	stack.offset_x = vmath.vector3(offset_x)
	stack.offset_y = vmath.vector3(offset_y)
	if settings then
		if settings.offset_x then
			stack.offset_x = settings.offset_x
		end
		if settings.offset_y then
			stack.offset_y = settings.offset_y
		end
		if settings.scale then
			stack.scale = settings.scale
			stack.offset_x.x = stack.offset_x.x * settings.scale
			stack.offset_y.y = stack.offset_y.y * settings.scale
		end
	end
	return stack
end

function M.is_empty(stack)
	return #stack.item_uids == 0
end

function M.is_full(stack)
	return #stack.item_uids == stack.capacity
end

function M.insert(stack, uid)
	if M.is_full(stack) then
		return false
	end
	table.insert(stack.item_uids, uid)
	return true
end

function M.item_uids(stack)
	return stack.item_uids
end

function M.remove(stack, pos)
	if stack.item_uids[pos] == nil then
		return
	end
	local item_uid = stack.item_uids[pos]
	table.remove(stack.item_uids, pos)
	return item_uid
end

return M
