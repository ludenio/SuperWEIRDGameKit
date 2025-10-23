local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local item_object = require "main.objects.item_object"
local pack = require "utils.pack"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"
local data = require "main.data"
local settings = require "main.settings"
local view_progress_bar = require "main.view.view_progress_bar"
local visual_settings = require "main.visual_settings"
local zoom = require "main.zoom"


local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of shop object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)

	-- msg.post(msg.url("main", view_object, "coin_icon"), "enable")
	-- msg.post(msg.url("main", view_object, "price"), "enable")
	-- label.set_text(msg.url("main", view_object, "price"), tostring(object.cost))

	if visual_settings.enable_animation then
		go.set_scale(vmath.vector3(0.5,0.5,1), view_object)
		go.animate(view_object, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_OUTELASTIC, 0.8)
	end
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 128, 5), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id
	
	return view_object, light_object
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of shop object
--=====================================================================	

--=========================SPINE ANIMATIONS PROCESSING=========================
--setting up spine animations depends on movespeed
--=============================================================================
local ANIMATION_LIST = {
	IDLE = 0,
	REACT = 1,
	IDLE_EMPTY = 2,
}

local cur_animations = {}
local lock_animations = {}

--play animation
local function play_animation(uid, animation)
	if lock_animations[uid] then
		return
	end
	if cur_animations[uid] and cur_animations[uid] == animation then
		return
	end
	cur_animations[uid] = animation 
	if animation == ANIMATION_LIST.IDLE then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "idle", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	end
	if animation == ANIMATION_LIST.REACT then
		lock_animations[uid] = true
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "collect", go.PLAYBACK_ONCE_FORWARD, {blend_duration = 0.1}, function()
			lock_animations[uid] = false
		end)
	end
	if animation == ANIMATION_LIST.IDLE_EMPTY then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "empty", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	end
end


--decide what animation to play
local function animate(object, modified_object)
	if object.react then
		if visual_settings.enable_animation then
			play_animation(object.uid, ANIMATION_LIST.REACT)
		end
	elseif object.regen_ticks_left == 0 then
		play_animation(object.uid, ANIMATION_LIST.IDLE)
	else
		play_animation(object.uid, ANIMATION_LIST.IDLE_EMPTY)
	end
end

--=========================ANIMATIONS PROCESSING=========================
-----------------------------------------------------------------------

function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)

	local object1 = model1.objects[uid]
	local object2 = model2.objects[uid]

	--[[
	if object1.name == "source_tree" then
		if visual_settings.enable_animation  then
			msg.post(msg.url("main", view_data.instances[uid], "spinemodel"), "enable")
			msg.post(msg.url("main", view_data.instances[uid], "sprite"), "disable")
			animate(object1, object2)
		else
			msg.post(msg.url("main", view_data.instances[uid], "spinemodel"), "disable")
			msg.post(msg.url("main", view_data.instances[uid], "sprite"), "enable")
		end
	end

	if object1.sprite and view_data.instances[uid] then
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "sprite"), object1.sprite)
	end
	--]]

	if visual_settings.enable_animation then
		if object1.regen_ticks_left == 0 and object2.regen_ticks_left ~= 0 and view_data.info[uid].is_disappear_animated ~= true  then
			local effect = nil
			local scale = nil
			local position_offset = nil
			play_animation(uid, ANIMATION_LIST.REACT)
			--[[
			if object1.name == "source_iron" then
				effect = "fungi_collect"
				scale = vmath.vector3(2)
				position_offset = vmath.vector3(-24, 96, 1)
			elseif object1.name == "source_stone" then
				effect = "star_chpok"
				scale = vmath.vector3(1.3)
				position_offset = vmath.vector3(0,-32, 1)
			end
			if effect then
				view_data.info[uid].is_disappear_animated = true
				local seq_fx_id = factory.create("/root#seq_fx_go")
				go.set_position(object1.position + vmath.rotate(zoom.get_camera_rotation(), position_offset), seq_fx_id)
				go.set_rotation(zoom.get_camera_rotation(), seq_fx_id)
				go.set_scale(scale, seq_fx_id)
				sprite.play_flipbook(seq_fx_id, effect, function()
					view_data.info[uid].is_disappear_animated = false
					go.delete(seq_fx_id)
				end)
			end
			--]]
		end
	end

	if visual_settings.enable_animation then
		if object1.do_scale_animation and view_data.info[uid] and view_data.info[uid].is_animated ~= true  then
			go.set_scale(vmath.vector3(1, 1, 1), view_data.instances[uid])
			view_data.info[uid].is_animated = true
			go.animate(view_data.instances[uid], "scale", go.PLAYBACK_ONCE_PINGPONG, vmath.vector3(1.15, 1.15, 1), go.EASING_OUTBACK, 1, 0, function()
				view_data.info[uid].is_animated = false
			end)
		end
	end

	if visual_settings.enable_animation then
		if object1.regen_ticks_left ~= 0 and object2.regen_ticks_left == 0 and view_data.info[uid] and view_data.info[uid].is_animated ~= true  then
			go.set_scale(vmath.vector3(0.5,0.5,1), view_data.instances[uid])
			view_data.info[uid].is_animated = true
			go.animate(view_data.instances[uid], "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_OUTELASTIC, 0.4, 0, function()
				view_data.info[uid].is_animated = false
			end)
		end
	end

	if object2.progress > object1.progress and object2.regen_ticks_left ~= 0 then
		local craft_progress = object1.progress * (1 - progress) + object2.progress * progress 
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, craft_progress)
	else
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, 0)
	end

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

