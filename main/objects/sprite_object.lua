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
		M.spawn(model, action.position, action.sprite, action.is_underground)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, sprite, is_underground)
	local uid
	if is_underground then
		uid = mm.create_object(model, "root#universal_underground_go", position)
	else
		uid = mm.create_object(model, "root#universal_go", position)
	end
	local self = model.objects[uid]
	self.sprite = sprite
	self.type = objects.TYPES.SPRITE
	self.visible = true
	self.uid = uid
	self.is_underground = is_underground
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

return M