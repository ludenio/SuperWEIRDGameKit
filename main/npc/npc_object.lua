local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"
local view_utils = require "main.view.view_utils"
local stack = require "main.objects.stack"
local lights = require "main.lights"
local data = require "main.data"
local zoom = require "main.zoom"
local collision_manager = require "main.collision_manager.collision_manager"
local settings = require "main.settings"
local view_progress_bar = require "main.view.view_progress_bar"
local visual_settings = require "main.visual_settings"
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
local diggable_tile_object = require "main.objects.diggable_tile_object"
local point_object = require "main.objects.point_object"

local function router(type)
	if type == objects.TYPES.ITEM then
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
	elseif type == objects.TYPES.DIGGABLE_TILE then
		return diggable_tile_object
	elseif type == objects.TYPES.POINT then
		return point_object
	end
end

local function distance(pos1, pos2)
	return math.sqrt(math.pow((pos1.x - pos2.x) / settings.player_speed_x, 2) + math.pow((pos1.z - pos2.z) / settings.player_speed_y, 2))
end

local INTERACTION_RADIUS = 6
local HIT_INDICATOR_TICKS = 6

local function find_nearest_interactable(model, object)
	local dist = nil
	local obj_uid = nil

	for other_uid, other_object in pairs(model.objects) do
		local ndist = distance(object.position, other_object.position)
		if other_object.interaction_points then
			for _, point in pairs(other_object.interaction_points) do
				ndist = math.min(ndist, distance(object.position, other_object.position + point))
			end
		end
		if other_object.npc_interactable and other_object.owner_uid == nil and (dist == nil or ndist < dist) and ndist <= INTERACTION_RADIUS and object ~= other_object then
			dist = ndist
			obj_uid = other_uid
		end
	end
	return obj_uid
end

local function find_nearest_interactable_item(model, object, element_name)
	local dist = nil
	local obj_uid = nil

	for other_uid, other_object in pairs(model.objects) do
		local ndist = distance(object.position, other_object.position)
		if other_object.interactable and other_object.type == objects.TYPES.ITEM and other_object.name == element_name and other_object.owner_uid == nil and other_object.npc_dropped == nil and (dist == nil or ndist < dist) and ndist <= INTERACTION_RADIUS then
			dist = ndist
			obj_uid = other_uid
		end
	end
	return obj_uid
end

local function update_nearest(uid, model)
	local self = model.objects[uid]
	self.nearest_interactable = find_nearest_interactable(model, self)
end

--=========================SPINE ANIMATIONS PROCESSING=========================
--setting up spine animations depends on movespeed
--=============================================================================
local ANIMATION_LIST = {
	IDLE = 0,
	WALK = 1,
	SIT = 2,
	HAPPY_WALK = 3,
	SPAWN = 4,
	OUT =5,
}

local cur_animations = {}

--play animation
local function play_animation(uid, animation)
	if not view_data.instances[uid] then
		return
	end
	
	if cur_animations[uid] and cur_animations[uid] == animation then
		return
	end
	cur_animations[uid] = animation 
	if animation == ANIMATION_LIST.SPAWN then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "spawn",  go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1})

	elseif animation == ANIMATION_LIST.OUT then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "out", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)

	elseif animation == ANIMATION_LIST.IDLE then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "idle", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	
	elseif animation == ANIMATION_LIST.WALK then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "walk", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	
	elseif animation == ANIMATION_LIST.SIT then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "seat_idle_2", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	
	elseif animation == ANIMATION_LIST.HAPPY_WALK then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "walkHappy", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	end
end


--decide what animation to play
local function animate(object, modified_object)
	if object.hold then 
		play_animation(object.uid, ANIMATION_LIST.SPAWN)
	elseif object.die then 
		play_animation(object.uid, ANIMATION_LIST.OUT)
	elseif object.position ~= modified_object.position then
		if object.happy then
			play_animation(object.uid, ANIMATION_LIST.HAPPY_WALK)
		else
			play_animation(object.uid, ANIMATION_LIST.WALK)
		end
	elseif object.health and object.health <= 0 then
		play_animation(object.uid, ANIMATION_LIST.SIT)
	else
		play_animation(object.uid, ANIMATION_LIST.IDLE)
	end
	if object.position.x < modified_object.position.x then
		zoom.set_flipped(msg.url("main", view_data.instances[object.uid], ""), false)
	elseif object.position.x > modified_object.position.x then
		zoom.set_flipped(msg.url("main", view_data.instances[object.uid], ""), true)
	end

