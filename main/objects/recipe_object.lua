local actions = require "main.sys.actions"
local mm = require "main.sys.model"
local objects = require "main.objects.objects"
local view_data = require "main.view.view_data"
local pack = require "utils.pack"
local zoom = require "main.zoom"
local lights = require "main.lights"
local collision_manager = require "main.collision_manager.collision_manager"
local data = require "main.data"
local item_object = require "main.objects.item_object"

local M = {}

--=========================CREATE VIEW==============================
-- called from view 
-- creates a view representation of existing item object
--==================================================================
function M.new_view(object)
	return item_object.new_view(object)
end
--=========================CREATE VIEW==============================
--------------------------------------------------------------------


--=========================INTERPOLATION============================
-- called from view                        
-- modifying an existing view representation of item object  
--==================================================================

function M.update_interpolate(uid, model1, model2, progress)
	item_object.update_interpolate(uid, model1, model2, progress)
end

--======================INTERPOLATION================================
---------------------------------------------------------------------

--========================ACTION HANDLING============================
-- called from mutator                        
-- modifying data-model of item object
--===================================================================
function M.apply_action(model, action)
	if action.type == actions.ACTION_TYPE.SPAWN_OBJECT then
		M.spawn(model, action.position, action.element_name)
	end
end

--=========================ACTION HANDLING==========================
--------------------------------------------------------------------



--=========================SPAWN====================================
-- creates a new item object in data-model
--==================================================================
function M.spawn(model, position, recipe_name)
	local uid = mm.create_object(model, "root#universal_go", position)--"/root#orb_factory", position)
	local self = model.objects[uid]
	local recipe = data.recipes[recipe_name]
	self.visible = true
	self.name = recipe_name
	-- self.sprite = recipe.sprite
	self.left = recipe.left
	self.right = recipe.right
	self.result = recipe.result
	self.type = objects.TYPES.RECIPE
	self.owner_uid = nil
	self.interactable = true
	self.is_pickable = true
	self.uid = uid
	-- model.items[uid] = true
	return uid
end

--=========================SPAWN====================================
--------------------------------------------------------------------	

return M