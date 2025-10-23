local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local item_slot_object = require "main.objects.item_slot_object"
local item_object = require "main.objects.item_object"
local pack = require "utils.pack"
local actions = require "main.sys.actions"
local view_data = require "main.view.view_data"


local M = {}

--=========================CREATE VIEW====================================
-- creating a new view representation of shop object
--=====================================================================
function M.new_view(object)
	local view_object, light_object = item_slot_object.new_view(object)

	msg.post(msg.url("main", view_object, "coin_icon"), "enable")
	msg.post(msg.url("main", view_object, "price"), "enable")
	label.set_text(msg.url("main", view_object, "price"), tostring(object.cost))
	
	return view_object, light_object
end
--=========================CREATE VIEW=================================
-----------------------------------------------------------------------

--=========================INTERPOLATION=================================
-- called from view
-- modifying an existing view representation of shop object
--=====================================================================	
function M.update_interpolate(uid, model1, model2, progress)
	item_slot_object.update_interpolate(uid, model1, model2, progress)

	-- if model1.objects[uid].item_uid then
	-- 	go.set_position(vmath.vector3(0, 60, 5), view_data.instances[model1.objects[uid].item_uid])
	-- end
end
--=========================INTERPOLATION=================================
-----------------------------------------------------------------------

--=========================ACTION HANDLING==============================
-- called from mutator
-- modifying data-model of shop object
--=====================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		local item_uid = item_object.spawn(model, action.item_create_action.position, action.item_create_action.element_name) --TODO: change stub item, to stack and sprite
		M.spawn(model, action.position, item_uid)
	else
		item_slot_object.apply_action(model, action)
	end
end
--=========================ACTION HANDLING==============================
-----------------------------------------------------------------------

--=========================SPAWN=========================================
-- creating a new shop object in data-model
--=====================================================================
function M.spawn(model, position, item_template_uid)
	local uid = item_slot_object.spawn(model, position)
	local self = model.objects[uid]
	self.factory = "root#price_label_go"--"/root#shop_factory"
	self.sprite = "shop"
	self.type = objects.TYPES.SHOP
	self.cost = model.objects[item_template_uid].buy_price
	M.try_insert_item(uid, model, item_template_uid)
	model.objects[item_template_uid].position = vmath.vector3(0, 60, 5)
	
	return uid
end
--=========================SPAWN=========================================
-----------------------------------------------------------------------


function M.is_empty(uid, model)
	return item_slot_object.is_empty(uid, model)
end

function M.try_insert_item(uid, model, item_uid)
	return item_slot_object.try_insert_item(uid, model, item_uid)
end

function M.try_remove_item(uid, model)
	return nil
end

function M.player_interact(uid, model, p_uid)
	local self = model.objects[uid]
	if model.money < self.cost then
		return nil
	end
	model.money = model.money - self.cost

	local clone_uid = mm.clone_object(model, self.item_uid)
	pprint("cloned_object: ", model.objects[clone_uid])

	return clone_uid
end

function M.get_attach_go(uid, model, instances)
	return instances[uid]
end

return M