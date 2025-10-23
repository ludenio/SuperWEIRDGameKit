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
local view_progress_bar = require "main.view.view_progress_bar"
local pathfinder = require "main.collision_manager.pathfinder"
local mines = require "main.mines.mines"
local npc_processor = require "main.npc.npc_processor"
local settings = require "main.settings"

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
local guard_object = require "main.objects.guard_object"

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
	elseif type == objects.TYPES.GUARD then
		return guard_object
	end
end

--=========================CREATE VIEW==============================
-- called from view 
-- creates a view representation of existing item object
--==================================================================
function M.new_view(object)
	local view_object, light_object = item_object.new_view(object)
	
	local id = view_progress_bar.init_progress_bar(vmath.vector3(0, 200, 20), view_object)
	view_progress_bar.set_progress_bar(id, object.progress)
	view_data.info[object.uid].progress_id = id
	msg.post(msg.url("main", view_object, "coin_icon"), "disable")
	msg.post(msg.url("main", view_object, "price"), "disable")
	msg.post(msg.url("main", view_object, "bounds"), "disable")
	msg.post(msg.url("main", view_object, "sprite"), "disable")

	return view_object, light_object
end
--=========================CREATE VIEW==============================
--------------------------------------------------------------------


--=========================INTERPOLATION============================
-- called from view                        
-- modifying an existing view representation of item object  
--==================================================================

