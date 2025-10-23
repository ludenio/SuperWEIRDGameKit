local M = {}

M.host = false
M.snap_flag = false
M.measure_start = nil

M.tick = 0

M.elements = {}
M.recipes = {}
M.sources = {}
M.foundations = {}
M.waves = {}
M.enemies = {}
M.locations = {}
M.mines = {}
M.miners = {}

M.are_actions_local = true

M.npc_prog_targets = {}

M.NPC_PROG_OPTIONS = {
	NONE = 0,
	MINE = 1,
	TAKE_FROM = 2,
	PUT_IN = 3,
	DELETE = 4,
}

return M
