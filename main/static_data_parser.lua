local data = require "main.data"
local pack = require "utils.pack"

local M = {}

local COLORS = {
	white = vmath.vector4(1, 1, 1, 0.5),
	sun_ = vmath.vector4(1, 1, 1, 2),
}

function M.parse(static_data)
	local static = static_data

	for i, e_table in pairs(static.elements) do
		e_table.light = COLORS[e_table.light]
		data.elements[e_table.name] = e_table
	end

	for i, e_table in pairs(static.recipes) do
		data.recipes[e_table.name] = e_table
	end

	for i, e_table in pairs(static.sources) do
		data.sources[e_table.name] = e_table
	end

	for _, e_table in pairs(static.locations_art_test) do
		data.locations[e_table.id] = e_table
	end

	local last_available = 1

	for _, table_name in pairs({"foundations_art_test"}) do
		print(table_name)
		for i, e_table in pairs(static[table_name]) do
			data[table_name] = data[table_name] or {}
			data[table_name][e_table.tag] = e_table
			
			if e_table.revealed_count ~= "" then
				data[table_name][e_table.tag].to_reveal = 1 + e_table.revealed_count - last_available
				last_available = e_table.revealed_count
			else
				data[table_name][e_table.tag].to_reveal = 1
			end
			
			if e_table.unlocked ~= true then
				e_table.unlocked = nil
			end

			if e_table.guard_radius ~= "" then
				data[table_name][e_table.tag].guard_radius = e_table.guard_radius
			end
			data[table_name][e_table.tag].spawned = false
		end
	end
end

return M