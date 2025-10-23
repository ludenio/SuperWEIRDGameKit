local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local view_data = require "main.view.view_data"
local view_progress_bar = require "main.view.view_progress_bar"
local pack = require "utils.pack"
local actions = require "main.sys.actions"
local data = require "main.data"
local item_object = require "main.objects.item_object"
local zoom = require "main.zoom"
local button_object = require "main.objects.button_object"
local view_utils = require "main.view.view_utils"
local recipe_object = require "main.objects.recipe_object"
local visual_settings = require "main.visual_settings"

local M = {}

local ATTACH_POSITIONS = {
	RECIPE = vmath.vector3(0, 55, 5),
	LEFT = vmath.vector3(-128, 55, 5),
	RIGHT = vmath.vector3(128, 55, 5),
	RESULT = vmath.vector3(0, 55, 5),
}

local INSERT_ITEM_DURATION = 0.7

local function update_child(uid, model1, model2, progress, child_index)
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	local child_uid = object[child_index]
	local child_uid_new = object_new[child_index]
	
	if child_uid_new ~= nil and child_uid ~= child_uid_new and view_data.instances[child_uid_new] then
		view_utils.interpolate_item_parent(view_data.instances[child_uid_new], M.get_attach_go(uid, model1, view_data.instances), model2.objects[child_uid_new].position, progress)
	elseif child_uid and child_uid_new == child_uid and view_data.instances[child_uid] then
		local id = view_data.instances[child_uid]
		go.set_parent(view_data.instances[child_uid], M.get_attach_go(uid, model1, view_data.instances))
		go.set_position(model1.objects[child_uid].position, id)
		go.set_rotation(vmath.quat(), id)
	end

	local item_uid = nil
	if child_index == "left_uid" or child_index == "right_uid" then
		item_uid = child_uid
	end

	if visual_settings.enable_animation then
		if item_uid then
			if view_data.info[item_uid] and view_data.info[item_uid].owner_uid ~= uid then
				if view_data.info[item_uid].is_animated then
					go.cancel_animations(view_data.instances[item_uid])
					go.set_parent(view_data.instances[item_uid], M.get_attach_go(uid, model1, view_data.instances))
					go.set_position(model1.objects[item_uid].position, view_data.instances[item_uid])
				end
				local position = go.get_position(view_data.instances[item_uid])
				go.set_position(vmath.vector3(0, 50, 0) + position, view_data.instances[item_uid])
				view_data.info[item_uid].owner_uid = uid
				view_data.info[item_uid].is_animated = true
				go.animate(view_data.instances[item_uid], "position", go.PLAYBACK_ONCE_FORWARD, position, go.EASING_OUTBOUNCE, INSERT_ITEM_DURATION, 0, function()
					view_data.info[item_uid].is_animated = false
				end)
			end
		end
	end
end

--=========================CREATE VIEW====================================
-- creating a new view representation of stand object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)
	sprite.set_constant(msg.url("main", view_object, "left_hint"	), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "right_hint"	), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "result_hint"	), "tint", vmath.vector4(1, 1, 1, 0.3))
	msg.post(msg.url("main", view_object, "left_hint"	), "disable")
	msg.post(msg.url("main", view_object, "right_hint"	), "disable")
	msg.post(msg.url("main", view_object, "result_hint"	), "disable")

	if visual_settings.enable_animation then
		go.set_scale(vmath.vector3(0.5,0.5,1), view_object)
		go.animate(view_object, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_OUTELASTIC, 0.8)
	end
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 250, 20), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id
	return view_object, light_object