function M.update_interpolate(uid, model1, model2, progress)
	item_object.update_interpolate(uid, model1, model2, progress)
	local self = model1.objects[uid]
	local instance = view_data.instances[uid]

	if self.visible then
		msg.post(msg.url("main", instance, "coin_icon"), "enable")
		msg.post(msg.url("main", instance, "price"), "enable")
		msg.post(msg.url("main", instance, "bounds"), "enable")
		if self.bounds_sprite then
			sprite.play_flipbook(msg.url("main", instance, "bounds"), self.bounds_sprite)
		end
		label.set_text(msg.url("main", instance, "price"), tostring(self.cost))
		view_progress_bar.set_progress_bar(view_data.info[uid].progress_id, self.progress)
	else
		msg.post(msg.url("main", instance, "coin_icon"), "disable")
		msg.post(msg.url("main", instance, "price"), "disable")
		msg.post(msg.url("main", instance, "bounds"), "disable")
	end

	if model2.money < self.cost then
		go.set(msg.url("main", instance, "price"), "color", vmath.vector4(0.5, 0.5, 0.5, 1))
	else
		go.set(msg.url("main", instance, "price"), "color", vmath.vector4(1, 1, 1, 1))
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
		M.spawn(model, action.position, action.foundation_tag, action.foundation_cfg)
	elseif action.type == actions.ACTION_TYPE.TICK then
		local self = model.objects[action.uid]
		if not self.player_interacted then
			self.progress = 0
		end
		self.player_interacted = nil
		M.update_availability(action.uid, model)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, foundation_tag, foundation_cfg)
	local uid = mm.create_object(model, "root#price_label_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	self.foundation_tag = foundation_tag
	local foundation_data = data[foundation_cfg][self.foundation_tag]
	self.foundation_index = foundation_data.number
	self.visible = false
	self.interactable = false
	self.sprite = "foundation"
	self.cost = foundation_data.price
	self.unlocks = foundation_data.unlocks
	self.unlocked = foundation_data.unlocked
	self.type = objects.TYPES.FOUNDATION
	self.owner_uid = nil
	self.uid = uid
	self.progress = 0
	self.visible = false
	self.interactable = false

	self.foundation_cfg = foundation_cfg
	self.foundation_tag = foundation_tag

	model.foundations[uid] = self
	M.update_availability(uid, model)

	if foundation_data.type == "source" then
		self.bounds_sprite = "bounds_small" 
	elseif foundation_data.type == "recipe" then
		self.bounds_sprite = "bounds_small" 
	elseif foundation_data.type == "workbench" then
		self.bounds_sprite = "bounds_large" 
	elseif foundation_data.type == "sell_point" then
		self.bounds_sprite = "bounds_medium" 
	elseif foundation_data.type == "reserved_stand" then
		self.bounds_sprite = "bounds_medium" 
	elseif foundation_data.type == "guard" then
		self.bounds_sprite = "bounds_small" 
	elseif foundation_data.type == "mines" then
		--TODO rework bounds
		self.bounds_sprite = "bounds_small" 
	elseif foundation_data.type == "miner" then
		self.bounds_sprite = "bounds_small" 
	end
	
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

function M.update_availability(uid, model)
	local self = model.objects[uid]
	-- if model.foundations_unlocked >= self.foundation_index and model.money >= self.cost then
	-- if self.unlocked and model.money >= self.cost then
	if self.unlocked and (not settings.hide_unreachable_foundations or model.money >= self.cost) then
		self.visible = true
		self.interactable = true
	else
		self.visible = false
		self.interactable = false
	end
end

function M.build(uid, model)
	local self = model.objects[uid]
	model.money = model.money - self.cost

	local foundation_data = data[self.foundation_cfg][self.foundation_tag]


	if foundation_data.create_collision then
		collision_manager.set_128collision_by_pos(self.position.x + 10, self.position.z + 10, model)
	end

	pathfinder.reset_paths(model)

	if foundation_data.type == "source" then
		local handler = router(objects.TYPES.SOURCE)
		handler.spawn(model, self.position, foundation_data.name)
	elseif foundation_data.type == "recipe" then
		local handler = router(objects.TYPES.RECIPE_STAND)
		handler.spawn(model, self.position, foundation_data.name)
	elseif foundation_data.type == "workbench" then
		local handler = router(objects.TYPES.WORKBENCH)
		handler.spawn(model, self.position, foundation_data.name)
		data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.PUT_IN][objects.TYPES.WORKBENCH] = "table_blueprint"
		data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.TAKE_FROM][objects.TYPES.WORKBENCH] = "table_blueprint"
	elseif foundation_data.type == "sell_point" then
		local handler = router(objects.TYPES.SELL_POINT)
		handler.spawn(model, self.position)
	elseif foundation_data.type == "reserved_stand" then
		local handler = router(objects.TYPES.RESERVED_STAND)
		handler.spawn(model, self.position, foundation_data.name)
		data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.PUT_IN][objects.TYPES.RESERVED_STAND] = "store"
	elseif foundation_data.type == "guard" then
		local handler = router(objects.TYPES.GUARD)
		handler.spawn(model, self.position, foundation_data.guard_radius)
		data.npc_prog_targets[model.id][data.NPC_PROG_OPTIONS.PUT_IN][objects.TYPES.GUARD] = "tower"
	elseif foundation_data.type == "wall" then
		local handler = router(objects.TYPES.STAND)
		handler.spawn(model, self.position, {0,0})
	elseif foundation_data.type == "mines" then
		mines.create(model, self.position, foundation_data.name)
	elseif foundation_data.type == "portal" then
		local handler = router(objects.TYPES.BUTTON)
		handler.spawn(model, self.position, foundation_data.name, foundation_data.sprite, false)
	elseif foundation_data.type == "miner" then
		local target_1_element_name = data.miners[foundation_data.name].target_1_element_name
		local target_2_type = data.miners[foundation_data.name].target_2_type
		npc_processor.spawn(model, self.position, "MINER", {skin = 5, speed = 0.2, target_1_element_name = target_1_element_name, target_2_type = objects.TYPES[target_2_type], interactable = true})
		-- mines.create_miner(model.locations[foundation_data.location_id], self.position, foundation_data.name)
	end
	model.foundations_unlocked = model.foundations_unlocked + foundation_data.to_reveal
	model.foundations[uid] = nil
	if self.unlocks then
		for other_uid, other_object in pairs(model.foundations) do
			for _, foundation_tag in pairs(self.unlocks) do
				if other_object.foundation_tag == foundation_tag then
					other_object.unlocked = true
				end
			end
			M.update_availability(other_uid, model)
		end
	end
	mm.delete_object(model, uid)
end

function M.player_interact(uid, model)
	local self = model.objects[uid]
	if model.money < self.cost then
		return nil
	end
	self.player_interacted = true
	self.progress = self.progress + 0.05
	if self.progress >= 1 then
		M.build(uid, model)
	end
end

return M