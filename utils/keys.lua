local M = {}

M.CONNECT = hash("F1")
M.DISCONNECT = hash("F2")
M.CREATE_ROOM = hash("F3")
M.JOIN_ROOM = hash("F4")
M.SEND_DATA = hash("F6")

M.SAVE = hash("F5")
M.LOAD = hash("F9")

M.UP = hash("up")
M.LEFT = hash("left")
M.DOWN = hash("down")
M.RIGHT = hash("right")
M.INTERACT = hash("interact")
M.ROTATE_LEFT = hash("rotate_left")
M.ROTATE_RIGHT = hash("rotate_right")
M.TOUCH = hash("touch")

M.SPAWN_BUYER = hash("B")
M.DEBUG = hash("F5")
M.DEBUG2 = hash("F6")
M.DEBUG3 = hash("F7")


return M