end
--=========================ANIMATIONS PROCESSING=========================
-----------------------------------------------------------------------


--=========================CREATE VIEW====================================
-- creating a new view representation of player object
-- setting up spine visual (attachments, and skins)
--=====================================================================
function M.new_view(object)
	local uid = object.uid
	if not uid then
		return
	end
	
	local view_object = factory.create(object.factory)
	object.handle = view_object

	if object.fake then
		go.set(msg.url("main", view_object, "sprite"), "tint.w", 0.5)
		return view_object, nil
	end

	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 200, 20), view_object)
	view_progress_bar.set_progress_bar(id, 1)
	view_data.info[object.uid].progress_id = id
	
	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "spinemodel"))
	if object.owner_id == data.player_id then
		zoom.set_camera_target(view_object)
	end
	go.set_position(object.position, view_object)

	if visual_settings.enable_animation then
		--spawn_fx = particlefx.play(msg.url("main", view_object, "spawn_fx"))
	else
		--spawn_fx = particlefx.play(msg.url("main", view_object, "spawn_fx"))
	end

	view_data.info[uid].arrow = factory.create("/root#arrow_go")
	msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
	msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
	go.set(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "tint", vmath.vector4(0, 0, 0, 0.5))
	-- go.set_parent(view_data.info[uid].arrow, view_object)
	return view_object, nil
end
--=========================CREATE VIEW====================================
-----------------------------------------------------------------------	

--=========================INTERPOLATION=================================
-- called from view
-- playing anumations
-- setting up visual position
--=====================================================================

