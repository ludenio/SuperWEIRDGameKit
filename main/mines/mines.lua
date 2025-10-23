local mines_map = require "main.mines.mines_map"
local diggable_tile_object = require "main.objects.diggable_tile_object"
local collision_manager = require "main.collision_manager.collision_manager"
local npc_processor = require "main.npc.npc_processor"
local point_object = require "main.objects.point_object"
local data = require "main.data"


local M = {}

local MINES_TILE_OFFSET = 64
local REFRESH_TICKS = 100

local function refresh(location, mine)
	local lv = mines_map.generate_level_core(mine.size, mine.density, mine.probs, mine.layout)
	mine.tile_uid_set = {}
	for x = 1, lv.w do
		for y = 1, lv.h do
			if lv.tiles[x] and lv.tiles[x][y] then
				local offset = vmath.vector3((x - 2) * MINES_TILE_OFFSET + 32, 0, (y - 2) * MINES_TILE_OFFSET + 32)
				local uid
				if lv.tiles[x][y].cover == mines_map.COVER_TYPES.STONE then
					uid = diggable_tile_object.spawn(location, mine.position + offset, "fence", "stone")
					data.npc_prog_targets[location.id][data.NPC_PROG_OPTIONS.MINE]["stone"] = "stone"
				else
					uid = diggable_tile_object.spawn(location, mine.position + offset, "fence_metall", "iron")
					data.npc_prog_targets[location.id][data.NPC_PROG_OPTIONS.MINE]["iron"] = "iron"
				end
				mine.tile_uid_set[uid] = true
				collision_manager.set_collision_by_pos(offset.x + mine.position.x, offset.z + mine.position.z, location, uid)
			end
		end
	end
	return mine
end

function M.create(location, position, name)
	local mine_data = data.mines[name]
	
	local mine = {}
	if location.mines == nil then
		location.mines = {}
	end
	table.insert(location.mines, mine)
	mine.size = {w = mine_data.width, h = mine_data.height}
	mine.probs = {iron = mine_data.p_iron, copper = mine_data.p_copper}
	mine.density = mine_data.density
	mine.layout = mine_data.layout
	mine.position = position
	-- point_object.spawn(location, position - vmath.vector3(mine_data.point_offset_x * 128, 0, mine_data.point_offset_y * 128))
	refresh(location, mine)
	return mine
end

local function tick(location)
	if location.mines == nil then
		location.mines = {}
	end
	for _, mine in ipairs(location.mines) do
		local empty = true
		for uid, _ in pairs(mine.tile_uid_set) do
			if location.objects[uid] == nil then
				mine.tile_uid_set[uid] = nil
			else
				empty = false
			end
		end


		if empty then
			if not mine.refresh_progress then
				mine.refresh_progress = 0
			end
			mine.refresh_progress = mine.refresh_progress + 1
			if mine.refresh_progress >= REFRESH_TICKS then
				mine.refresh_progress = nil
				refresh(location, mine)
			end
		end
	end
end

function M.tick(model)
	for _,location in pairs(model.locations) do
		tick(location)
	end
end

return M