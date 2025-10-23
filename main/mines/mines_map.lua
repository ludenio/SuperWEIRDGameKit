local utils 	= require("utils.common_utils")
local ss 		= require("main.settings")

local M = {}

M.COVER_TYPES = {
	EMPTY = 0,
	STONE = 64,
	COAL = 80,
	COPPER = 96,
	IRON = 112,
	BARRIER = 128,
}

M.CONTENT_TYPES = {
	EMPTY = 0,
	STONE = 11,
	BATTERY_SMALL = 7,
	COAL = 8,
	COPPER = 9,
	IRON = 10,
	BOMB = 12,
}

M.ORE_POWER_LEVEL_ORE_PROB = {
	[3] = 0.9,
	[2] = 0.63,
	[1] = 0.36,
	[0] = 0.1
}

M.LEVEL_WIDTH = 7
M.LEVEL_HEIGHT = 7
M.BASE_BORDER = 1
M.LEVEL_CENTER = {
	x = 4,
	y = 4
}
M.LEVEL_BASE_SIZE_MIN = 0
M.LEVEL_BASE_SIZE_MAX = 16

M.LEVEL_X_SPACING = 1
M.LEVEL_Y_SPACING = 1

M.CANVAS_WIDTH = M.LEVEL_WIDTH * 2 + M.LEVEL_X_SPACING
M.CANVAS_HEIGHT = M.LEVEL_HEIGHT * 2 + M.LEVEL_Y_SPACING

M.MAP_DEPTH = 100

M.TILES = {
	barrier = { -- base tile. sets default tile parameters.
		mark = M.COVER_TYPES.BARRIER,
		tile = {
			cover = M.COVER_TYPES.BARRIER,
			content = M.CONTENT_TYPES.EMPTY,
			ore = 0,
			is_barrier = true,
			is_digable = false,
			-- health = 0,
			-- max_health = 0,
		}
	},
	empty = {
		mark = M.COVER_TYPES.EMPTY,
		tile = {
			cover = M.COVER_TYPES.EMPTY,
			content = M.CONTENT_TYPES.EMPTY,
			is_barrier = false,
			is_digable = false,
			-- health = 0,
			-- max_health = 0,
		}
	},
	stone = {
		mark = M.COVER_TYPES.STONE,
		tile = {
			cover = M.COVER_TYPES.STONE,
			is_barrier = false,
			is_digable = true,
			-- health = ss.COVER_HEALTH.stone,
			-- max_health = ss.COVER_HEALTH.stone,
		}
	},
	coal = {
		mark = M.COVER_TYPES.COAL,
		tile = {
			cover = M.COVER_TYPES.COAL,
			is_barrier = false,
			is_digable = true,
			-- health = ss.COVER_HEALTH.coal,
			-- max_health = ss.COVER_HEALTH.coal,
		}
	},
	copper = {
		mark = M.COVER_TYPES.COPPER,
		tile = {
			cover = M.COVER_TYPES.COPPER,
			is_barrier = false,
			is_digable = true,
			-- health = ss.COVER_HEALTH.copper,
			-- max_health = ss.COVER_HEALTH.copper,
		}
	},
	iron = {
		mark = M.COVER_TYPES.IRON,
		tile = {
			cover = M.COVER_TYPES.IRON,
			is_barrier = false,
			is_digable = true,
			-- health = ss.COVER_HEALTH.iron,
			-- max_health = ss.COVER_HEALTH.iron,
		}
	},
}

M.ORE_CRACKS = {
	coal = 21,
	copper = 22,
	iron = 23,
}

M.levels = {}
local max_id = 0

local function get_new_level()
	max_id = max_id + 1
	M.levels[max_id] = {
		id = max_id
	}
	return M.levels[max_id]
end

