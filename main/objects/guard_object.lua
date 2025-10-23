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
local settings = require "main.settings"
local npc_object = require "main.npc.npc_object"
local stack = require "main.objects.stack"
local view_progress_bar = require "main.view.view_progress_bar"
local item_object = require "main.objects.item_object"

local M = {}

local function distance(pos1, pos2)
	return math.sqrt(math.pow((pos1.x - pos2.x) / settings.player_speed_x, 2) + math.pow((pos1.z - pos2.z) / settings.player_speed_y, 2))
end

local DEFAULT_INTERACTION_RADIUS = 100
local AIM_TICKS = 20
local SHOOT_TICKS = 5
local RELOAD_TICKS = 5

local PROJECTILE_POS = vmath.vector3(0, 190, 5)
local PROJECTILE_SCALE = vmath.vector3(0.6, 0.6, 1)
local PROJECTILE_POS_FLOOR = vmath.vector3(0, 0, 5)

local function find_nearest_thief(model, object)
	local dist = nil
	local obj_uid = nil

	for other_uid, other_object in pairs(model.objects) do
		local ndist = distance(object.position, other_object.position)
		if other_object.interaction_points then
			for _, point in pairs(other_object.interaction_points) do
				ndist = math.min(ndist, distance(object.position, other_object.position + point))
			end
		end
		if other_object.type == objects.TYPES.NPC and (other_object.npc_type == "ENEMY" or other_object.npc_type == "THIEF") and other_object.health > 0 and (dist == nil or ndist < dist) and ndist <= object.guard_radius then
			dist = ndist
			obj_uid = other_uid
		end
	end
	return obj_uid
