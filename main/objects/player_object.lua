local mm = require "main.sys.model"
local settings = require "main.settings"
local objects = require "main.objects.objects"
local pack = require "utils.pack"
local view_data = require "main.view.view_data"
local lights = require "main.lights"
local data = require "main.data"
local zoom = require "main.zoom"
local actions = require "main.sys.actions"
local collision_manager = require "main.collision_manager.collision_manager"
local view_utils = require "main.view.view_utils"
local stack = require "main.objects.stack"
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
local foundation_object = require "main.objects.foundation_object"
local trashcan_object = require "main.objects.trashcan_object"
local npc_object = require "main.npc.npc_object"
local guard_object = require "main.objects.guard_object"
local coin_object = require "main.objects.coin_object"
local next_wave_zone = require "main.objects.next_wave_zone"
local diggable_tile_object = require "main.objects.diggable_tile_object"
local point_object = require "main.objects.point_object"

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
	elseif type == objects.TYPES.FOUNDATION then
		return foundation_object
	elseif type == objects.TYPES.TRASHCAN then
		return trashcan_object
	elseif type == objects.TYPES.NPC then
		return npc_object
	elseif type == objects.TYPES.GUARD then
		return guard_object
	elseif type == objects.TYPES.COIN then
		return coin_object
	elseif type == objects.TYPES.ZONE then
		return next_wave_zone
	elseif type == objects.TYPES.DIGGABLE_TILE then
		return diggable_tile_object
	elseif type == objects.TYPES.POINT then
		return point_object
	end
end

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

	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "spinemodel"))

	spawn_fx = particlefx.play(msg.url("main", view_object, "spawn_fx"))

	view_data.info[uid].arrow = factory.create("/root#arrow_go")
	msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
	msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
	go.set(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "tint", vmath.vector4(0, 0, 0, 0.5))
	-- go.set_parent(view_data.info[uid].arrow, view_object)


	if object.owner_id == data.player_id then
		zoom.set_camera_target(view_object)
	end
	
	return view_object, nil
end
--=========================CREATE VIEW====================================
-----------------------------------------------------------------------	

--=========================INTERPOLATION=================================
-- called from view
-- playing anumations
-- setting up visual position
--=====================================================================