local SCALE_ANIMATION_COOLDOWN = 200

function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.source_name)
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		if self.regen_ticks_left > 0 then
			self.progress = (data.sources[self.name].regen_ticks - self.regen_ticks_left) / data.sources[self.name].regen_ticks
			self.regen_ticks_left = self.regen_ticks_left - 1
			if self.regen_ticks_left == 0 then
				self.interactable = true
				self.progress = 0
				M.set_state(action.uid, model, 1)
			end
		else
			if not self.player_interacted then
				self.progress = 0
				self.react = false
			else
				self.scale_animaion_cooldown = SCALE_ANIMATION_COOLDOWN
				self.react = true
			end
			self.player_interacted = nil
		end


		if self.regen_ticks_left == 0 then
			self.scale_animaion_cooldown = self.scale_animaion_cooldown - 1
		end
		
		if self.scale_animaion_cooldown <= 0 then
			self.do_scale_animation = true
			self.scale_animaion_cooldown = SCALE_ANIMATION_COOLDOWN
		else
			self.do_scale_animation = false
		end
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------

--=========================SPAWN=========================================
-- creating a new shop object in data-model
--=====================================================================
function M.spawn(model, position, source_name)
	local uid = mm.create_object(model, "root#universal_go", position)
	local self = model.objects[uid]
	if source_name == "source_tree" then
		self.factory = "root#tree_go"
	else
		self.factory = "root#universal_go"
	end
	self.sprite = "shop"
	self.type = objects.TYPES.SOURCE
	self.interactable = true
	self.name = source_name
	self.regen_ticks_left = 0
	self.progress = 0
	self.is_storage = true
	self.do_scale_animation = false
	self.scale_animaion_cooldown = SCALE_ANIMATION_COOLDOWN + (uid * 7) % 20
	M.set_state(uid, model, 1)
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------

function M.setup_next_state_item(uid, model, state)
	local self = model.objects[uid]
	local source_data = data.sources[self.name]
	local drop_name = source_data["drop" .. tostring(self.state + 1)]
	if drop_name and data.elements[drop_name] then
		self.item_uid = item_object.spawn(model, vmath.vector3(0, 0, 0), drop_name)
		model.objects[self.item_uid].visible = false
		model.objects[self.item_uid].interactable = false
		model.objects[self.item_uid].owner_uid = uid
	end
end

function M.drop_item(uid, model, element_name)
	local self = model.objects[uid]
	model.objects[self.item_uid].visible = true
	model.objects[self.item_uid].interactable = true
	model.objects[self.item_uid].owner_uid = nil
	local item_uid = self.item_uid
	self.item_uid = nil
	return item_uid
end

function M.set_state(uid, model, state)
	local self = model.objects[uid]
	if self.regen_ticks_left > 0 then
		return
	end
	local source_data = data.sources[self.name]
	self.state = math.min(state, source_data.states_n)
	if source_data.states_n == self.state then
		self.regen_ticks_left = source_data.regen_ticks
		self.interactable = false
	end
	self.sprite = source_data["sprite" .. tostring(self.state)]
	local drop_name = source_data["drop" .. tostring(self.state)]
	local drop = nil
	if drop_name and data.elements[drop_name] then
		drop = M.drop_item(uid, model, drop_name)
	end
	M.setup_next_state_item(uid, model, state)
	return drop
end

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return self.item_uid == nil
end

function M.try_insert_item(uid, model, item_uid)
	return false
end

function M.try_remove_item(uid, model, item_uid)
	return nil
end

function M.player_try_remove_item(uid, model, p_uid)
	local DIST_MODIFIER = 40
	
	local self = model.objects[uid]
	local player = model.objects[p_uid]
	if self.regen_ticks_left > 0 then
		return
	end
	local distance = vmath.length(player.position - self.position) / DIST_MODIFIER
	local progress_increment = 1 / (distance * distance)
	self.player_interacted = true
	self.progress = self.progress + progress_increment
	if self.progress >= 1 then
		self.progress = 0
		return M.set_state(uid, model, self.state + 1)
	end
	return
end

function M.get_production_type(uid, model)
	local object = model.objects[uid]
	local data = data.sources[object.name]
	return data.drop2
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M