local function extract_random(t) 
	local i = math.random(#t)
	local item = t[i]
	table.remove(t, i)
	return item
end

function M.get_level_tile(level_id, x, y)
	local lv = M.levels[level_id]
	if lv.standalone then
		if lv.tiles == nil or lv.tiles[x] == nil or lv.tiles[x][y] == nil then
			return M.TILES.barrier.tile
		end
		return lv.tiles[x][y]
	end
	
	local tile = M.get_global_tile(M.levels[level_id].global.x + x, M.levels[level_id].global.y + y, M.levels[level_id].layer)
	if tile.level_id ~= level_id then
		return M.TILES.barrier.tile
	end
	return tile
end

function M.set_level_tile(level_id, x, y, tile)
	local lv = M.levels[level_id]
	if lv.standalone then
		if lv.tiles == nil then
			lv.tiles = {}
		end
		if lv.tiles[x] == nil then
			lv.tiles[x] = {}
		end
		if lv.tiles[x][y] == nil then
			lv.tiles[x][y] = utils.copy_table(M.TILES.barrier.tile)
			lv.tiles[x][y].x = x
			lv.tiles[x][y].y = y
		end
		for k, v in pairs(tile) do
			lv.tiles[x][y][k] = v
		end
		return
	end
	M.set_global_tile(M.levels[level_id].global.x + x, M.levels[level_id].global.y + y, M.levels[level_id].layer, tile)
end

function M.set_tile(lv, x, y, tile)
	if lv.tiles == nil then
		lv.tiles = {}
	end
	if lv.tiles[x] == nil then
		lv.tiles[x] = {}
	end
	if lv.tiles[x][y] == nil then
		lv.tiles[x][y] = utils.copy_table(M.TILES.barrier.tile)
		lv.tiles[x][y].x = x
		lv.tiles[x][y].y = y
	end
	for k, v in pairs(tile) do
		lv.tiles[x][y][k] = v
	end
	return
end

function M.find_tile(id, query)
	local level = M.get_level(id)
	local tiles = M.get_level_tiles(id)
	local estimator = 1000
	local result = nil
	for _, pos in ipairs(tiles) do
		local current_estimator = math.abs(pos.x - level.center.x) + math.abs(pos.y - level.center.y)
		if current_estimator < estimator then
			local match = true
			local tile = M.get_level_tile(id, pos.x, pos.y)
			for k, v in pairs(query) do
				if tile[k] ~= v or (v == "#notnil" and tile[k] == nil) or (tile[k] ~= nil and v == "#nil") then
					match = false
				end
			end
			if match then
				estimator = current_estimator
				result = pos
			end
		end
	end
	return result
end

function M.get_level_tiles(level_id)
	local level = M.levels[level_id]
	local tiles = {}
	for xx = 1, level.width do
		for yy = 1, level.height do
			if M.get_level_tile(level_id, xx, yy) ~= M.COVER_TYPES.BARRIER then
				table.insert(tiles, {x = xx, y = yy})
			end
		end
	end
	return tiles
end

local function do_for_bordered_neighbours4(x, y, bx_low, bx_high, by_low, by_high, func)
	if x + 1 <= bx_high then
		func(x + 1, y)
	end
	if x - 1 >= bx_low then
		func(x - 1, y)
	end
	if y + 1 <= by_high then
		func(x, y + 1)
	end
	if y - 1 >= by_low then
		func(x, y - 1)
	end
end

local function connect_tiles(t1, t2)
	local dx
	local w
	if t1.x < t2.x then
		dx = 1
		w = t2.x - t1.x
	else
		dx = -1
		w = t1.x - t2.x
	end
	local dy
	local h
	if t1.y < t2.y then
		dy = 1
		h = t2.y - t1.y
	else
		dy = -1
		h = t1.y - t2.y
	end

	-- заносим в таблицу шаги
	local deltas = {}
	for _ = 1, w do
		table.insert(deltas, {x = dx, y = 0})
	end
	for _ = 1, h do
		table.insert(deltas, {x = 0, y = dy})
	end

	--прокладываем путь
	local tiles = {}
	local rx = t1.x
	local ry = t1.y
	table.insert(tiles, {x = rx, y = ry})
	while #deltas > 0 do
		local delta = extract_random(deltas)
		rx = rx + delta.x
		ry = ry + delta.y
		table.insert(tiles, {x = rx, y = ry})
	end

	return tiles
end

local function matrix_contains(matrix, x, y)
	return matrix ~= nil and matrix[x] ~= nil and matrix[x][y] ~= nil and matrix[x][y]
end

local function matrix_set(matrix, x, y, v)
	if matrix == nil then return end
	if matrix[x] == nil then matrix[x] = {} end
	matrix[x][y] = v
end

-- строим случайный скелет из содиненных вершин
local function random_connected_tiles(base_tiles, lx, hx, ly, hy, size)
	print(size)
	local loaded = {}
	local positions = {}
	local candidates = {}
	for _, tile in ipairs(base_tiles) do
		table.insert(positions, tile)
		matrix_set(loaded, tile.x, tile.y, true)
	end
	for _, tile in ipairs(base_tiles) do
		do_for_bordered_neighbours4(tile.x, tile.y, lx, hx, ly, hy, function(nx, ny)
			if not matrix_contains(loaded, nx, ny) then
				table.insert(candidates, {x = nx, y = ny})
				matrix_set(loaded, nx, ny, true)
			end
		end)
	end
	for _ = 1, size do
		local pos = extract_random(candidates)
		table.insert(positions, pos)
		do_for_bordered_neighbours4(pos.x, pos.y, lx, hx, ly, hy, function(nx, ny)
			if not matrix_contains(loaded, nx, ny) then
				table.insert(candidates, {x = nx, y = ny})
				matrix_set(loaded, nx, ny, true)
			end
		end)
	end
	return positions
end

local function grow_to_nb_tiles(base_tiles, lx, hx, ly, hy)
	local loaded = {}
	local positions = {}
	for _, tile in ipairs(base_tiles) do
		table.insert(positions, tile)
		matrix_set(loaded, tile.x, tile.y, true)
	end
	for _, tile in ipairs(base_tiles) do
		do_for_bordered_neighbours4(tile.x, tile.y, lx, hx, ly, hy, function(nx, ny)
			if not matrix_contains(loaded, nx, ny) then
				table.insert(positions, {x = nx, y = ny})
				matrix_set(loaded, nx, ny, true)
			end
		end)
	end
	return positions
end

local function fill_with_ore(level_id, tiles, depth)
	local ore_power
	if depth < 1 then
		ore_power = {}
	elseif depth < 6 then
		ore_power = {coal = 1}
	elseif depth < 11 then
		ore_power = {coal = 3, copper = 1}
	elseif depth < 16 then
		ore_power = {coal = 2, copper = 3, iron = 1}
	elseif depth < 21 then
		ore_power = {coal = 1, copper = 2, iron = 3}
	else
		ore_power = {coal = 1, copper = 2, iron = 3}
	end
	for i, pos in ipairs(tiles) do
		M.set_level_tile(level_id, pos.x, pos.y, M.TILES.stone.tile)
		M.set_level_tile(level_id, pos.x, pos.y, {level_id = level_id})
		local ores = {}
		for ore, power in pairs(ore_power) do
			local prob = M.ORE_POWER_LEVEL_ORE_PROB[power]
			if math.random() <= prob then
				table.insert(ores, ore)
			end
		end
		if #ores > 0 then
			local ore = extract_random(ores)
			M.set_level_tile(level_id, pos.x, pos.y, M.TILES[ore].tile)
		end
	end
end

local function fill_with_ore_lv(lv, tiles, probs)
	-- local ore_power
	-- if depth < 1 then
	-- 	ore_power = {}
	-- elseif depth < 6 then
	-- 	ore_power = {coal = 1}
	-- elseif depth < 11 then
	-- 	ore_power = {coal = 3, copper = 1}
	-- elseif depth < 16 then
	-- 	ore_power = {coal = 2, copper = 3, iron = 1}
	-- elseif depth < 21 then
	-- 	ore_power = {coal = 1, copper = 2, iron = 3}
	-- else
	-- 	ore_power = {coal = 1, copper = 2, iron = 3}
	-- end
	for i, pos in ipairs(tiles) do
		M.set_tile(lv, pos.x, pos.y, M.TILES.stone.tile)
		local ores = {}
		for ore, prob in pairs(probs) do
			-- local prob = M.ORE_POWER_LEVEL_ORE_PROB[power]
			if math.random() <= prob then
				table.insert(ores, ore)
			end
		end
		if #ores > 0 then
			local ore = extract_random(ores)
			M.set_tile(lv, pos.x, pos.y, M.TILES[ore].tile)
		end
	end
end

local function fill_with_empty(level_id, tiles, depth)
	for i, pos in ipairs(tiles) do
		M.set_level_tile(level_id, pos.x, pos.y, M.TILES.empty.tile)
		M.set_level_tile(level_id, pos.x, pos.y, {level_id = level_id})
	end
end

--returns: level, tiles
function M.generate_level_core_small(depth)
	local tiles = {}
	local cx = 2
	local cy = 2
	local w = 3
	local h = 3
	table.insert(tiles, {x = cx, y = cy})
	table.insert(tiles, {x = cx - 1, y = cy})
	table.insert(tiles, {x = cx + 1, y = cy})
	table.insert(tiles, {x = cx, y = cy + 1})
	table.insert(tiles, {x = cx - 1, y = cy + 1})
	table.insert(tiles, {x = cx + 1, y = cy + 1})
	table.insert(tiles, {x = cx, y = cy - 1})
	table.insert(tiles, {x = cx - 1, y = cy - 1})
	table.insert(tiles, {x = cx + 1, y = cy - 1})
	local level = get_new_level()
	level.passages = {}
	level.standalone = true
	level.depth = depth
	level.width = w
	level.height = h
	level.center = {x = cx, y = cy}
	fill_with_ore(level.id, tiles, depth)
	
	return level, tiles
end

function M.generate_level_core(size, density, probs, layout)
	math.randomseed(os.time())
	local tiles = {}
	local w = size.w
	local h = size.h
	local cx = math.floor(w / 2)
	local cy = math.floor(h / 2)
	table.insert(tiles, {x = cx, y = cy})

	if layout then
		for x = 1, w do
			for y = 1, h do
				if layout[y] and layout[y][x] == 1 then
					table.insert(tiles, {x = x, y =y})
				end
			end
		end
	else

		-- random level skeleton
		local level_size = math.floor((w - 2) * (h - 2) * density) - 1
		tiles = random_connected_tiles(tiles, 2, w - 1, 2, h - 1, level_size)

		-- expand it by 1 tile each direction
		tiles = grow_to_nb_tiles(tiles, 1, w, 1, h)
	end

	local lv = {}
	fill_with_ore_lv(lv, tiles, probs)

	lv.size = #tiles
	lv.w = w
	lv.h = h
	
	return lv
end

--returns: level, tiles
function M.generate_level_core_medium(depth)
	local tiles = {}
	local cx = 3
	local cy = 3
	local w = 5
	local h = 5
	table.insert(tiles, {x = cx, y = cy})

	-- строим случайный скелет уровня из содиненных вершин
	local level_size = math.random(5, 8)
	tiles = random_connected_tiles(tiles, 1 + M.BASE_BORDER, w - M.BASE_BORDER, 1 + M.BASE_BORDER, h - M.BASE_BORDER, level_size)

	-- раздуваем его на 1 в каждую сторону
	tiles = grow_to_nb_tiles(tiles, 1, w, 1, h)
	
	local level = get_new_level()
	level.passages = {}
	level.standalone = true
	level.depth = depth
	level.width = w
	level.height = h
	level.center = {x = cx, y = cy}
	fill_with_ore(level.id, tiles, depth)

	return level, tiles
end

--returns: level, tiles
function M.generate_level_core_large(depth, settings)
	local tiles = {}
	local cx = 4
	local cy = 4
	local w = 7
	local h = 7
	table.insert(tiles, {x = cx, y = cy})
	table.insert(tiles, {x = cx - 1, y = cy})
	table.insert(tiles, {x = cx + 1, y = cy})
	table.insert(tiles, {x = cx, y = cy + 1})
	table.insert(tiles, {x = cx - 1, y = cy + 1})
	table.insert(tiles, {x = cx + 1, y = cy + 1})
	table.insert(tiles, {x = cx, y = cy - 1})
	table.insert(tiles, {x = cx - 1, y = cy - 1})
	table.insert(tiles, {x = cx + 1, y = cy - 1})

	-- строим случайный скелет уровня из содиненных вершин
	local level_size = math.random(0, 16)
	tiles = random_connected_tiles(tiles, 1 + M.BASE_BORDER, w - M.BASE_BORDER, 1 + M.BASE_BORDER, h - M.BASE_BORDER, level_size)

	-- раздуваем его на 1 в каждую сторону
	tiles = grow_to_nb_tiles(tiles, 1, w, 1, h)

	local level = get_new_level()
	level.passages = {}
	level.standalone = true
	level.depth = depth
	level.width = w
	level.height = h
	level.center = {x = cx, y = cy}
	if settings and settings.empty then
		fill_with_empty(level.id, tiles, depth)
	else
		fill_with_ore(level.id, tiles, depth)
	end

	return level, tiles
end

function M.generate_level_core_shop(depth)
	local tiles = {}
	local cx = 3
	local cy = 3
	local w = 5
	local h = 5
	for x = cx - 2, cx + 2 do
		for y = cy - 2, cy + 2 do
			table.insert(tiles, {x = x, y = y})
		end
	end
	-- tiles = grow_to_nb_tiles(tiles, 1, w, 1, h)

	-- table.insert(tiles, {x = 5, y = 3})
	-- table.insert(tiles, {x = 3, y = 3})
	-- table.insert(tiles, {x = 1, y = 3})
	-- table.insert(tiles, {x = 2, y = 1})
	-- table.insert(tiles, {x = 3, y = 1})
	-- table.insert(tiles, {x = 4, y = 1})
	
	local level = get_new_level()
	level.passages = {}
	level.standalone = true
	level.depth = depth
	level.width = w
	level.height = h
	level.center = {x = cx, y = cy}
	fill_with_empty(level.id, tiles, depth)

	return level, tiles
end

M.LEVEL_TYPE = {
	HEAL = 1,
	SHOP = 2,
	BOSS = 3,
	HARD = 4,
	COMMON = 5,
	FIRST = 6,
	SECOND = 7,
}

function M.set_item(level, pos, item)
	M.set_level_tile(level.id, pos.x, pos.y, M.TILES.empty.tile)
	M.set_level_tile(level.id, pos.x, pos.y, {item = item, is_item = true})
end

function M.set_enemy(level, pos, enemy)
	for _, offset in ipairs(enemy.restricted) do
		M.set_level_tile(level.id, pos.x + offset.x, pos.y + offset.y, M.TILES.empty.tile)
		M.set_level_tile(level.id, pos.x + offset.x, pos.y + offset.y, {is_enemy = true, enemy_core_pos = pos})
	end
	local enemy_copy = utils.copy_table(enemy)
	enemy_copy.max_health = enemy_copy.max_health + level.depth * 2
	M.set_level_tile(level.id, pos.x, pos.y, {is_enemy_core = true, enemy = enemy_copy})
end

function M.set_passage(level, pos, type, settings)
	table.insert(level.passages, {type = type, pos = pos})
	M.set_level_tile(level.id, pos.x, pos.y, {
		ground = M.GROUND_TYPES.CRACK,
		passage_type = type,
		is_crack = true,
	})
	if settings.guarded then
		local depth = level.depth
		if depth > 15 then
			M.set_enemy(level, pos, M.ENEMY.lava_red)
		elseif depth > 10 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_red)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			end
		elseif depth > 5 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			end
		else
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_yellow)
			end
		end
	end