--=========================SPINE ANIMATIONS PROCESSING=========================
--setting up spine animations depends on movespeed
--=============================================================================
local ANIMATION_LIST = {
	IDLE = 0,
	WALK = 1,
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
	if animation == ANIMATION_LIST.WALK then
		spine.play_anim(msg.url("main", view_data.instances[uid], "spinemodel"), "walk", go.PLAYBACK_LOOP_FORWARD, {blend_duration = 0.1}, nil)
	end
end


--decide what animation to play
local function animate(object, modified_object)
	if object.position ~= modified_object.position then
		play_animation(object.uid, ANIMATION_LIST.WALK)
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

--TODO: move to utils
local function distance(pos1, pos2)
	return math.sqrt(math.pow((pos1.x - pos2.x) / settings.player_speed_x, 2) + math.pow((pos1.z - pos2.z) / settings.player_speed_y, 2))
end

local INTERACTION_RADIUS = 6

--TODO: move to utils
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
		if other_object.interactable and other_object.owner_uid == nil and (dist == nil or ndist < dist) and ndist <= INTERACTION_RADIUS then
			dist = ndist
			obj_uid = other_uid
		end
	end
	return obj_uid
end

local function find_next_target(model, object)
	local min_index = nil
	local obj_uid = nil

	for other_uid, other_object in pairs(model.objects) do
		if other_object.type == objects.TYPES.FOUNDATION then
			if (min_index == nil or min_index > other_object.foundation_index) and settings.foundation_hints >= other_object.foundation_index then
				min_index = other_object.foundation_index
				obj_uid = other_uid
			end
		end
	end
	return obj_uid
end

local function remove_highlight(uid, model, player_uid)
	if uid and view_data.instances[uid] then
		lights.update_highlight_power(view_data.instances[uid], nil)
	end
end

local function add_highlight(uid, model, player_uid)
	if uid and view_data.instances[uid] then
		lights.update_highlight_power(view_data.instances[uid], 1)
	end
end

local function update_highlighted(uid, model, player_uid)
	remove_highlight(view_data.highlighted_uid, model, player_uid)
	view_data.highlighted_uid = uid
	add_highlight(view_data.highlighted_uid, model, player_uid)
end

function M.update_interpolate(uid, model1, model2, progress)
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	local v1 = object.position
	local v2 = object_new.position
	local vc = vmath.lerp(progress, v1, v2)

	if object.owner_id == data.player_id then
		-- zoom.set_camera_target(view_data.instances[uid])
		update_highlighted(object.nearest_interactable, model1, uid)

		local dir_v = v2 - v1
		dir_v.x = dir_v.x / settings.player_speed_x
		dir_v.z = dir_v.z / settings.player_speed_y
		
		-- zoom.set_zoom_progress_target(vmath.length(dir_v) * vmath.length(dir_v))
	end

	if object_new.item_uid ~= nil and object.item_uid ~= object_new.item_uid and view_data.instances[object_new.item_uid] then
		view_utils.interpolate_item_parent(view_data.instances[object_new.item_uid], M.get_attach_go(uid, model1, view_data.instances), model2.objects[object_new.item_uid].position, progress)
	elseif object.item_uid and object_new.item_uid == object.item_uid and view_data.instances[object.item_uid] then
		local id = view_data.instances[object.item_uid]
		go.set_parent(view_data.instances[object.item_uid], M.get_attach_go(uid, model1, view_data.instances))
		go.set_position(model1.objects[object.item_uid].position, id)
		go.set_rotation(vmath.quat(), id)
	end
	
	animate(object, object_new)
	go.set_position(vc, view_data.instances[uid])

	if object.type == objects.TYPES.PLAYER then
		local next_target_uid = find_next_target(model2, object)
		local next_target = model2.objects[next_target_uid]
		if next_target and next_target.cost <= model2.money then
			local BASE_DIST = 200
			local DELTA_DIST = 20
			local APPROACH_DELTA = 200
			local CYCLE_TICKS = 100
			
			local target_pos = next_target.position
			local direction = target_pos - vc
			local dist = vmath.length(direction)
			if dist > BASE_DIST + DELTA_DIST + APPROACH_DELTA then
				local rotation = math.atan2(direction.z, direction.x)
				direction = direction / dist
				local arrow_power = BASE_DIST + DELTA_DIST * math.sin(model2.tick * 2 * math.pi / CYCLE_TICKS)
				direction = direction * arrow_power
				go.set_position(vc + direction, view_data.info[uid].arrow)
				msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "enable")
				msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "enable")
				go.set_rotation(vmath.quat_rotation_x(-math.pi / 2) * vmath.quat_rotation_z(math.pi / 2 - rotation), view_data.info[uid].arrow)
			else
				msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
				msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
			end
		else
			msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
			msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
		end
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
		local rotation = nil

		if zoom.is_flipped(msg.url("main", view_data.instances[uid], "")) then
			rotation = vmath.quat_rotation_y(math.pi)
		end

		stack.update_view(model2.objects[uid].stack, model2.objects[uid].stack, M.get_attach_go(uid, model, view_data.instances), vmath.vector3(0, 0, 10), rotation)

		if visual_settings.enable_animation then
			local item_uids = stack.item_uids(model1.objects[uid].stack)
			for i, item_uid in ipairs(item_uids) do
				if view_data.info[item_uid] and view_data.info[item_uid].owner_uid ~= uid then
					local position = go.get_position(view_data.instances[item_uid])
					go.set_position(vmath.vector3(0, 50, 0) + position, view_data.instances[item_uid])
					view_data.info[item_uid].owner_uid = uid
					view_data.info[item_uid].is_animated = true
					go.animate(view_data.instances[item_uid], "position", go.PLAYBACK_ONCE_FORWARD, position, go.EASING_INBACK, 0.5, 0, function()
						view_data.info[item_uid].is_animated = false
					end)
				end
			end
		end
	end
	
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of player object
--=====================================================================
local function update_nearest(uid, model)
	local self = model.objects[uid]
	self.nearest_interactable = find_nearest_interactable(model, self)
