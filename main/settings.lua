local M = {}

M.disconnect_timeout = 5

M.player_speed_x = 25
M.player_speed_y = 25
M.enemy_speed_x = M.player_speed_x / 2
M.enemy_speed_y = M.player_speed_y / 2

M.local_mode = true
M.skip_menu = true

M.enable_touch_input = true
M.hide_unreachable_foundations = false

M.foundation_hints = 6
M.foundation_revealed_count = 1

M.init_money = 85
M.init_health = 12

M.tower_init_load = 1

M.defauit_location_id = 1

-- for testing
-- M.init_money = 85
--

return M
