local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local stand_object = require "main.objects.stand_object"
local item_slot_object = require "main.objects.item_slot_object"
local pack = require "utils.pack"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"
local hashes = require "utils.hashes"
local zoom = require "main.zoom"
local visual_settings = require "main.visual_settings"


local M = {}

local DISPLAY_WIDTH = sys.get_config_int("display.width")
local DISPLAY_HEIGHT = sys.get_config_int("display.height")

--=========================CREATE VIEW=================================
-- called from view
-- creating a new view representation of sell point object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)
	view_data.info[object.uid].worked_income = 0

	-- msg.post(msg.url("main", view_object, "coin_icon"), "disable")
	-- msg.post(msg.url("main", view_object, "price"), "disable")
	
	if visual_settings.enable_animation then
		go.set_scale(vmath.vector3(0.5,0.5,1), view_object)
		go.animate(view_object, "scale", go.PLAYBACK_ONCE_FORWARD, vmath.vector3(1), go.EASING_OUTELASTIC, 0.8)
	end
	
	return view_object, light_object
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION===============================
-- called from view
-- modifying an existing view representation of sell point object
--=====================================================================

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
	if view_data.info[object.uid].proj_alive and view_data.info[object.uid].proj_alive > 0  then
		if visual_settings.enable_animation then
			play_animation(object.uid, ANIMATION_LIST.REACT)
		end
	else
		play_animation(object.uid, ANIMATION_LIST.IDLE)
	end
end

local INCOME_EXPIRE_PER_TICK = 5

local function process_income(uid, model1, model2, progress)
	local object1 = model1.objects[uid]
	local object2 = model2.objects[uid]

	view_data.info[uid].income_per_npc = view_data.info[uid].income_per_npc or {}
	view_data.info[uid].proj_alive = view_data.info[uid].proj_alive or 0
	
	if view_data.info[uid].last_interacted_tick ~= model1.tick then
		view_data.info[uid].last_interacted_tick = model1.tick
		
		if object1.last_interacted_npc_uid and object1.last_interacted_tick == model1.tick then
			view_data.info[uid].income_per_npc[object1.last_interacted_npc_uid] = (view_data.info[uid].income_per_npc[object1.last_interacted_npc_uid] or 0) + object1.income
		end

		for npc_uid, income in pairs(view_data.info[uid].income_per_npc) do
			view_data.info[uid].income_per_npc[npc_uid] = income - 10

			local position_from = go.get_position(view_data.instances[npc_uid]) + vmath.rotate(zoom.get_camera_rotation(), vmath.vector3(0, 48, 0))  
			local position_to = go.get_position(view_data.instances[uid]) + vmath.rotate(zoom.get_camera_rotation(), vmath.vector3(52, 80, 10))
			local item = factory.create("/root#universal_go")
			view_data.info[uid].proj_alive = view_data.info[uid].proj_alive + 1
			go.set_position(position_from, item)
			go.set_scale(vmath.vector3(0.4, 0.4, 1), item)
			sprite.play_flipbook(msg.url("main", item, "sprite"), "coin")
			zoom.register_object(msg.url(item))
			go.animate(item, "position.x", go.PLAYBACK_ONCE_FORWARD, position_to.x, go.EASING_LINEAR, 0.3, 0, function()
				zoom.remove_object(item)
				go.delete(item)
				view_data.info[uid].proj_alive = view_data.info[uid].proj_alive - 1
			end)
			go.animate(item, "position.z", go.PLAYBACK_ONCE_FORWARD, position_to.z, go.EASING_LINEAR, 0.3, 0, function()
			end)
			go.animate(item, "position.y", go.PLAYBACK_ONCE_FORWARD, (position_from.y + position_to.y) / 2 + 32, go.EASING_OUTQUAD, 0.15, 0, function()
				go.animate(item, "position.y", go.PLAYBACK_ONCE_FORWARD, position_to.y, go.EASING_INQUAD, 0.15, 0, function()
				end)
			end)

			if view_data.info[uid].income_per_npc[npc_uid] <= 0 then
				view_data.info[uid].income_per_npc[npc_uid] = nil
			end
		end
	end
end

local INSERT_ITEM_DURATION = 0.7
local INSERT_ITEM_LOCK_DURATION = 0.3

function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)
	local object1 = model1.objects[uid]
	local object2 = model2.objects[uid]
	animate(object1, object2)

	if visual_settings.enable_animation then
		local item_uid = object1.item_uid 

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
	
	process_income(uid, model1, model2, progress)
end
--=========================INTERPOLATION===============================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
--=====================================================================

function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position)
	elseif action.type == actions.ACTION_TYPE.TICK then
		local object = model.objects[action.uid]
		object.interact_cooldown = math.max(object.interact_cooldown - 1, 0)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
------------------------------------------------------------------------


--=========================SPAWN=========================================
-- creating a new sell point object in data-model
--=====================================================================
function M.spawn(model, position)
	local uid = item_slot_object.spawn(model, position)
	local self = model.objects[uid]
	self.factory = "root#table_shop_go"--"/root#sell_point_factory"
	self.sprite = nil
	self.income = 0
	self.type = objects.TYPES.SELL_POINT
	self.last_interacted_npc_uid = nil
	self.last_interacted_tick = nil
	self.npc_interactable = true
	self.interact_cooldown = 0
	return uid
end
--=========================SPAWN=========================================
-------------------------------------------------------------------------


function M.is_empty(uid, model)
	return item_slot_object.is_empty(uid, model)
end

function M.try_insert_item(uid, model, item_uid) -- TODO: in fact, this is not insertion, but sell, so we can rename this function
	return nil --item_slot_object.try_insert_item(uid, model, item_uid)
end

function M.npc_insert_item(uid, model, item_uid, npc_uid)
	local result = item_slot_object.try_insert_item(uid, model, item_uid)
	local item = model.objects[item_uid]
	item.position = vmath.vector3(-56, 60, 5)
	if result then
		model.objects[uid].last_interacted_npc_uid = npc_uid
		model.objects[uid].interact_cooldown = INSERT_ITEM_LOCK_DURATION * 21
	end
	return result
end

function M.player_interact(uid, model, player_uid)
	local object = model.objects[uid]
	if object.interact_cooldown > 0 or M.is_empty(uid, model) then
		return nil
	end

	local item_uid = item_slot_object.try_remove_item(uid, model)

	if item_uid then
		if model.objects[item_uid].sell_price then
			object.react = true
			object.react_ticks = 10
			object.income = model.objects[item_uid].sell_price
			object.last_interacted_tick = model.tick
			object.income_owner = player_uid
			model.money = model.money + model.objects[item_uid].sell_price
			model.objects[item_uid] = nil
			return nil
		end
	end
end

function M.try_remove_item(uid, model)
	return nil
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M