local M ={}
local measure = require('utils.measure')


function M.copy_table(table)
	assert(table)
	local new_table = {}
	for k,v in pairs(table) do
		
		if type(v) == "table" then
			if type(k) == "string" then
				new_table[k] = measure.profile_function(k, M.copy_table, v)
			else
				new_table[k] = M.copy_table(v)
			end
		elseif types.is_vector3(v) then
			new_table[k] = vmath.vector3(v)
		elseif types.is_vector4(v) then
			new_table[k] = vmath.vector4(v)
		else
			new_table[k] = v
		end
	end
	return new_table
end

---------------------------------------------
function M.createTable(width, height, spacer)
	local t = {}
	for i = 1, width do
		table.insert(t, {})
		for j = 1, height do
			t[i][j] = spacer
		end
	end
	return t
end

-------------------------------------------
function M.boolFromNum(num)
	if num == 1 then
		return true
	else
		return false
	end
end
-----------------------------------------

function M.get_z(yPos, base_z)	--генерирует Z координату в заданном диапазоне на основе yPos (от low_2 до high_2 + base_z)
	--слои тайлмапы распределены по Z в редакторе, при указании  base_z нужно учитывать эти значения
	local   low   		= 5000
	local   high   		= 1 -- по уму, надо бы - settings.world_max_h ,но чтоб кросслинк модулей не словить, захардкодим
	local  	value   	= yPos
	local  	low_2   	= 0.001
	local   high_2   	= 0.002
	local 	base		= base_z or 0.00

	local relative_value = (value - low) / (high - low)
	local scaled_value = low_2 + (high_2 - low_2) * relative_value
	return (scaled_value + base)
end

--------------------------------------------

function M.get_random(t)
	return t[math.random(#t)]
end

function M.extract_random(t) 
	local i = math.random(#t)
	local item = t[i]
	table.remove(t, i)
	return item
end

function M.dict_get_random(d)
	local keys = {}
	for k, _ in pairs(d) do
		table.insert(keys, k)
	end
	return d[M.get_random(keys)]
end

return M