end
--=========================CREATE VIEW====================================
-----------------------------------------------------------------------

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
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "idle", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	end
	if animation == ANIMATION_LIST.REACT then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "craft", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
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

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of stand object
--=====================================================================
function M.update_interpolate(uid, model1, model2, progress)
	local object1 = model1.objects[uid]
	local object2 = model2.objects[uid]

	if visual_settings.enable_animation then
		msg.post(msg.url("main", view_data.instances[uid], "spinemodel"), "enable")
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "disable")
		animate(object1, object2)
	else
		msg.post(msg.url("main", view_data.instances[uid], "spinemodel"), "disable")
		msg.post(msg.url("main", view_data.instances[uid], "sprite"), "enable")
	end
	
	if object1.sprite then
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "sprite"), object1.sprite)
	end

	update_child(uid, model1, model2, progress, "recipe_uid")
	update_child(uid, model1, model2, progress, "left_uid")
	update_child(uid, model1, model2, progress, "right_uid")
	update_child(uid, model1, model2, progress, "result_uid")
	

	if object1.recipe_uid == nil or object1.result_uid ~= nil then
		msg.post(msg.url("main", view_data.instances[uid], "left_hint"	), "disable")
		msg.post(msg.url("main", view_data.instances[uid], "right_hint"	), "disable")
		msg.post(msg.url("main", view_data.instances[uid], "result_hint"	), "disable")
	else
		local item_uid = object1.recipe_uid
		local item = model1.objects[item_uid]
		if view_data.instances[item_uid] then
			msg.post(msg.url("main", view_data.instances[item_uid], "sprite"), "disable")
		end
		msg.post(msg.url("main", view_data.instances[uid], "left_hint"		), "enable")
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "left_hint"	), data.elements[item.left].sprite)
		msg.post(msg.url("main", view_data.instances[uid], "right_hint"	), "enable")
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "right_hint"	), data.elements[item.right].sprite)
		msg.post(msg.url("main", view_data.instances[uid], "result_hint"	), "enable")
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "result_hint"), data.elements[item.result].sprite)
	end

	if object1.result_uid == nil and object2.result_uid ~= nil and view_data.info[uid].craft_fx_last_model ~= model1 then
		view_data.info[uid].craft_fx_last_model = model1
		particlefx.play(msg.url("main", view_data.instances[uid], "craft_fx"))
	end

	if object2.progress > object1.progress then
		local craft_progress = object1.progress * (1 - progress) + object2.progress * progress 
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, craft_progress)
	else
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, 0)
	end
	
	
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
		M.spawn(model, action.position, action.recipe_name)
	elseif action.type == actions.ACTION_TYPE.TICK then
		local object = model.objects[action.uid]
		if M.can_craft(action.uid, model) then
			object.progress = math.max(object.progress + 1/30, 0)
			M.craft(action.uid, model)
			object.react = true
		elseif object.result_uid == nil then
			object.progress = 0
			object.react = false
		else
			object.react = false
		end

		-- if self.react_ticks > 0 then
		-- 	self.react_ticks = self.react_ticks - 1
		-- else
		-- 	self.react = false
		-- end
	elseif action.type == actions.ACTION_TYPE.BUTTON_PRESS then
		local self = model.objects[action.uid]
		self.progress = math.min(self.progress + 0.2, 1)
		M.craft(action.uid, model)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------	


--=========================SPAWN=========================================
-- creating a new stand object in data-model
--=====================================================================
function M.spawn(model, position, recipe_name)
	local uid = item_slot_object.spawn(model, position)
	local self = model.objects[uid]
	self.factory = "root#workbench_go"--"/root#stand_factory"
	self.sprite = "table_blueprint"
	self.type = objects.TYPES.WORKBENCH
	self.progress = 0
	self.interaction_points = {ATTACH_POSITIONS.LEFT, ATTACH_POSITIONS.RIGHT}
	M.try_insert_item(uid, model, recipe_object.spawn(model, position, recipe_name))
	
	-- self.button_uid = button_object.spawn(model, button_create_action.position, uid)
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------

function M.can_craft(uid, model)
	local self = model.objects[uid]
	if not self.recipe_uid or not self.left_uid or not self.right_uid or self.result_uid then
		return false
	end
	local recipe = model.objects[self.recipe_uid]
	if data.recipes[recipe.name].left ~= model.objects[self.left_uid].name then
		return false
	end
	if data.recipes[recipe.name].right ~= model.objects[self.right_uid].name then
		return false
	end
	return true
end

function M.craft(uid, model)
	local object = model.objects[uid]
	if not M.can_craft(uid, model) or object.progress < 1 then
		return
	end
	local recipe = model.objects[object.recipe_uid]
	-- object.progress = 0
	mm.delete_object(model, object.left_uid)
	mm.delete_object(model, object.right_uid)
	object.left_uid = nil
	object.right_uid = nil

	object.result_uid = item_object.spawn(model, ATTACH_POSITIONS.RESULT, recipe.result)
	local item = model.objects[object.result_uid]
	item.owner_uid = uid
	return
end

function M.is_empty(uid, model)
	return item_slot_object.is_empty(uid, model)
end

function M.try_insert_item(uid, model, item_uid)
	local self = model.objects[uid]

	local item = model.objects[item_uid]
	if self.result_uid then
		return
	end
	
	if self.recipe_uid == nil then
		if item.type == objects.TYPES.RECIPE then
			item.visible = false
			item.owner_uid = uid
			item.position = ATTACH_POSITIONS.RECIPE
			self.recipe_uid = item_uid
			return true
		end
		return false
	else
		if item.type == objects.TYPES.RECIPE then
			return false
		end
		
		if self.left_uid == nil then
			if data.recipes[model.objects[self.recipe_uid].name].left == item.name then
				item.owner_uid = uid
				self.left_uid = item_uid
				item.position = ATTACH_POSITIONS.LEFT
				M.craft(uid, model)
				return true
			end
		end
		if self.right_uid == nil then
			if data.recipes[model.objects[self.recipe_uid].name].right == item.name then
				item.owner_uid = uid
				self.right_uid = item_uid
				item.position = ATTACH_POSITIONS.RIGHT
				M.craft(uid, model)
				return true
			end
		end
	end
	return false
end

function M.try_remove_item(uid, model)
	local self = model.objects[uid]
	
	if self.result_uid ~= nil then
		local item_uid = self.result_uid
		self.result_uid = nil
		local item = model.objects[item_uid]
		item.owner_uid = uid
		return item_uid
	else
		return nil
	end
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M