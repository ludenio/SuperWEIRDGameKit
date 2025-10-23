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
	
	local light_object = nil
	if object.light then
		-- light_object = factory.create("/root#light_source_factory")
-- 		go.set_parent(light_object, view_object)
-- 
-- 		timer.delay(0.01, false, function() --position linked to parent will be calculated only in next frame, so we can set position of light only in next frame
-- 			go.set_position(vmath.vector3(0, 32, 0), light_object)
-- 		end)
-- 
-- 		lights.add_light_source(light_object, nil, object.light)
	end

	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "sprite"), light_object)

	if object.sprite then
		sprite.play_flipbook(msg.url("main", view_object, "sprite"), object.sprite)
	end

	if not object.visible then
		msg.post(msg.url("main", view_object, "sprite"), "disable")
	else
		msg.post(msg.url("main", view_object, "sprite"), "enable")
	end

	return view_object, light_object
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

	local v1 = object.position
	local v2 = object_new.position

	if object_new.owner_uid == nil and object.owner_uid ~= nil then
		zoom.remove_object(msg.url("main", view_data.instances[uid], ""))
		view_utils.interpolate_item_parent(view_data.instances[uid], go.get_id("/root"), model2.objects[uid].position, progress)
	elseif object_new.owner_uid == nil and object.owner_uid == nil then
		zoom.register_object(msg.url("main", view_data.instances[uid], ""))
		go.set_position(vmath.lerp(progress, v1, v2), view_data.instances[uid])
	elseif object_new.owner_uid ~= nil then
		zoom.remove_object(msg.url("main", view_data.instances[uid], ""))
	end
	
	if not object.owner_uid then
		local cur_parent = go.get_parent(view_data.instances[uid])

		if cur_parent ~= nil or cur_parent ~= go.get_id("/root") then
			go.set_parent(view_data.instances[uid], go.get_id("/root"))
			zoom.register_object(msg.url("main", view_data.instances[uid], ""))
			--go.set_rotation(vmath.quat(), view_data.instances[uid])
		end
	end

	if object.visible and object_new.visible then
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "enable")
	else
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "disable")
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
		M.spawn(model, action.position, action.element_name)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, element_name)
	local uid = mm.create_object(model, "root#universal_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	local element = data.elements[element_name]
	self.name = element_name
	self.sprite = element.sprite
	if not element.visible then
		self.visible = false
	else
		self.visible = true
	end
	self.buy_price = element.buy_price
	self.sell_price = element.sell_price
	self.type = objects.TYPES.ITEM
	self.light = element.light
	self.owner_uid = nil
	if element.static == true then
		self.interactable = false
		self.is_pickable = false
	else
		self.interactable = true
		self.is_pickable = true
	end
	self.uid = uid
	-- model.items[uid] = true
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

return M