end

function M.create_passages(level, tiles, depth, settings)
	if settings == nil then
		settings = {}
	end
	local rd = depth % 10
	-- if depth == 0 then
	-- 	local pos = utils.extract_random(tiles)
	-- 	while M.get_level_tile(level.id, pos.x, pos.y).is_building or M.get_level_tile(level.id, pos.x, pos.y).is_item or (level.type == M.LEVEL_TYPE.SHOP and pos.y > level.center.y - 2) do
	-- 		pos = utils.extract_random(tiles)
	-- 	end
	-- 	M.set_passage(level, pos, M.LEVEL_TYPE.SECOND, settings)
	-- else
	if depth == 0 then
		M.set_passage(level, {x = level.center.x, y = level.center.y}, M.LEVEL_TYPE.COMMON, settings)
	elseif rd == 9 then
		local pos = utils.extract_random(tiles)
		while M.get_level_tile(level.id, pos.x, pos.y).is_building or M.get_level_tile(level.id, pos.x, pos.y).is_item or (level.type == M.LEVEL_TYPE.SHOP and pos.y > level.center.y - 2) do
			pos = utils.extract_random(tiles)
		end
		M.set_passage(level, pos, M.LEVEL_TYPE.BOSS, settings)
	elseif rd == 0 then
		M.set_passage(level, {x = level.center.x, y = level.center.y}, M.LEVEL_TYPE.COMMON, settings)
	else
		local passages_n = math.random(2, 3)
		local options = {M.LEVEL_TYPE.COMMON, M.LEVEL_TYPE.COMMON, M.LEVEL_TYPE.COMMON, M.LEVEL_TYPE.HARD, M.LEVEL_TYPE.HARD, M.LEVEL_TYPE.HEAL}
		if rd == 3 or rd == 7 then
			options = {M.LEVEL_TYPE.SHOP, M.LEVEL_TYPE.HEAL}
		end
		for i = 1, math.min(passages_n, #options) do
			local pos = utils.extract_random(tiles)
			while M.get_level_tile(level.id, pos.x, pos.y).is_building or M.get_level_tile(level.id, pos.x, pos.y).is_item or (level.type == M.LEVEL_TYPE.SHOP and pos.y > level.center.y - 2) do
				pos = utils.extract_random(tiles)
			end
			local type = utils.extract_random(options)
			M.set_passage(level, pos, type, settings)
		end
	end
end

function M.try_set_building(level, pos, building)
	for _, offset in ipairs(building.restricted) do
		if M.get_level_tile(level.id, pos.x + offset.x, pos.y + offset.y).is_barrier == true then
			return false
		end
	end
	for _, offset in ipairs(building.restricted) do
		M.set_level_tile(level.id, pos.x + offset.x, pos.y + offset.y, M.TILES.empty.tile)
		M.set_level_tile(level.id, pos.x + offset.x, pos.y + offset.y, {is_building = true, building_core_pos = pos})
	end
	M.set_level_tile(level.id, pos.x, pos.y, {is_building_core = true, building = building})
	return true
end

function M.set_shop_item(level, pos, item)
	M.set_level_tile(level.id, pos.x, pos.y, M.TILES.empty.tile)
	M.set_level_tile(level.id, pos.x, pos.y, {item = item, is_item = true, cost = item.cost})
end

function M.generate_level_heal(depth)
	local level, tiles = M.generate_level_core_medium(depth)
	level.type = M.LEVEL_TYPE.HEAL
	local tile = utils.get_random(tiles)
	local unused = {}
	while not M.try_set_building(level, tile, M.BUILDINGS.heal) do
		tile = utils.extract_random(tiles)
		table.insert(unused, tile)
	end
	for _, v in ipairs(unused) do
		table.insert(tiles, v)
	end
	M.create_passages(level, tiles, depth)
	return level
end

function M.generate_level_shop(depth)
	local level, tiles = M.generate_level_core_shop(depth)
	level.type = M.LEVEL_TYPE.SHOP
	for i = -2, 2, 2 do
		if i == 2 then
			local rarity = it.ITEM_RARITY.EPIC
			M.set_shop_item(level, {x = level.center.x + i, y = level.center.y}, it.create_item(rarity))
			M.set_level_tile(level.id, level.center.x + i, level.center.y, {ad_item = true})
		else
			local rarity = utils.dict_get_random(it.ITEM_RARITY)
			M.set_shop_item(level, {x = level.center.x + i, y = level.center.y}, it.create_item(rarity))
		end
	end
	M.create_passages(level, tiles, depth)
	return level
end

function M.generate_level_boss(depth)
	local level, tiles = M.generate_level_core_large(depth)
	level.type = M.LEVEL_TYPE.BOSS
	if depth == 10 then
		M.set_enemy(level, {x = level.center.x, y = level.center.y}, M.ENEMY.lava_boss_grey)
	else
		M.set_enemy(level, {x = level.center.x, y = level.center.y}, M.ENEMY.lava_boss_red)
	end
	M.create_passages(level, tiles, depth)
	return level
end

function M.generate_level_hard(depth)
	local level, tiles
	if depth < 7 then
		level, tiles = M.generate_level_core_medium(depth)
	else
		level, tiles = M.generate_level_core_large(depth)
	end
	level.type = M.LEVEL_TYPE.HARD

	local enemy_count = math.random(2, 3)

	for i = 1, enemy_count do
		local pos = extract_random(tiles)
		if depth > 15 then
			M.set_enemy(level, pos, M.ENEMY.lava_red)
		elseif depth > 10 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_red)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			end
		elseif depth > 5 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			end
		else
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_yellow)
			end
		end
	end
	
	M.create_passages(level, tiles, depth, {guarded = true})

	return level
