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
local view_progress_bar = require "main.view.view_progress_bar"

local M = {}

local item_slot_object = require "main.objects.item_slot_object"
local stand_object = require "main.objects.stand_object"
local shop_object = require "main.objects.shop_object"
local item_object = require "main.objects.item_object"
local sell_point_object = require "main.objects.sell_point_object"
local recipe_object = require "main.objects.recipe_object"
local workbench_object = require "main.objects.workbench_object"
local button_object = require "main.objects.button_object"
local source_object = require "main.objects.source_object"
local recipe_stand_object = require "main.objects.recipe_stand_object"
local reserved_stand_object = require "main.objects.reserved_stand_object"
local guard_object = require "main.objects.guard_object"

local function router(type)
	if type == objects.TYPES.PLAYER then
		return M
	elseif type == objects.TYPES.ITEM then
		return item_object
	elseif type == objects.TYPES.STAND then
		return stand_object
	elseif type == objects.TYPES.SHOP then
		return shop_object
	elseif type == objects.TYPES.SELL_POINT then
		return sell_point_object
	elseif type == objects.TYPES.ITEM_SLOT then
		return item_slot_object
	elseif type == objects.TYPES.RECIPE then
		return recipe_object
	elseif type == objects.TYPES.WORKBENCH then
		return workbench_object
	elseif type == objects.TYPES.BUTTON then
		return button_object
	elseif type == objects.TYPES.SOURCE then
		return source_object
	elseif type == objects.TYPES.RECIPE_STAND then
		return recipe_stand_object
	elseif type == objects.TYPES.RESERVED_STAND then
		return reserved_stand_object
	elseif type == objects.TYPES.GUARD then
		return guard_object
	end
end

--=========================CREATE VIEW==============================
-- called from view 
-- creates a view representation of existing item object
--==================================================================
function M.new_view(object)
	local view_object, light_object = item_object.new_view(object)
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 200, 20), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id
	msg.post(msg.url("main", view_object, "sprite"), "disable")

	view_data.info[object.uid].can_create_square = true
	view_data.info[object.uid].radius = factory.create("/root#square_border_go")
	go.set_position(object.position, view_data.info[object.uid].radius)
	go.set_rotation(vmath.quat_rotation_x(-math.pi / 2), view_data.info[object.uid].radius)

	return view_object, light_object
end
--=========================CREATE VIEW==============================
--------------------------------------------------------------------


--=========================INTERPOLATION============================
-- called from view                        
-- modifying an existing view representation of item object  
--==================================================================

function M.update_interpolate(uid, model1, model2, progress)
	item_object.update_interpolate(uid, model1, model2, progress)
	local self = model1.objects[uid]
	local instance = view_data.instances[uid]

	if self.interactable and view_data.info[uid].can_create_square then
		msg.post(msg.url("main", view_data.info[uid].radius, "sprite"), "enable")
		view_data.info[uid].can_create_square = false
		timer.delay(0.5, false, function()
			view_data.info[uid].can_create_square = true
		end)
		local square_id = factory.create("/root#square_border_go")
		go.set_position(self.position, square_id)
		go.set_rotation(vmath.quat_rotation_x(-math.pi / 2), square_id)
		local v = vmath.rotate(zoom.get_camera_rotation(), vmath.vector3(0, 1, 0))
		go.animate(square_id, "position", go.PLAYBACK_ONCE_FORWARD, self.position + v * 100, go.EASING_LINEAR, 4, 0, function()
			go.delete(square_id)
		end)
		go.animate(msg.url("main", square_id, "sprite"), "tint.w", go.PLAYBACK_ONCE_FORWARD, 0, go.EASING_LINEAR, 3.5)
	elseif view_data.info[uid].radius then
		msg.post(msg.url("main", view_data.info[uid].radius, "sprite"), "disable")
	end
	view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, self.progress)
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
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		if not self.player_interacted then
			self.progress = 0
		end
		self.player_interacted = nil
		M.update_availability(action.uid, model)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position)
	local uid = mm.create_object(model, "root#universal_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	self.visible = false
	self.interactable = false
	self.type = objects.TYPES.ZONE
	self.owner_uid = nil
	self.uid = uid
	self.progress = 0
	self.visible = false
	self.interactable = false
	self.interaction_points = {
		vmath.vector3(-64, 0, -64), vmath.vector3(0, 0, -64), vmath.vector3(64, 0, -64),
		vmath.vector3(0, 0, -64) 							, vmath.vector3(0, 0, 64), 
		vmath.vector3(-64, 0, 64), vmath.vector3(0, 0, 64), vmath.vector3(64, 0, 64), 
	}
	M.update_availability(uid, model)
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

function M.update_availability(uid, model)
	local self = model.objects[uid]
	if model.wave_status and model.wave_status == 3 and model.wave > 1 then
		self.interactable = true
	else
		self.interactable = false
		self.progress = 0
	end
end

function M.player_interact(uid, model)
	local self = model.objects[uid]
	-- TODO: rewrite using shared enum
	if model.next_wave_requested or (model.wave_status and model.wave_status ~= 3) then
		M.update_availability(uid, model)
		return
	end
	self.player_interacted = true
	self.progress = self.progress + 0.05
	if self.progress >= 1 then
		self.progress = 0
		model.next_wave_requested = true
	end
	M.update_availability(uid, model)
end

return M