function M.update_interpolate(uid, model1, model2, progress)
	if view_data.info[uid].visible  == false then
		return
	end
	
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	local v1 = object.position
	local v2 = object_new.position
	local vc = vmath.lerp(progress, v1, v2)

	if object.fake then
		zoom.remove_object(msg.url("main", view_data.instances[uid], ""))
		local direction = v2 - v1
		go.set_position(vc, view_data.instances[uid])
		local rotation = math.atan2(direction.z, direction.x)
		go.set_rotation(vmath.quat_rotation_x(-math.pi / 2) * vmath.quat_rotation_z(math.pi / 2 - rotation), view_data.instances[uid])
		if model2.wave and model2.wave_status ~= 3 then 
			msg.post(msg.url("main", view_data.instances[uid], "sprite"), "disable")
		else
			msg.post(msg.url("main", view_data.instances[uid], "sprite"), "enable")
		end
		return
	end

	local player_interact_progress = object.player_interact_progress * (1 - progress) + object_new.player_interact_progress * progress

	view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, player_interact_progress)




	local color = vmath.vector4(visual_settings.bg_color_r / 256, visual_settings.bg_color_g / 256, visual_settings.bg_color_b / 256, 1)
	local white = vmath.vector4(1)

	local lb = -1024 - vc.x
	local rb = vc.x - 1920
	local tb = -768 - vc.z
	local bb = vc.z - 640
	local v_p = math.max(tb, bb, 0) / (128 * 4)
	local h_p = math.max(lb, rb, 0) / (128 * 4)
	local power = math.sqrt(v_p * v_p + h_p * h_p)

	local tint = power * color + (1 - power) * white
	
	-- local hit_indicator = (object.hit_indicator * (1 - progress) + object_new.hit_indicator * progress) / HIT_INDICATOR_TICKS
	-- local hit_tint_power = 1 - hit_indicator / 2
	-- local tint = vmath.vector4(1, hit_tint_power, hit_tint_power, 1)
	go.set(msg.url("main", view_data.instances[uid], "sprite"), "tint", tint)
	go.set(msg.url("main", view_data.instances[uid], "spinemodel"), "tint", tint)

	if object_new.item_uid ~= nil and object.item_uid ~= object_new.item_uid and view_data.instances[object_new.item_uid] then
		view_utils.interpolate_item_parent(view_data.instances[object_new.item_uid], M.get_attach_go(uid, model1, view_data.instances), model2.objects[object_new.item_uid].position, progress)
	elseif object.item_uid and object_new.item_uid == object.item_uid and view_data.instances[object.item_uid] then
		local id = view_data.instances[object.item_uid]
		go.set_parent(view_data.instances[object.item_uid], M.get_attach_go(uid, model1, view_data.instances))
		
		local rotation = vmath.quat()
		local position = vmath.vector3(model1.objects[object.item_uid].position)
		if zoom.is_flipped(msg.url("main", view_data.instances[uid], "")) then
			rotation = vmath.quat_rotation_y(math.pi)
			position.z = - position.z
		end
		go.set_position(position, id)
		go.set_rotation(rotation, id)
	end

	if visual_settings.enable_animation then
		local item_uid = object.item_uid 

		if item_uid then
			if view_data.info[item_uid] and view_data.info[item_uid].owner_uid ~= uid then
				if view_data.info[item_uid].is_animated then
					go.cancel_animations(view_data.instances[item_uid])
					go.set_parent(view_data.instances[item_uid], M.get_attach_go(uid, model1, view_data.instances))
					
				end
				local position = vmath.vector3(model1.objects[object.item_uid].position)
				if not zoom.is_flipped(msg.url("main", view_data.instances[uid], "")) then
					position.z = -position.z
				end
				go.set_position(vmath.vector3(0, 50, 0) + position, view_data.instances[item_uid])
				view_data.info[item_uid].owner_uid = uid
				view_data.info[item_uid].is_animated = true
				go.animate(view_data.instances[item_uid], "position", go.PLAYBACK_ONCE_FORWARD, position, go.EASING_INBACK, 0.5, 0, function()
					view_data.info[item_uid].is_animated = false
				end)
			end
		end
	end

	animate(object, object_new)
	go.set_position(vc, view_data.instances[uid])

	local wanted_item_icon = "element_" .. (model1.objects[uid].execution_context.icon_name or model1.objects[uid].execution_context.wanted_item or "none")

	if view_data.info[uid].wanted_item_set ~= wanted_item_icon then
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "sprite"), wanted_item_icon)
		view_data.info[uid].wanted_item_set = wanted_item_icon
	end
	-- label.set_text(msg.url("main", view_data.instances[uid], "debug_label"), model1.objects[uid].execution_context.state)

	-- set settings update mode
	if object.open_miner_settings_menu and view_data.info[uid].opened_miner_settings_menu ~= true and model1.player_object_uids[data.player_id] and object.interact_requested_from == model1.player_object_uids[data.player_id] and data.are_actions_local == true then
		msg.post("root#main_menu", hash("show_miner_settings"), {uid = uid, location_id = model1.id, steps = object.steps})
		zoom.set_camera_target(view_data.instances[uid])
		view_data.info[uid].opened_miner_settings_menu = true
		view_data.info[uid].prev_target = zoom.get_zoom_target()
		zoom.set_zoom_target(200)
	end
	--check if we are still in reach
	if object.open_miner_settings_menu and view_data.info[uid].opened_miner_settings_menu and model1.player_object_uids[data.player_id] and object.interact_requested_from == model1.player_object_uids[data.player_id] and data.are_actions_local == true then
		local p_uid = model1.player_object_uids[data.player_id] 
		if model1.objects[p_uid].nearest_interactable ~= uid and view_data.info[uid].requested_close == nil then
			msg.post("root#main_menu", hash("close_miner_settings"))
			view_data.info[uid].requested_close = true
		end
	end
	-- close settings update mode
	if not object.open_miner_settings_menu and view_data.info[uid].opened_miner_settings_menu == true then
		zoom.set_camera_target(view_data.instances[model1.player_object_uids[data.player_id]])
		view_data.info[uid].opened_miner_settings_menu = nil
		zoom.set_zoom_target(view_data.info[uid].prev_target)
		object.interact_requested_from = nil
		view_data.info[uid].prev_target = nil
		view_data.info[uid].requested_close = nil
	end
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------