end

function M.generate_level_common(depth)
	local level, tiles
	if depth < 7 then
		level, tiles = M.generate_level_core_medium(depth)
	else
		level, tiles = M.generate_level_core_large(depth)
	end
	level.type = M.LEVEL_TYPE.COMMON

	local enemy_count = math.random(2, 3)

	for i = 1, enemy_count do
		local pos = extract_random(tiles)
		if depth > 15 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_red)
			end
		elseif depth > 10 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_blue)
			end
		elseif depth > 5 then
			if math.random() > 0.8 then
				M.set_enemy(level, pos, M.ENEMY.lava_yellow)
			else
				M.set_enemy(level, pos, M.ENEMY.lava_grey)
			end
		else
			M.set_enemy(level, pos, M.ENEMY.lava_yellow)
		end
	end

	M.create_passages(level, tiles, depth)
	
	return level
end

function M.generate_level_first(depth)
	local level, tiles = M.generate_level_core_small(depth)
	level.type = M.LEVEL_TYPE.FIRST
	M.create_passages(level, tiles, depth)
	return level
end

function M.generate_level_second(depth)
	local level, tiles = M.generate_level_core_small(depth)
	level.type = M.LEVEL_TYPE.SECOND
	M.set_enemy(level, {x = level.center.x, y = level.center.y}, M.ENEMY.lava_yellow)
	M.set_item(level, {x = level.center.x + 1, y = level.center.y}, it.create_item(it.ITEM_RARITY.COMMON, {type = it.ITEM_TYPE.PICKAXE}))
	M.set_level_tile(level.id, level.center.x + 1, level.center.y + 1, {drop_sword = true})
	M.create_passages(level, tiles, depth)
	return level