end

local function interact(p_uid, model)
	local player = model.objects[p_uid]
	local nearest_uid = player.nearest_interactable
	local nearest = model.objects[nearest_uid]

	local nearest_handler = nearest and router(nearest.type) or nil

	if model.wave_status and model.wave_status == 3 then
		for uid, object in pairs(model.objects) do
			if object.type == objects.TYPES.COIN and object.interactable then
				coin_object.player_interact(uid, model, p_uid)
				break
			end
		end
	end

	-- local item_uid = M.try_remove_item(p_uid, model)
	local item_uids = M.get_item_uids(p_uid, model)
	for i, item_uid in ipairs(item_uids) do
		if nearest and nearest.is_storage and nearest_handler.try_insert_item then
			local inserted = nearest_handler.try_insert_item(nearest_uid, model, item_uid)
			if inserted then
				M.try_remove_item(p_uid, model, i)
			end
		end
	end


	if nearest and nearest.interactable and nearest_handler.player_interact then
		nearest_handler.player_interact(nearest_uid, model, p_uid)
	elseif nearest and nearest.interactable and nearest_handler.interact then
		nearest_handler.interact(nearest_uid, model)
	elseif not M.is_full(p_uid, model) then
		if nearest and nearest.is_pickable then -- TODO: Add remove handler to item (returning itself) and simplify this code
			M.try_insert_item(p_uid, model, nearest_uid)
		elseif nearest and nearest_handler.player_try_remove_item then
			local item_uid = nearest_handler.player_try_remove_item(nearest_uid, model, p_uid)
			if item_uid then
				M.try_insert_item(p_uid, model, item_uid)
			end
		elseif nearest and nearest.is_storage then
			local item_uid = nearest_handler.try_remove_item(nearest_uid, model)
			if item_uid then
				M.try_insert_item(p_uid, model, item_uid)
			end
		end
	end

	update_nearest(p_uid, model)
end

local function move_interact(p_uid, model, uid)
	local nearest = model.objects[uid]
	if not nearest then
		return
	end
	local nearest_handler = nearest and router(nearest.type) or nil
	if nearest_handler and nearest_handler.player_move_interact then
		nearest_handler.player_move_interact(uid, model, p_uid)
	end
end

function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		local p_uid = M.spawn(model, action.position, action.player_id)
		model.player_object_uids[action.player_id] = p_uid
	else
		if action.uid and model.objects[action.uid].archived then
			return
		end
	end
	if action.type == actions.ACTION_TYPE.TICK then
		if model.block_interact[action.uid] then
			return
		end
		interact(action.uid, model)
	elseif action.type == actions.ACTION_TYPE.MOVE_OBJECT then
		if not model.objects[action.uid] then
			return
		end
		-- if model.block_interact[action.uid] then
		-- 	return
		-- end

		local new_x = model.objects[action.uid].position.x + action.delta.x
		local new_y = model.objects[action.uid].position.y + action.delta.y
		local new_z = model.objects[action.uid].position.z + action.delta.z

		if not collision_manager.get_collision(model.objects[action.uid].position.x, model.objects[action.uid].position.z, model) and collision_manager.get_collision(new_x, new_z, model) then
			move_interact(action.uid, model, collision_manager.get_collision(new_x, new_z, model))
			if not collision_manager.get_collision(new_x, model.objects[action.uid].position.z, model) then
				new_x = model.objects[action.uid].position.x + action.delta.x
			else
				new_x = model.objects[action.uid].position.x
			end
			if not collision_manager.get_collision(model.objects[action.uid].position.x, new_z, model) then
				new_z = model.objects[action.uid].position.z + action.delta.z
			else
				new_z = model.objects[action.uid].position.z
			end

			if collision_manager.get_collision(new_x, new_z, model) then
				return
			end
		end


		model.objects[action.uid].position.x = new_x
		model.objects[action.uid].position.y = new_y
		model.objects[action.uid].position.z = new_z

		update_nearest(action.uid, model)
	elseif action.type == actions.ACTION_TYPE.INTERACT  then
		if not (model.player_object_uids[action.player_id] or model.objects[action.player_id].type == objects.TYPES.NPC) then -- TODO: separate player and NPC logic
			return
		end
		local p_uid = model.player_object_uids[action.player_id] or action.player_id -- TODO: separate player and NPC logic
		interact(p_uid, model)
		
	elseif action.type == actions.ACTION_TYPE.DESTROY_OBJECT then
		M.destroy(action.pid, model)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------	

