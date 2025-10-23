local collision_manager = require "main.collision_manager.collision_manager"
local actions = require "main.sys.actions"
local setup_map_data = require "main.maps.setup_map_data"
local data = require "main.data"

local M = {}

local function ground_processer(setup_tile_index, x, y, add_action_callback, location)
    tilemap.set_tile("ground#ground","layer1", x, y, setup_tile_index)
end

local function static_collisions_processer(setup_tile_index, x, y, add_action_callback, location)
    if setup_tile_index == 32 then
        collision_manager.set_128collision(x,y, location)
    end
end

local function static_sprites_processer(setup_tile_index, x, y, add_action_callback, location)
    if setup_tile_index == 0 then
        return
    end
    local px, py = collision_manager.tile128_to_pos(x, y)
    local pos = vmath.vector3(px, 0, py)
    local action = nil
    if setup_tile_index == setup_map_data.STATIC_SPRITES.BIPKA then
        action = actions.spawn_sprite(pos + vmath.vector3(0, 0, 64), "bipka", true)
    end

    for i = 1, setup_map_data.STATIC_SPRITES.SPRITES_END - setup_map_data.STATIC_SPRITES.SPRITES_START + 1 do
        if setup_tile_index == setup_map_data.STATIC_SPRITES.SPRITES_START + i - 1 then
            local sprite = "s" .. tostring(i)
            action = actions.spawn_sprite(pos + vmath.vector3(0, 0, 0), sprite)
        end
    end
    
    if action then
        add_action_callback(action)
    end
end


local function buildings_processer(setup_tile_index, x, y, add_action_callback, location)
    local px, py = collision_manager.tile128_to_pos(x, y)
    local pos = vmath.vector3(px, 0, py)
    local action = nil

    if setup_tile_index == setup_map_data.BUILDINGS.TRASHCAN then
        action = actions.spawn_trashcan(pos)
    end

    for i = 1, setup_map_data.BUILDINGS.FOUNDATION_END - setup_map_data.BUILDINGS.FOUNDATION_START + 1 do
        if setup_tile_index == setup_map_data.BUILDINGS.FOUNDATION_START + i - 1 then
            local tag = "F" .. tostring(i)
            local foundations_cfg = data.locations[location.id].foundation_config
            print("foundations_cfg: ", foundations_cfg)
            if data[foundations_cfg][tag] then
                data[foundations_cfg][tag].location_id = location.id
                
                data[foundations_cfg][tag].spawned = true
                action = actions.spawn_foundation(pos, tag, foundations_cfg)
            else
                print("WARNING: no static data found for foundation tag", tag, "from setup map")
            end
        end
    end
    if action then
        add_action_callback(action)
    end
end

local function _init_parce(add_action_callback, location)
    local setup_map_layers = {
        --ground = ground_processer,
        static_collisions = static_collisions_processer,
        buildings = buildings_processer,
        static_sprites = static_sprites_processer,
    }

    local go_name = data.locations[location.id].go_name

    for layer, processer in pairs(setup_map_layers) do
        local x_border,y_border,w_border,h_border = tilemap.get_bounds(msg.url("main", "/".. go_name, "setup"), layer)
        w_border, h_border = w_border -1, h_border -1
        if layer == "static_collisions" then
            collision_manager.init_collision(x_border,y_border,w_border,h_border, location)
        end
        location.map_size = {x = x_border, y = y_border, w = w_border, h = h_border}

        for x = x_border, x_border + w_border, 1 do
            for y = y_border, y_border + h_border, 1 do
                local tile_id 
                if layer == "buildings" and location.id == 1 then
                    tile_id = tilemap.get_tile(msg.url("main", "/"..go_name, "building_setup"), layer, x, y)
                else
                    tile_id = tilemap.get_tile(msg.url("main", "/".. go_name, "setup"), layer, x, y)
                end
                -- print("x: ", x, "y: ", y, "tile_id: ", tile_id)
                if layer == "ground" then
                    processer(tile_id, x, y, add_action_callback, location)
                elseif layer == "static_collisions" then
                    processer(tile_id, x, 1-y, add_action_callback, location)
                else
                    processer(tile_id, x, 1-y, add_action_callback, location)
                end
            end
        end

      --  print("go_name: ", go_name .. "#setup", "layer: ", layer)
        tilemap.set_visible(msg.url("main", "/".. go_name, "setup"), layer, false)
        if layer == "buildings" and location.id == 1 then
            tilemap.set_visible(msg.url("main", "/"..go_name, "building_setup"), layer, false)
        end
    end
end

function M.init_parce(add_action_callback, model)
    for location_id, location in pairs(model.locations) do
        _init_parce(add_action_callback(location_id), location)
    end
end

return M
