local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local actions = require "main.sys.actions"
local stack = require "main.objects.stack"
local view_data = require "main.view.view_data"

local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of stand object
--=====================================================================
function M.new_view(object)
	return item_slot_object.new_view(object)
end
--=========================CREATE VIEW====================================
-----------------------------------------------------------------------

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of stand object
--=====================================================================
function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of stand object
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------	


--=========================SPAWN=========================================
-- creating a new stand object in data-model
--=====================================================================
function M.spawn(model, position, stack_size)
	local uid = item_slot_object.spawn(model, position)
	local self = model.objects[uid]
	self.factory = "root#universal_go"--"/root#stand_factory"
	self.sprite = "counter"
	self.type = objects.TYPES.STAND
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------

function M.get_item(uid, model)
	local self = model.objects[uid]
	if stack.is_empty(self.stack) then
		return nil
	end
	local item_uids = stack.item_uids(self.stack)
	return item_uids[#item_uids]
end

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return stack.is_empty(self.stack)
end

function M.is_full(uid, model)
	local self = model.objects[uid]
	return stack.is_full(self.stack)
end

function M.try_insert_item(uid, model, item_uid)
	local self = model.objects[uid]
	local result = stack.insert(self.stack, item_uid)
	-- local result = item_slot_object.try_insert_item(uid, model, item_uid)
	local item = model.objects[item_uid]
	item.owner_uid = uid
	-- item.position = vmath.vector3(0, 60, 5)
	return result
end

function M.try_remove_item(uid, model)
	local self = model.objects[uid]
	local item_uid = stack.remove(self.stack, #stack.item_uids(self.stack))
	if not item_uid then
		return nil
	end
	local item = model.objects[item_uid]
	item.owner_uid = nil
	return item_uid
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M