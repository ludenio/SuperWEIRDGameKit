local actions = require "main.sys.actions"
local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local view_data = require "main.view.view_data"
local pack = require "utils.pack"
local zoom = require "main.zoom"
local lights = require "main.lights"
local collision_manager = require "main.collision_manager.collision_manager"
local data = require "main.data"
local view_utils = require "main.view.view_utils"

local M = {}

--=========================CREATE VIEW==============================
-- called from view 
-- creates a view representation of existing item object
--==================================================================
function M.new_view(object)
	local uid = object.uid
	if not uid then
		return
	end

	local view_object = factory.create(object.factory)
	object.handle = view_object
	go.set_position(object.position, view_object)

	if object.sprite then
		sprite.play_flipbook(msg.url("main", view_object, "sprite"), object.sprite)
	end

	msg.post(msg.url("main", view_object, "sprite"), "disable")
	return view_object, nil
end
--=========================CREATE VIEW==============================
--------------------------------------------------------------------


--=========================INTERPOLATION============================
-- called from view                        
-- modifying an existing view representation of item object  
--==================================================================

function M.update_interpolate(uid, model1, model2, progress)
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	if not object.visible and not object_new.visible then
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "disable")
	else
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "enable")
	end
end

--======================INTERPOLATION================================
---------------------------------------------------------------------

--========================ACTION HANDLING============================
-- called from mutator                        
-- modifying data-model of item object
--===================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position)
	local uid
	uid = mm.create_object(model, "root#universal_go", position)
	local self = model.objects[uid]
	self.sprite = "point"
	self.type = objects.TYPES.POINT
	self.visible = true
	self.npc_interactable = true
	self.is_storage = true
	self.uid = uid
	self.random = 1
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------

function M.is_empty(uid, model)
	return true
end

function M.npc_insert_item(uid, model, item_uid, npc_uid)
	local self = model.objects[uid]
	local item = model.objects[item_uid]
	item.npc_dropped = true
	local a = (self.random * 2377) % 720 / 2
	self.random = self.random + 1
	local offset = vmath.rotate(vmath.quat_rotation_y(a), vmath.vector3(1, 0, 0)) * 32
	item.position = self.position + offset
	return true
end

return M