end

function M.generate_cave_from_preset(depth, row_n, preset)
	if cave_by_coordinates[depth] == nil or cave_by_coordinates[depth][row_n] == nil or cave_by_coordinates[depth][row_n].id == nil then
		return -1 
	end

	local cave = cave_by_coordinates[depth][row_n]

	if cave.generated then
		return cave.id
	end
	cave.generated = true

	for xx = 1, cave.width do
		for yy = 1, cave.height do
			local background = tilemap.get_tile(preset, "background", xx, yy)
			local ground = tilemap.get_tile(preset, "ground", xx, yy)
			local content = tilemap.get_tile(preset, "content", xx, yy)
			local cover = tilemap.get_tile(preset, "cover", xx, yy)
			for _, tt in pairs(M.TILES) do
				if tt.mark == cover then
					M.set_level_tile(cave.id, xx, yy, tt.tile)
				end
			end
			local mark = tilemap.get_tile(preset, "mark", xx, yy)
			local tunnel_id
			local tunnel_level_passage
			if mark == M.PRESET_MARK.DOWN_LEFT then
				tunnel_id = cave.down[0]
				tunnel_level_passage = M.levels[tunnel_id].up
			elseif mark == M.PRESET_MARK.DOWN_RIGHT then
				tunnel_id = cave.down[1]
				tunnel_level_passage = M.levels[tunnel_id].up
			elseif mark == M.PRESET_MARK.UP_LEFT then
				tunnel_id = cave.up[-1]
				tunnel_level_passage = M.levels[tunnel_id].down
			elseif mark == M.PRESET_MARK.UP_RIGHT then
				tunnel_id = cave.up[0]
				tunnel_level_passage = M.levels[tunnel_id].down
			elseif mark == M.PRESET_MARK.BATTERY_MAKER then
				M.set_level_tile(cave.id, xx,yy, {
					building = M.BUILDING_DESCRIPTION[mark],
				})
			elseif mark == M.PRESET_MARK.UPGRADE then
				M.set_level_tile(cave.id, xx,yy, {
					building = M.BUILDING_DESCRIPTION[mark],
				})
			end
			local is_barrier = false
			if cover == M.COVER_TYPES.BARRIER then
				is_barrier = true
			end
			if tunnel_id ~= nil then
				M.set_level_tile(cave.id, xx,yy, {
					passage = tunnel_id,
				})
				tunnel_level_passage.position = {
					x = xx + cave.global.x,
					y = yy + cave.global.y,
				}
			end

			if ground == M.GROUND_TYPES.CRACK then
				M.set_level_tile(cave.id, xx,yy, {
					is_crack = true,
				})
			end

			for ore, crack in pairs(M.ORE_CRACKS) do
				if ground == crack then
					M.set_level_tile(cave.id, xx,yy, {
						is_crack = true,
					})
				end
			end
			
			M.set_level_tile(cave.id, xx, yy, {
				background = background,
				ground = ground,
				content = content,
				cover = cover,
				ore = 0,
				is_barrier = is_barrier,
			})
		end
	end
	M.apply_buildings(depth, row_n)
