local pack = require "utils.pack"
local zoom = require "main.zoom"
local data = require "main.data"
local lights = require "main.lights"
local objects = require "main.objects.objects"


local item_slot_object = require "main.objects.item_slot_object"
local stand_object = require "main.objects.stand_object"
local shop_object = require "main.objects.shop_object"
local player_object = require "main.objects.player_object"
local item_object = require "main.objects.item_object"
local sell_point_object = require "main.objects.sell_point_object"
local recipe_object = require "main.objects.recipe_object"
local workbench_object = require "main.objects.workbench_object"
local button_object = require "main.objects.button_object"
local source_object = require "main.objects.source_object"
local recipe_stand_object = require "main.objects.recipe_stand_object"
local npc_object = require "main.npc.npc_object"
local reserved_stand_object = require "main.objects.reserved_stand_object"
local foundation_object = require "main.objects.foundation_object"
local view_progress_bar = require "main.view.view_progress_bar"
local trashcan_object = require "main.objects.trashcan_object"
local guard_object = require "main.objects.guard_object"
local coin_object = require "main.objects.coin_object"
local next_wave_zone_object = require "main.objects.next_wave_zone"
local sprite_object = require "main.objects.sprite_object"
local diggable_tile_object = require "main.objects.diggable_tile_object"
local point_object = require "main.objects.point_object"

local function router(type)
	if type == objects.TYPES.PLAYER then
		return player_object
	elseif type == objects.TYPES.NPC then
		return npc_object
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
	elseif type == objects.TYPES.GUARD then
		return guard_object
	elseif type == objects.TYPES.COIN then
		return coin_object
	elseif type == objects.TYPES.ZONE then
		return next_wave_zone_object
	elseif type == objects.TYPES.SPRITE then
		return sprite_object
	elseif type == objects.TYPES.DIGGABLE_TILE then
		return diggable_tile_object
	elseif type == objects.TYPES.POINT then
		return point_object
	end
end

-- local router_factory = require "main.objects.objects_router"
-- local router = router_factory.new_router()

local view_data = require "main.view.view_data"

local M = {}

local function delete(uid)
	if view_data.instances[uid] and go.exists(view_data.instances[uid]) then
		go.delete(view_data.instances[uid])
		lights.remove_light_reciever(view_data.instances[uid])
		if view_data.light_sources[uid] then
			lights.remove_light_source(view_data.light_sources[uid])
		end
		if view_data.info[uid] and view_data.info[uid].progress_id then
			view_progress_bar.delete_progress_bar(view_data.info[uid].progress_id)
		end
		if view_data.info[uid] and view_data.info[uid].arrow then
			go.delete(view_data.info[uid].arrow)
		end
		if view_data.info[uid] and view_data.info[uid].radius then
			go.delete(view_data.info[uid].radius)
		end
		zoom.remove_object(view_data.instances[uid])
		view_data.instances[uid] = nil
	end
	view_data.info[uid] = nil
end

local function instanciate(uid, object)
	if not view_data.instances[uid] then

		--ask object manager to create view, and light source (if needed)
		local handle_module = router(object.type)

		view_data.info[uid] = {factory = object.factory}
		
		view_data.instances[uid], view_data.light_sources[uid] = handle_module.new_view(object)--factory.create(object.factory)

		zoom.register_object(msg.url("main", view_data.instances[uid], ""))
	end
end

function M.update_view(model)
	for uid, _ in pairs(view_data.instances) do
		if not model.objects[uid] then
			delete(uid)
		end
	end
	for uid, object in pairs(model.objects) do
		if not view_data.instances[uid] then
			instanciate(uid, object)
		end
		if view_data.info[uid].factory ~= object.factory then
			delete(uid)
			instanciate(uid, object)
		end
		go.set_position(object.position, view_data.instances[uid])
	end
end


function M.update_intrpolate(model1, model2, progress)
	if not view_data.current_location_id or view_data.current_location_id ~= model2.id then
		print("update map to: ", model2.id)

		if view_data.current_location_id then
			local go_name = data.locations[view_data.current_location_id].go_name
			tilemap.set_visible(go_name .. "#ground", "ground", false)
		end

		for _, layer_data in pairs(data.locations) do
			local go_name = layer_data.go_name
			tilemap.set_visible(go_name .. "#ground", "ground", false)
		end

		view_data.current_location_id = model2.id

		local go_name = data.locations[view_data.current_location_id].go_name
		tilemap.set_visible(go_name .. "#ground", "ground", true)
		
		for uid, object in pairs(model1.objects) do
			delete(uid)
		end
		for uid, object in pairs(model2.objects) do
			if not view_data.instances[uid] then
				instanciate(uid, object)
			end
		end
		return
	end
	if model1.id ~= model2.id then
		return
	end
		
	
	for uid, _ in pairs(view_data.instances) do
		if not model2.objects[uid] then
			delete(uid)
		end
	end

	if model1.wave_status ~= model2.wave_status and model2.wave_status == 0 then
		msg.post("root#main_menu", hash("show_prepare"))
	elseif model1.wave_status ~= model2.wave_status and model2.wave_status == 1 then
		msg.post("root#main_menu", hash("show_wave_start"), {wave = model2.wave})
	end

	for uid, object in pairs(model1.objects) do
		if model2.objects[uid] then

			local been_spawned = false

			if not view_data.instances[uid] then
				instanciate(uid, object)
				been_spawned = true
			end
			if view_data.info[uid].factory ~= object.factory then
				delete(uid)
				instanciate(uid, object)
				been_spawned = true
			end

			--delligate interpolation to object manager
			if not been_spawned then
				local handle_module = router(object.type)
				handle_module.update_interpolate(uid, model1, model2, progress)
			end
		end
	end
end

return M