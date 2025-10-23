local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local item_object = require "main.objects.item_object"
local recipe_object = require "main.objects.recipe_object"
local pack = require "utils.pack"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"


local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of shop object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)
	
	return view_object, light_object
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of shop object
--=====================================================================	
function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)

	-- if model1.objects[uid].item_uid then
	-- 	go.set_position(vmath.vector3(0, 60, 5), view_data.instances[model1.objects[uid].item_uid])
	-- end
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of shop object
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.recipe_name)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------

--=========================SPAWN=========================================
-- creating a new shop object in data-model
--=====================================================================
function M.spawn(model, position, recipe_name)
	local uid = item_slot_object.spawn(model, position)
	local recipe_uid = recipe_object.spawn(model, position, recipe_name)
	local self = model.objects[uid]
	self.factory = "root#universal_go"--"/root#shop_factory"
	self.sprite = "stand"
	self.type = objects.TYPES.RECIPE_STAND
	self.recipe_of = model.objects[recipe_uid].result
	item_slot_object.try_insert_item(uid, model, recipe_uid)
	model.objects[recipe_uid].position = vmath.vector3(0, 60, 5)
	
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------


function M.is_empty(uid, model)
	return true
end

function M.try_insert_item(uid, model, item_uid)
	return false
end

function M.try_remove_item(uid, model)
	local self = model.objects[uid]

	local item_uid = self.item_uid
	self.item_uid = mm.clone_object(model, self.item_uid)

	return item_uid
end


function M.get_production_type(uid, model)
	local object = model.objects[uid]
	return object.recipe_of
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M