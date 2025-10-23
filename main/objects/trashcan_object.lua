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
local visual_settings = require "main.visual_settings"

local M = {}

local item_slot_object = require "main.objects.item_slot_object"

--=========================CREATE VIEW==============================
-- called from view 
-- creates a view representation of existing item object
--==================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 200, 20), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id

	return view_object, light_object
end
--=========================CREATE VIEW==============================
--------------------------------------------------------------------


--=========================INTERPOLATION============================
-- called from view                        
-- modifying an existing view representation of item object  
--==================================================================

--=========================SPINE ANIMATIONS PROCESSING=========================
--setting up spine animations depends on movespeed
--=============================================================================
local ANIMATION_LIST = {
	IDLE = 0,
	REACT = 1,
}

local cur_animations = {}

--play animation
local function play_animation(uid, animation)
	if cur_animations[uid] and cur_animations[uid] == animation then
		return
	end
	cur_animations[uid] = animation 
	if animation == ANIMATION_LIST.IDLE then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "idle", go.PLAYBACK_LOOP_FORWARD, {}, nil)
	end
	if animation == ANIMATION_LIST.REACT then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "action", go.PLAYBACK_ONCE_FORWARD, {track = 2}, nil)
	end
end


--decide what animation to play
local function animate(object, modified_object)
	if object.react then
		if visual_settings.enable_animation then
			play_animation(object.uid, ANIMATION_LIST.REACT)
		end
	else
		play_animation(object.uid, ANIMATION_LIST.IDLE)
	end
end

--=========================ANIMATIONS PROCESSING=========================
-----------------------------------------------------------------------

function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)
	local object1 = model1.objects[uid]
	local object2 = model2.objects[uid]
	animate(object1, object2)
	if object1.visible then
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, object1.progress)
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
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		if not self.player_interacted then
			self.progress = 0
		end
		self.player_interacted = nil

		if self.react_ticks > 0 then
			self.react_ticks = self.react_ticks - 1
		else
			self.react = false
		end
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, foundation_index)
	local uid = mm.create_object(model, "root#urn_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	self.visible = true
	self.interactable = true
	self.is_storage = true
	self.type = objects.TYPES.TRASHCAN
	self.owner_uid = nil
	self.uid = uid
	self.progress = 0
	self.react_ticks = 0
	self.react = false
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------

function M.is_empty(uid, model)
	return true
end

function M.try_insert_item(uid, model, item_uid)
	local self = model.objects[uid]
	self.player_interacted = true
	self.progress = self.progress + 0.05
	if self.progress >= 1 then
		self.react_ticks = 3
		self.react = true
		self.progress = 0
		model.objects[item_uid] = nil
		return true
	end
	return false
end

function M.try_remove_item(uid, model)
	return false
end

return M