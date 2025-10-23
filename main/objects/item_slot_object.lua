local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local view_data = require "main.view.view_data"
local pack = require "utils.pack"
local lights = require "main.lights"
local collision_manager = require "main.collision_manager.collision_manager"
local actions = require "main.sys.actions"
local zoom = require "main.zoom"
local view_utils = require "main.view.view_utils"

local M = {}

--=========================CREATE VIEW====================================
-- creates a new view representation of item slot object
--========================================================================
function M.new_view(object)
	local uid = object.uid
	if not uid then
		return
	end

	local view_object = factory.create(object.factory)

	local light_object = nil
	if object.light then
		light_object = factory.create("/root#light_source_factory")
		go.set_parent(light_object, view_object)
		go.set_position(vmath.vector3(0, 32, 0), light_object)
		lights.add_light_source(light_object, nil, object.light)
	end

	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "sprite"), light_object)



	if object.sprite then
		sprite.play_flipbook(msg.url("main", view_object, "sprite"), object.sprite)
	end
	
	return view_object, light_object
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION===============================
-- called from view
-- modifying an existing view representation of item slot object
--=====================================================================
function M.update_interpolate(uid, model1, model2, progress)
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	local v1 = object.position
	local v2 = object_new.position

	if object.item_uid and object_new.item_uid == object.item_uid and view_data.instances[object.item_uid] then
		local id = view_data.instances[object.item_uid]
		go.set_parent(view_data.instances[object.item_uid], M.get_attach_go(uid, model1, view_data.instances))
		go.set_position(model1.objects[object.item_uid].position, id)
		go.set_rotation(vmath.quat(), id)
	end

	go.set_position(vmath.lerp(progress, v1, v2), view_data.instances[uid])
end
--=========================INTERPOLATION===============================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position)
	end
end
--=========================ACTION HANDLING==============================
------------------------------------------------------------------------



--=========================SPAWN=========================================
-- creating a new item slot object in data-model
--=======================================================================
function M.spawn(model, position)
	local uid = mm.create_object(model, "root#universal_go", position)--"/root#item_slot_factory", position)
	local self = model.objects[uid]
	self.sprite = "fire"
	self.type = objects.TYPES.ITEM_SLOT
	self.item_uid = nil
	self.interactable = true
	self.is_storage = true
	self.uid = uid
	return uid
end
--=========================SPAWN=========================================
-------------------------------------------------------------------------

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return self.item_uid == nil
end

function M.try_insert_item(uid, model, item_uid)
	local self = model.objects[uid]
	if self.item_uid ~= nil then
		return false
	end
	self.item_uid = item_uid
	local item = model.objects[item_uid]
	item.owner_uid = uid
	return true
end

function M.try_remove_item(uid, model)
	local self = model.objects[uid]
	if self.item_uid == nil then
		return nil
	end
	local item_uid = self.item_uid
	self.item_uid = nil
	local item = model.objects[item_uid]
	item.owner_uid = nil
	return item_uid
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M