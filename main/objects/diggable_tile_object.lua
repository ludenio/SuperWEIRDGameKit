local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_object = require "main.objects.item_object"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"
local lights = require "main.lights"
local view_progress_bar = require "main.view.view_progress_bar"
local collision_manager = require "main.collision_manager.collision_manager"
local pathfinder = require "main.collision_manager.pathfinder"
local zoom = require "main.zoom"


local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of shop object
--=====================================================================
function M.new_view(object)
	local view_object = factory.create(object.factory)
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 128, 5), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id
	
	if object.sprite then
		sprite.play_flipbook(msg.url("main", view_object, "sprite"), object.sprite .. "_1")
	end

	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "sprite"), nil)

	return view_object, nil
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of shop object
--=====================================================================	
function M.update_interpolate(uid, model1, model2, progress)
	local object = model1.objects[uid]
	local object_new = model2.objects[uid]

	local v1 = object.position
	local v2 = object_new.position
	go.set_position(vmath.lerp(progress, v1, v2), view_data.instances[uid])
	
	if object.sprite and view_data.instances[uid] then
		local step = zoom.get_camera_horizontal_step() % 2 + 1
		sprite.play_flipbook(msg.url("main", view_data.instances[uid], "sprite"), object.sprite .. "_" .. tostring(step))
	end

	local interact_progress = object.progress * (1 - progress) + object_new.progress * progress
	view_progress_bar.set_progress_bar(view_data.info[object.uid].progress_id, 1 - interact_progress)
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of shop object
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.source_name)
	elseif action.type == actions.ACTION_TYPE.TICK then
		-- local self = model.objects[action.uid]
		-- if self.player_interacted_tostop then
		-- 	if self.player_interacted_tostop > 20 then
		-- 		self.player_interacted_tostop = nil
		-- 		self.progress = 0
		-- 	else
		-- 		self.player_interacted_tostop = self.player_interacted_tostop + 1
		-- 	end
		-- elseif not self.player_interacted then
		-- 	self.player_interacted_tostop = 1
		-- end
		-- self.player_interacted = nil
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------

--=========================SPAWN=========================================
-- creating a new shop object in data-model
--=====================================================================
function M.spawn(model, position, sprite, drop_name)
	local uid = mm.create_object(model, "root#universal_go", position)
	local self = model.objects[uid]
	self.factory = "root#universal_go"
	self.type = objects.TYPES.DIGGABLE_TILE
	self.sprite = sprite
	self.drop_name = drop_name
	self.interactable = true
	self.progress = 0
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------

function M.drop_item(uid, model, element_name)
	local self = model.objects[uid]
	local item_uid = item_object.spawn(model, vmath.vector3(self.position), element_name)
	model.objects[item_uid].visible = true
	model.objects[item_uid].interactable = true
	model.objects[item_uid].owner_uid = nil
	return item_uid
end

function M.is_empty(uid, model)
	local self = model.objects[uid]
	return self.item_uid == nil
end

function M.player_move_interact(uid, model, p_uid)
	local DIST_MODIFIER = 40
	
	local self = model.objects[uid]
	local player = model.objects[p_uid]
	local distance = vmath.length(player.position - self.position) / DIST_MODIFIER
	local progress_increment = 0.05
	self.player_interacted = true
	self.progress = self.progress + progress_increment
	if self.progress >= 1 then
		self.progress = 0
		local drop_uid = M.drop_item(uid, model, self.drop_name)
		mm.delete_object(model, uid)
		collision_manager.delete_collision_by_pos(self.position.x, self.position.z, model)
		pathfinder.reset_paths(model)
		return drop_uid
	end
	return
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M