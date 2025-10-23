local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local actions = require "main.sys.actions"
local data = require "main.data"
local stack = require "main.objects.stack"
local view_data = require "main.view.view_data"
local visual_settings = require "main.visual_settings"

local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of stand object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)
	sprite.play_flipbook(msg.url("main", view_object, "element_sprite"), object.element_sprite)
	sprite.set_constant(msg.url("main", view_object, "element_sprite"), "tint", vmath.vector4(1, 1, 1, 1))

	if visual_settings.enable_animation then
		go.set_scale(vmath.vector3(0.5,0.5,1), view_object)
		go.animate(view_object, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_OUTELASTIC, 0.8)
	end

	return view_object, light_object
end
--=========================CREATE VIEW====================================
-----------------------------------------------------------------------

local INSERT_ITEM_DURATION = 0.7
local INSERT_ITEM_LOCK_DURATION = 0.3

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of stand object
--=====================================================================
function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)

	if visual_settings.enable_animation then
		local item_uids = stack.item_uids(model1.objects[uid].stack)
		for i, item_uid in ipairs(item_uids) do
			if view_data.info[item_uid] and view_data.info[item_uid].owner_uid ~= uid then
				if view_data.info[item_uid].is_animated then
					go.cancel_animations(view_data.instances[item_uid])
					view_data.info[item_uid].is_animated = false
				end
			end
		end
	end
	
	stack.update_view(model2.objects[uid].stack, model2.objects[uid].stack, M.get_attach_go(uid, model, view_data.instances), vmath.vector3(-64, 24, 10))

	if visual_settings.enable_animation then
		local item_uids = stack.item_uids(model1.objects[uid].stack)
		for i, item_uid in ipairs(item_uids) do
			if view_data.info[item_uid] and view_data.info[item_uid].owner_uid ~= uid then
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
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of stand object
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.element_name)
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		self.npc_interact_cooldown = math.max(self.npc_interact_cooldown - 1, 0)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------	


--=========================SPAWN=========================================
-- creating a new stand object in data-model
--=====================================================================
function M.spawn(model, position, element_name)
	local uid = item_slot_object.spawn(model, position)
	local self = model.objects[uid]
	self.factory = "root#with_element_sprite_go"--"/root#stand_factory"
	self.sprite = "store"
	self.element_sprite = data.elements[element_name].sprite
	self.element_name = element_name
	self.type = objects.TYPES.RESERVED_STAND
	self.stack = stack.create({2, 3}, {offset_y = vmath.vector3(0, 32, -2)})
	self.npc_progress = 0
	self.npc_interactable = true
	self.npc_interact_cooldown = 0
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
	if self.element_name ~= model.objects[item_uid].name then
		return false
	end
	
	local result = stack.insert(self.stack, item_uid)
	
	if result then
		model.objects[item_uid].owner_uid = uid
		self.npc_interact_cooldown = INSERT_ITEM_LOCK_DURATION * 21
	end
	return result
end

function M.try_remove_item(uid, model)
	return nil
end

function M.npc_remove_item(uid, model)
	local self = model.objects[uid]
	if self.npc_interact_cooldown > 0 then
		return nil
	end
	if not M.is_empty(uid, model) then
		self.npc_progress = self.npc_progress + 0.2
	end
	if self.npc_progress < 1 then
		return nil
	end
	self.npc_progress = 0

	local item_uid = stack.remove(self.stack, #stack.item_uids(self.stack))
	if item_uid then
		model.objects[item_uid].owner_uid = nil
	end
	
	return item_uid
end

function M.get_production_type(uid, model)
	return model.objects[uid].element_name
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M