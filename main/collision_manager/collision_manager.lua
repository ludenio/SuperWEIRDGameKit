local data = require "main.data"

local M = {}

local tile_size = 64

function M.pos_to_tile(x,y, model)
    local tileX = math.floor(x / tile_size) + 1
    local tileY = math.floor(y / tile_size) + 1
    return tileX, tileY
end

function M.tile_to_pos(tile_x, tile_y, model)
    return (tile_x - 1) * tile_size + tile_size / 2, (tile_y - 1) * tile_size + tile_size / 2
end

function M.tile128_to_pos(tile_x, tile_y, model)
    return (tile_x - 1) * 128 + 64, (tile_y - 1) * 128 + 64
end

function M.pos_to_tile128(x, y, model)
    return math.floor(x / 128) + 1, math.floor(y / 128) + 1
end

function M.set_128collision(tile_x,tile_y, model)
    local to64tiles = {{x = tile_x * 2, y = tile_y * 2}, {x = tile_x * 2 - 1, y = tile_y * 2}, {x = tile_x * 2, y = tile_y * 2 - 1}, {x = tile_x * 2 - 1, y = tile_y * 2 - 1}}
    for _, tile in ipairs(to64tiles) do
        if model.collision_matrix[tile.x] == nil then
            model.collision_matrix[tile.x] = {}
        end
        model.collision_matrix[tile.x][tile.y] = true

        -- local go_name = data.locations[model.id].go_name
        -- tilemap.set_tile(go_name .. "#ground","debug", tile.x, -tile.y + 1, 95)
    end
end

function M.set_128collision_by_pos(x,y, model)
    local tile_x, tile_y = M.pos_to_tile128(x, y, model)
    M.set_128collision(tile_x,tile_y, model)
end

function M.set_collision(tile_x,tile_y, model, object_uid)
    if model.collision_matrix[tile_x] == nil then
        model.collision_matrix[tile_x] = {}
    end
    model.collision_matrix[tile_x][tile_y] = object_uid or true
    -- local go_name = data.locations[model.id].go_name
    -- tilemap.set_tile(go_name .. "#ground","debug", tile_x, -tile_y + 1, 95)
end

function M.set_collision_by_pos(x,y, model, object_uid)
    local tile_x, tile_y = M.pos_to_tile(x, y, model)
    M.set_collision(tile_x,tile_y, model, object_uid)
end

function M.delete_collision(tile_x,tile_y, model)
    model.collision_matrix[tile_x][tile_y] = nil
    -- local go_name = data.locations[model.id].go_name
    -- tilemap.set_tile(go_name .. "#ground","debug", tile_x, -tile_y + 1, 0)
end

function M.delete_collision_by_pos(x,y, model)
    local tile_x, tile_y = M.pos_to_tile(x, y, model)
    M.delete_collision(tile_x,tile_y, model)
end


--now this module just checking "is tile passable", in future we can get a concrete object data though this collision
function M.init_collision(x,y,w,h, model)
    model.collision_matrix = {}
    for X = x, x + w, 1 do
        model.collision_matrix[X] = {}
        -- for Y = y, y + h, 1 do
        --     model.collision_matrix[X][Y] = false
        -- end
    end
end

function M.get_collision(x,y, model)
    -- print("x: ", x, "y: ", y)
    local tile_x, tile_y = M.pos_to_tile(x,y)
    -- print("tile_x: ", tile_x, "tile_y: ", tile_y)

    if model.collision_matrix[tile_x] then
        return model.collision_matrix[tile_x][tile_y] or false
    end
    return false
end

function M.get_tile_collision(tile_x, tile_y, model)
    if model.collision_matrix[tile_x] then
        return model.collision_matrix[tile_x][tile_y] or false
    end
    return false
end

return M