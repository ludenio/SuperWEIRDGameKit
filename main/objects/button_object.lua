local actions = require "main.sys.actions"
local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local view_data = require "main.view.view_data"
local pack = require "utils.pack"
local zoom = require "main.zoom"
local lights = require "main.lights"
local collision_manager = require "main.collision_manager.collision_manager"
local data = require "main.data"
local hashes = require "utils.hashes"
local view_progress_bar = require "main.view.view_progress_bar"

local item_object = require "main.objects.item_object"


local M = {}

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
	
	local light_object = nil
	if object.light then
		light_object = factory.create("/root#light_source_factory")
		go.set_parent(light_object, view_object)

		timer.delay(0.01, false, function() --position linked to parent will be calculated only in next frame, so we can set position of light only in next frame
			go.set_position(vmath.vector3(0, 32, 0), light_object)
		end)

		lights.add_light_source(light_object, nil, object.light)
	end

	lights.add_light_reciever(view_object, nil, msg.url("main", view_object, "sprite"), light_object)

	if object.sprite then
		sprite.play_flipbook(view_object, object.sprite)
	end

	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 200, 20), view_object)
	view_progress_bar.set_progress_bar(id, object.progress or 0)
	view_data.info[object.uid].progress_id = id

	return view_object, light_object
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
	
	go.set_position(vmath.lerp(progress, v1, v2), view_data.instances[uid])

	view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, object.progress or 0)
end

--======================INTERPOLATION================================
---------------------------------------------------------------------

--========================ACTION HANDLING============================
-- called from mutator                        
-- modifying data-model of item object
--===================================================================
function M.apply_action(model, action)

	if action.type == actions.ACTION_TYPE.TICK then
		local button = model.objects[action.uid]
		if not button.player_interacted then
			button.progress = 0
		end
		button.player_interacted = nil
	elseif action.type == actions.ACTION_TYPE.EXTRACT_ITEM_FROM_LOCATION then
		print("extract item from location")
		local item_position = vmath.vector3(model.objects[action.uid].position)
		local item = item_object.spawn(model, item_position + vmath.vector3(0, 0, 150), action.element_name)
		
	elseif action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.to_location, action.sprite)
		data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.PUT_IN][objects.TYPES.BUTTON] = "mine_entry"
		-- data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.TAKE_FROM][objects.TYPES.BUTTON] = "mine_entry"
	end
end

function M.stack_interact(uid, model)
	local self = model.objects[uid]
	self.progress = (self.progress or 0) + 0.05
	if self.progress > 1 and self.to_location then
		self.player_interacted = true
	end
end

function M.player_interact(uid, model, p_uid)
	local self = model.objects[uid]
	self.progress = (self.progress or 0) + 0.05
	if self.progress > 1 and self.to_location then
		local player_id = model.objects[p_uid].owner_id
		local delete_action = actions.delete_player(p_uid, player_id)
		local spawn_action = actions.spawn_player(vmath.vector3(-650, 0, -100), player_id, {offset = vmath.vector3(0, 0, 200), from_location_id = model.id})
		actions.send_action(delete_action, model.id, data.are_actions_local)
		actions.send_action(spawn_action, self.to_location, data.are_actions_local)
		self.progress = -0.2
	end
	self.player_interacted = true
end

function M.npc_insert_item(uid, model, item_uid, npc_uid)
	M.try_insert_item(uid, model, item_uid)
end

function M.try_insert_item(uid, model, item_uid)
	local item = model.objects[item_uid]
	local button = model.objects[uid]

	if item.type == objects.TYPES.ITEM then
		item.owner_uid = uid
		mm.delete_object(model, item_uid)
		local action = actions.extract_item_from_location(item.location_id, item.name)
		actions.send_action(action, button.to_location, data.are_actions_local)
		return true
	end
	return false
end
--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, to_location, sprite, is_storage)
	local uid = mm.create_object(model, "root#universal_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	self.sprite = sprite or "button"
	self.type = objects.TYPES.BUTTON
	self.owner_uid = nil
	self.interactable = true
	self.is_pickable = false
	self.uid = uid
	self.to_location = to_location

	if is_storage == nil then
		is_storage = true
	end
	self.is_storage = is_storage
	self.npc_interactable = true
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

function M.is_empty(uid, model)
	return true
end

return M