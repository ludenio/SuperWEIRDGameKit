local M = {}

local LIGHTS_ON = false

local light_sources = {}

local light_recievers = {}

local global_directional_light = {
	direction = vmath.vector3(0, 0, 0),
	color = vmath.vector4(1, 1, 1, 0),
}

local global_ambient_light = {
	color = vmath.vector4(1, 1, 1, 0.8),
}

function M.update_global_directional_light(direction, color)
	global_directional_light.direction = direction
	global_directional_light.color = color
end

function M.update_global_ambient_light(color)
	global_ambient_light.color = color
end

function M.add_light_source(id, collection, color, height)
	light_sources[id] = {color = color, collection = collection}
end

function M.update_light_source_power(id, power)
	light_sources[id].color.w = power
end

function M.remove_light_source(id)
	light_sources[id] = nil
end

function M.add_light_reciever(id, collection, material_component, light_component)
	light_recievers[id] = {collection = collection, material_component = material_component}
	if light_component then
		light_recievers[id].light_component = light_component
	end
end

function M.remove_light_reciever(id)
	if light_recievers[id] then
		light_recievers[id] = nil
	end
end

function M.update_highlight_power(id, power)
	if light_recievers[id] then
		light_recievers[id].highlight_power = power
	end
end

function M.update_rotations()
	if not LIGHTS_ON then
		return
	end
	for id, data in pairs(light_recievers) do
		local url = data.material_component
		local quat = go.get_rotation(id)
		local rot_mtx = vmath.matrix4_from_quat(quat)
		go.set(url, "iRotation", rot_mtx)
	end
end

function M.update()
	if not LIGHTS_ON then
		return
	end
	for id, data in pairs(light_sources) do
		data.position = go.get_world_position(id)
	end
	for id, data in pairs(light_recievers) do
		local url = data.material_component
		local position = go.get_world_position(id)
		local distances = {}
		for source_id, source_table in pairs(light_sources) do
			if not (data.light_component and light_sources[data.light_component]) then
				local distance = vmath.length(position - source_table.position)
				table.insert(distances, {distance = distance, id = source_id})
			end
		end
		table.sort(distances, function(lhs, rhs) return lhs.distance < rhs.distance end)
		go.set(url, "directional_direction", vmath.vector4(global_directional_light.direction.x, global_directional_light.direction.y, global_directional_light.direction.z, 0))
		go.set(url, "directional_color", global_directional_light.color)
		local ambient = global_ambient_light.color
		if light_recievers[id].light_component then
			local cl = light_sources[data.light_component].color 
			ambient = cl
		end
		if light_recievers[id].highlight_power then
			local cl = ambient  + vmath.vector4(0, 0, 0, light_recievers[id].highlight_power / 2)
			ambient = cl
		end
		go.set(url, "ambient_color",  ambient)
		local lights_max = go.get(url, "lights_max").x
		local to_pass = math.min(lights_max, #distances)
		go.set(url, "light_source_count", vmath.vector4(to_pass, 0, 0, 0))
		if #distances > 0 then
			for i = 1, to_pass do
				local s_id = distances[i].id
				local s_pos = light_sources[s_id].position
				local s_col = light_sources[s_id].color
				go.set(url, "light_positions", vmath.vector4(s_pos.x, s_pos.y, s_pos.z, 0), {index = i})
				go.set(url, "light_colors", s_col, {index = i})
			end
		end
		if to_pass < lights_max then
			for i = to_pass + 1, lights_max do
				go.set(url, "light_positions", vmath.vector4(0), {index = i})
				go.set(url, "light_colors", vmath.vector4(0), {index = i})
			end
		end
	end
end

return M