--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of player object
--=====================================================================

local function move_interact(p_uid, model, uid)
	local nearest = model.objects[uid]
	if not nearest then
		return
	end
	local nearest_handler = nearest and router(nearest.type) or nil
	if nearest_handler and nearest_handler.player_move_interact then
		nearest_handler.player_move_interact(uid, model, p_uid)
		return true
	else
		return false
	end
end

function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.NPC_INTERACT then
		local p_uid = action.player_id
		local player = model.objects[p_uid]
		local nearest_uid = player.nearest_interactable
		local nearest = model.objects[nearest_uid]


		local nearest_handler = nearest and router(nearest.type) or nil

		local item_uid = M.try_remove_item(p_uid, model)
		if item_uid then
			local item = model.objects[item_uid]
			if nearest and nearest.is_storage and nearest_handler.is_empty(nearest_uid, model) then
				if nearest_handler.npc_insert_item then
					nearest_handler.npc_insert_item(nearest_uid, model, item_uid, p_uid)
				else
					M.try_insert_item(p_uid, model, item_uid)
				end
			end
		else
			if nearest and nearest.is_storage and nearest_handler.npc_remove_item then
				item_uid = nearest_handler.npc_remove_item(nearest_uid, model)
				if item_uid then
					M.try_insert_item(p_uid, model, item_uid)
				end
			end
		end
	elseif action.type == actions.ACTION_TYPE.NPC_DROP_ITEM then
		local item_uid = M.try_remove_item(action.uid, model)
		local item = model.objects[item_uid]
		item.npc_dropped = true
	elseif action.type == actions.ACTION_TYPE.NPC_PICK_ITEM then
		local uid = action.uid
		local object = model.objects[uid]
		local nearest_uid = find_nearest_interactable_item(model, object, action.element_name)
		local nearest = model.objects[nearest_uid]
		if nearest and nearest.interactable and nearest.type == objects.TYPES.ITEM then
			M.try_insert_item(uid, model, nearest_uid)
		end
		
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		if not self.player_interacted then
			self.player_interact_progress = 0
		end
		self.player_interacted = nil
		self.hit_indicator = math.max(0, self.hit_indicator - 1)
	elseif action.type == actions.ACTION_TYPE.MOVE_OBJECT then
		if not model.objects[action.uid] then
			return
		end

		local new_x = model.objects[action.uid].position.x + action.delta.x
		local new_y = model.objects[action.uid].position.y + action.delta.y
		local new_z = model.objects[action.uid].position.z + action.delta.z

-- 		if collision_manager.get_collision(model.objects[action.uid].position.x, model.objects[action.uid].position.z, model) then
-- 			 if move_interact(action.uid, model, collision_manager.get_collision(model.objects[action.uid].position.x, model.objects[action.uid].position.z, model)) then
-- 				return
-- 			end
-- 		end
-- 
-- 		if not collision_manager.get_collision(model.objects[action.uid].position.x, model.objects[action.uid].position.z, model) and collision_manager.get_collision(new_x, new_z, model) then
-- 			if move_interact(action.uid, model, collision_manager.get_collision(new_x, new_z, model)) then
-- 				return
-- 			end
-- 			if not collision_manager.get_collision(new_x, model.objects[action.uid].position.z, model) then
-- 				new_x = model.objects[action.uid].position.x + action.delta.x
-- 			else
-- 				new_x = model.objects[action.uid].position.x
-- 			end
-- 			if not collision_manager.get_collision(model.objects[action.uid].position.x, new_z, model) then
-- 				new_z = model.objects[action.uid].position.z + action.delta.z
-- 			else
-- 				new_z = model.objects[action.uid].position.z
-- 			end
-- 
-- 			if collision_manager.get_collision(new_x, new_z, model) then
-- 				return
-- 			end
-- 		end


		model.objects[action.uid].position.x = new_x
		model.objects[action.uid].position.y = new_y
		model.objects[action.uid].position.z = new_z

		update_nearest(action.uid, model)
	elseif action.type == actions.ACTION_TYPE.UPDATE_MINER_SETTINGS then
		local self = model.objects[action.uid]
		self.steps = action.steps
		-- self.target_1_element_name = action.settings.target_1_element_name
		-- self.target_2_type = action.settings.target_2_type
		model.block_interact[self.interact_requested_from] = nil
		self.open_miner_settings_menu = nil
	elseif action.type == actions.ACTION_TYPE.DESTROY_OBJECT then
		M.destroy(action.uid, model)
	end

