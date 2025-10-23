local M = {}

M.TYPES = {
	ITEM_SLOT = 1,
	ITEM = 2,
	PLAYER = 3,
	SHOP = 4,
	SELL_POINT = 5,
	STAND = 6,
	RECIPE = 7,
	WORKBENCH = 8,
	BUTTON = 9,
	SOURCE = 10,
	RECIPE_STAND = 11,
	NPC = 12,
	RESERVED_STAND = 13,
	FOUNDATION = 14,
	TRASHCAN = 15,
	GUARD = 16,
	COIN = 17,
	ZONE = 18,
	SPRITE = 19,
	DIGGABLE_TILE = 20,
	POINT = 21,
}

M.is_affecting_pathfinder = {
	[M.TYPES.STAND] = true,
	[M.TYPES.GUARD] = true,
	[M.TYPES.DIGGABLE_TILE] = true,
	[M.TYPES.SOURCE] = true,
	
}

return M