end

function M.generate_tunnel(g1, p1, g2, p2)
	local tunnel = get_new_level()
	tunnel.standalone = true
	local up = {x = g1.x + p1.x, y = g1.y + p1.y}
	local down = {x = g2.x + p2.x, y = g2.y + p2.y}
	if tunnel.generated then
		return
	end
	tunnel.generated = true
	
	tunnel.global = {
		x = math.min(up.x, down.x) - 1,
		y = math.min(up.y, down.y) - 1
	}
	tunnel.width = math.abs(up.x - down.x) + 1
	tunnel.height = math.abs(up.y - down.y) + 1

	local down_x = down.x - tunnel.global.x
	local down_y = down.y - tunnel.global.y
	local up_x = up.x - tunnel.global.x
	local up_y = up.y - tunnel.global.y
	
	local path = connect_tiles({x = down_x, y = down_y}, {x = up_x, y = up_y})

	for _, tile in ipairs(path) do
		M.set_level_tile(tunnel.id, tile.x, tile.y, {is_tunnel = true})
	end

	-- M.set_level_tile(tunnel.id, down_x, down_y, {
	-- 	ground = M.GROUND_TYPES.DOWN,
	-- 	passage = tunnel.down.id
	-- })

	-- M.set_level_tile(tunnel.id, up_x, up_y, {
	-- 	-- ground = M.GROUND_TYPES.UP,
	-- 	passage = tunnel.up.id
	-- })