--=========================SPAWN=========================================
-- creating a new player object in data-model
--=====================================================================	
function M.spawn(model, position, player_id, player_factory)
	if model.player_object_uids[player_id] then
		model.objects[model.player_object_uids[player_id]].archived = false
		model.objects[model.player_object_uids[player_id]].position = position
		return model.player_object_uids[player_id]
	end
	player_factory = player_factory or "/root#player_factory" -- TODO: move it to abstract file
	local uid = mm.create_object(model, player_factory, position)
	local self = model.objects[uid]
	self.type = objects.TYPES.PLAYER
	self.is_player = true
	self.owner_id = player_id
	self.item_uid = nil
	self.nearest_interactable = nil
	self.stack = stack.create()

	if player_id ~= "BUYER" or player_id ~= "THIEF" then -- TODO: move it to abstract file
		self.skin_id = model.player_object_next_skin + 1
		model.player_object_next_skin = (model.player_object_next_skin + 1) % 11
	else
		self.skin_id = 7
	end
	self.uid = uid
	return uid
end
--=========================SPAWN=========================================
-------------------------------------------------------------------------


--=======================DESTROY=========================================
-- destroying a player object in data-model
--=======================================================================
function M.destroy(pid, model)
	--print("destroy: ", pid)
	local uid = model.player_object_uids[pid]
	-- model.player_object_uids[pid] = nil
	local object = model.objects[uid]

	object.archived = true
	object.position = vmath.vector3(-10000, 0, 0)

-- 	local item_uid = 123
-- 	while item_uid do
-- 		item_uid = stack.remove(object.stack)
-- 		print("item_delete: ", item_uid)
-- 		if item_uid then
-- 			mm.delete_object(model, item_uid)
-- 			--TODO translate it to sub
-- 		end
-- 	end
-- 
-- 
-- 	if object and object.item_uid then
-- 		mm.delete_object(model, object.item_uid)
-- 	end
-- 	if uid then
-- 		mm.delete_object(model, uid)
-- 	end
end

--=======================DESTROY=========================================
-------------------------------------------------------------------------

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
	if stack.is_full(self.stack) then
		return false
	end
	stack.insert(self.stack, item_uid)
	local item = model.objects[item_uid]
	item.owner_uid = uid
	return true
end

function M.get_item_uids(uid, model)
	local self = model.objects[uid]
	return stack.item_uids(self.stack)
end

function M.try_remove_item(uid, model, index)
	local self = model.objects[uid]
	return stack.remove(self.stack, index)
end

function M.get_attach_go(uid, model, instances)
	-- return instances[uid]
	if zoom.is_flipped(msg.url("main", instances[uid], "")) then
		return spine.get_go(msg.url("main", instances[uid], "spinemodel"), "element_2")
	else
		return spine.get_go(msg.url("main", instances[uid], "spinemodel"), "element_1")
	end
	-- return spine.get_go(msg.url("main", instances[uid], "spinemodel"), "energypanel")
end

return M