end


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

	-- if object.sprite_left then
	-- 	sprite.play_flipbook(msg.url("main", view_object, "sprite_left"), object.sprite_left)
	-- end
	-- 
	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "sprite"), nil)

	view_data.info[uid].arrow = factory.create("/root#arrow_go")
	msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
	msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
	go.set(msg.url("main", view_data.info[uid].arrow, "sprite"), "tint", vmath.vector4(1, 0, 0, 0.5))
	go.set(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "tint", vmath.vector4(0, 0, 0, 0.5))
	
	view_data.info[uid].radius = factory.create("/root#radius_go")
	sprite.play_flipbook(msg.url("main", view_data.info[uid].radius, "sprite"), "radius")
	go.set(msg.url("main", view_data.info[uid].radius, "sprite"), "size.x", object.guard_radius * settings.player_speed_x * 2)
	go.set(msg.url("main", view_data.info[uid].radius, "sprite"), "size.y", object.guard_radius * settings.player_speed_y * 2)
	msg.post(msg.url("main", view_data.info[uid].radius, "sprite"), "disable")
	go.set_position(object.position + PROJECTILE_POS_FLOOR, view_data.info[uid].radius)
	go.set_rotation(vmath.quat_rotation_x(-math.pi / 2), view_data.info[uid].radius)
	
	sprite.set_constant(msg.url("main", view_object, "hint"), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "hint1"), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "hint2"), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "hint3"), "tint", vmath.vector4(1, 1, 1, 0.3))
	sprite.set_constant(msg.url("main", view_object, "hint4"), "tint", vmath.vector4(1, 1, 1, 0.3))

	sprite.set_constant(msg.url("main", view_object, "shine"), "tint", vmath.vector4(1, 1, 1, 0))
	-- go.animate(msg.url("main", view_object, "shine"), "tint.w", go.PLAYBACK_LOOP_PINGPONG, 0.8, go.EASING_INSINE, 2)

	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 300, 20), view_object)
	view_progress_bar.set_progress_bar(id, 0)
	view_data.info[object.uid].progress_id = id
	
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

	local v1 = object.position
	local v2 = object_new.position
	local vc = vmath.lerp(progress, v1, v2)

	local stack_offset = vmath.vector3(-48, 240, 5)
	
	stack.update_view(object.stack, object_new.stack, M.get_attach_go(uid, model, view_data.instances), stack_offset)

	-- local reload_progress = ((1 - progress) * object.reload + progress * object_new.reload) / RELOAD_TICKS
	-- view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, reload_progress)

	if view_data.highlighted_uid == uid then
		msg.post(msg.url("main", view_data.info[uid].radius, "sprite"), "enable")
	else
		msg.post(msg.url("main", view_data.info[uid].radius, "sprite"), "disable")
	end

	if not object.projectile_uid then
		if view_data.info[uid].fx then
			particlefx.stop(msg.url("main", view_data.info[uid].fx, "sparks_round_small"))
			go.delete(view_data.info[uid].fx)
			view_data.info[uid].fx = nil
		end
	end

	local load = #stack.item_uids(object_new.stack)

	if object.projectile_uid ~= nil then
		load = load + 1
	end
	
	sprite.set_constant(msg.url("main", view_data.instances[uid], "shine"), "tint", vmath.vector4(1, 1, 1, load / 5))
	if load == 5 then
		if not view_data.info[uid].fx2 then
			view_data.info[uid].fx2 = msg.url("main", view_data.instances[uid], "sparks_highlight")
			particlefx.play(view_data.info[uid].fx2)
		end
	else
		if view_data.info[uid].fx2 then
			particlefx.stop(view_data.info[uid].fx2)
			view_data.info[uid].fx2 = nil
		end
	end

	if object.shoot > 0 and object_new.shoot > 0 then
		local target = model2.objects[object.projectile_target_uid]
		if not target then
			return
		end
		local target_pos = target.position

		local shoot_progress = 1 - (object.shoot * (1 - progress) + object_new.shoot * progress) / SHOOT_TICKS
		local position = (vc + PROJECTILE_POS) * (1 - shoot_progress) + target_pos * shoot_progress
		local projectile = view_data.instances[object.projectile_uid]
		if not view_data.info[uid].fx then
			view_data.info[uid].fx = factory.create("/root#fx_container_go")
			go.set_parent(view_data.info[uid].fx, projectile)
			go.set_scale(vmath.vector3(2, 2, 1), view_data.info[uid].fx)
			go.set_position(vmath.vector3(0, 50, 1), view_data.info[uid].fx)
			particlefx.play(msg.url("main", view_data.info[uid].fx, "sparks_round_small"))
		end
		go.set_parent(projectile, nil)
		go.set_position(position, projectile)
		go.set_scale(PROJECTILE_SCALE, projectile)
		zoom.register_object(msg.url(projectile))
	elseif object.projectile_uid then
		local projectile = view_data.instances[object.projectile_uid]
		if projectile and go.exists(projectile) then
			go.set_parent(projectile, view_data.instances[uid])
			go.set_position(PROJECTILE_POS, projectile)
			go.set_scale(PROJECTILE_SCALE, projectile)
			go.set_rotation(vmath.quat(), projectile)
		end
	end
	
	if object_new.target_uid and model2.objects[object.target_uid] and object.aim and object_new.aim then
		local target = model2.objects[object.target_uid]

		local target_pos = target.position
		local direction = target_pos - (vc + PROJECTILE_POS_FLOOR)
		local X_MAX_SIZE = 72
		local X_MIN_SIZE = 2
		
		local aim_progress = 1 - (object.aim * (1 - progress) + object_new.aim * progress) / AIM_TICKS
		-- local x_size = X_MIN_SIZE + (X_MAX_SIZE - X_MIN_SIZE) * aim_progress

		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, aim_progress)
		
		local rotation = math.atan2(direction.z, direction.x)
		go.set(msg.url("main", view_data.info[uid].arrow, "sprite"), "size.y", vmath.length(direction))
		go.set(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "size.y", vmath.length(direction))
		go.set(msg.url("main", view_data.info[uid].arrow, "sprite"), "size.x", 10)
		go.set(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "size.x", 10)
		direction = direction / 2
		go.set_position(vc + direction + PROJECTILE_POS_FLOOR, view_data.info[uid].arrow)
		msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "enable")
		msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "enable")
		go.set_rotation(vmath.quat_rotation_x(-math.pi / 2) * vmath.quat_rotation_z(-math.pi / 2 - rotation), view_data.info[uid].arrow)
	else
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, 0)
		msg.post(msg.url("main", view_data.info[uid].arrow, "sprite"), "disable")
		msg.post(msg.url("main", view_data.info[uid].arrow, "shadow_sprite"), "disable")
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

		if self.shoot > 0 then
			self.shoot = self.shoot - 1
			if self.shoot == 0 then
				if self.projectile_uid then
					mm.delete_object(model, self.projectile_uid)
					self.projectile_uid = nil
				end
				if self.projectile_target_uid and model.objects[self.projectile_target_uid] then
					npc_object.guard_interact(self.projectile_target_uid, model)
					self.projectile_target_uid = nil
				end
			end
		end

		if self.reload > 0 then
			self.reload = self.reload - 1
			self.aim = AIM_TICKS
			return
		end

		if self.projectile_uid == nil then
			if stack.is_empty(self.stack) then
				self.aim = AIM_TICKS
				self.target_uid = nil
				return
			else
				self.projectile_uid = stack.remove(self.stack, 1)
				local projectile_obj = model.objects[self.projectile_uid]
				projectile_obj.position = vmath.vector3(PROJECTILE_POS)
			end
		end

		local target = nil
		if not model.objects[self.target_uid] or distance(self.position, model.objects[self.target_uid].position) > self.guard_radius then
			target = find_nearest_thief(model, self)
		else
			target = self.target_uid
		end

		if target == nil then
			self.aim = AIM_TICKS
			self.target_uid = nil
			return
		end
		
		if self.target_uid ~= target then
			self.target_uid = target
			self.aim = AIM_TICKS
		end
		
		self.aim = self.aim - 1
		
		if self.aim <= 0 then
			self.aim = AIM_TICKS
			self.projectile_target_uid = self.target_uid
			self.target_uid = nil
			self.shoot = SHOOT_TICKS
			self.reload = RELOAD_TICKS
		end
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, guard_radius)
	local uid = mm.create_object(model, "root#double_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	self.sprite = "tower"
	self.sprite_left = "counter"
	self.type = objects.TYPES.GUARD
	self.owner_uid = nil
	self.uid = uid
	self.guard_radius = guard_radius or DEFAULT_INTERACTION_RADIUS
	self.stack = stack.create({1, 4}, {scale = 0.5, stack_offset_x = vmath.vector3(64, 0, 2)})
	self.projectile_uid = nil
	if settings.tower_init_load > 0 then
		M.try_insert_item(uid, model, item_object.spawn(model, vmath.vector3(), "stone"))
		self.projectile_uid = stack.remove(self.stack, 1)
		if settings.tower_init_load > 1 then
			for i = 2, settings.tower_init_load do
				M.try_insert_item(uid, model, item_object.spawn(model, vmath.vector3(), "stone"))
			end
		end
	end
	self.is_storage = true
	self.interactable = true
	self.shoot = 0
	self.reload = 0
	self.aim = 0
	-- self.interaction_points = {vmath.vector3(-64, 60, 5), vmath.vector3(64, 60, 5)}
	return uid
end

function M.try_insert_item(uid, model, item_uid)
	local self = model.objects[uid]
	local item = model.objects[item_uid]
	if item.name ~= "stone" then
		return false
	end
	local result = stack.insert(self.stack, item_uid)
	item.owner_uid = uid
	return result
end

function M.try_remove_item(uid, model)
	return nil
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return stack.is_empty(self.stack)
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

return M