end

function M.get_level(level_id)
	local level = M.levels[level_id]
	-- if level.layer == "tunnel" then
	-- 	return level
	-- end
	-- local depth = level.depth
	-- local row_n = level.row_n
	-- M.generate_cave(depth, row_n)
	-- M.generate_cave(depth + 1, row_n)
	-- M.generate_cave(depth + 1, row_n + 1)
	-- for _, tunnel_id in pairs(level.down) do
	-- 	M.generate_tunnel(tunnel_id)
	-- end
	
	-- defsave.set("mapdata", "tunnels", M.tunnels)
	-- defsave.set("mapdata", "levels", M.levels)
	-- defsave.save("mapdata")
	
	return level
end

local ore_gen_depth = {
	coal = 3,
	copper = 10,
	iron = 17,
}


local function set_ore(ore_settings, depth, main_ore)
	for ore, g_depth in pairs(ore_gen_depth) do
		if main_ore == ore then
			ore_settings[ore] = math.min(ore_settings[ore] + 1, 3)
		elseif depth >= g_depth then
			if not ore_settings[ore] then
				ore_settings[ore] = 0
			end
			ore_settings[ore] = math.max(ore_settings[ore] - 1, 0)
		end
	end
end

function M.next_level(level_id, passage_tile)
	if level_id == nil then
		return M.generate_level_first(0)
	end
	
	local level = M.levels[level_id]
	local depth = level.depth + 1

	local new_level 
	if not passage_tile then
		new_level = M.generate_level_first(0)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.BOSS then
		new_level = M.generate_level_boss(depth)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.COMMON then
		new_level = M.generate_level_common(depth)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.HARD then
		new_level = M.generate_level_hard(depth)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.HEAL then
		new_level = M.generate_level_heal(depth)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.SHOP then
		new_level = M.generate_level_shop(depth)
	elseif passage_tile.passage_type == M.LEVEL_TYPE.SECOND then
		new_level = M.generate_level_second(depth)
	end
	
	return new_level
end

function M.set_level(level)
	M.levels[level.id] = level
end

function M.init_map()
	-- defsave.load("mapdata")
	-- defsave.get("mapdata", "map")
	-- if #M.levels == 0 then
		-- M.generate_map()
	-- end
	-- M.generate_cave(1, 1)
	-- M.generate_cave_from_preset(1, 1, "mines:/root#level_1_1")
	local level = M.generate_level_second(0)
	-- local level = M.generate_level_shop(0)
	-- local level = M.generate_level_heal(0)
	-- level.depth = 0
	-- level.global = {x = 0, y = 0}
	-- M.save()
	return level
end

return M