end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------	

--=========================SPAWN=========================================
-- creating a new player object in data-model
--=====================================================================	
function M.spawn(model, position, type, factory, skin_id, params)
	factory = factory or "/root#buyer_factory"
	local uid = mm.create_object(model, factory, position)
	local self = model.objects[uid]
	self.is_player = false
	self.item_uid = nil
	self.nearest_interactable = nil
	self.stack = stack.create()
	self.npc_type = type
	self.execution_context = {spawn_position = position}
	self.vanted_sprite = "element_none"
	self.type = objects.TYPES.NPC
	self.skin_id = skin_id
	self.interactable = params.interactable
	self.drop_item = params.drop_item
	self.player_interact_progress = 0
	self.max_health = params.max_health
	self.health = params.max_health
	self.speed = params.speed or 0.5
	self.reward = params.reward
	self.hit_indicator = 0
	self.fake = params.fake
	self.steps = params.steps
	self.hold = true
	self.die = false
	self.uid = uid
	return uid
end
--=========================SPAWN=========================================
-------------------------------------------------------------------------


--=======================DESTROY=========================================
-- destroying a player object in data-model
--=======================================================================
function M.destroy(uid, model)
	local object = model.objects[uid]

	if object.item_uid then
		mm.delete_object(model, object.item_uid)
	end
	mm.delete_object(model, uid)
end
--=======================DESTROY=========================================
-------------------------------------------------------------------------

local function hit(uid, model, is_player) --owful crutch
	local self = model.objects[uid]
	if is_player then
		self.health = self.health - 0.5
	else
		self.health = self.health - 1
	end
	if self.health == 0 and not is_player and self.drop_item then
		item_object.spawn(model, vmath.vector3(self.position), self.drop_item)
	end
	if self.health == 0 then
		self.interactable = false
	end
	self.hit_indicator = HIT_INDICATOR_TICKS
end

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return self.item_uid == nil
end

function M.try_insert_item(uid, model, item_uid)
	local result = item_slot_object.try_insert_item(uid, model, item_uid)
	local item = model.objects[item_uid]
	item.position = vmath.vector3(0, 0, 10)
	return result
end

function M.try_remove_item(uid, model)
	local self = model.objects[uid]
	local result = item_slot_object.try_remove_item(uid, model)
	if result then
		local item = model.objects[result]
		item.position = self.position + vmath.vector3(0, 0, 10)
	end
	return result
end

function M.player_interact(uid, model, player_uid)
	local self = model.objects[uid]
	if not self.interact_requested_from then
		self.player_interacted = true
		self.player_interact_progress = math.min(1, self.player_interact_progress + 0.1)
		if self.player_interact_progress >= 1 then
			self.interact_requested_from = player_uid
			self.player_interact_progress = 0
			-- hit(uid, model, true)
		end
	end
end

function M.player_hit(uid, model)
	hit(uid, model, true)
end

function M.guard_interact(uid, model)
	hit(uid, model)
end

function M.get_attach_go(uid, model, instances)
	if zoom.is_flipped(msg.url("main", instances[uid], "")) then
		return spine.get_go(msg.url("main", instances[uid], "spinemodel"), "element_2")
	else
		return spine.get_go(msg.url("main", instances[uid], "spinemodel"), "element_1")
	end
end

return M