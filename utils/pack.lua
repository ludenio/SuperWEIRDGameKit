local M = {}

local PACK_TYPES = {
	VECTOR3 = 1,
	VECTOR4 = 2,
	QUAT = 3
}

function M.pack_vec3(vec)
	return {x = vec.x, y = vec.y, z = vec.z, packtype = PACK_TYPES.VECTOR3}
end

function M.unpack_vec3(t)
	return vmath.vector3(t.x, t.y, t.z)
end

function M.pack_quat(quat)
	return {x = quat.x, y = quat.y, z = quat.z, w = quat.w, packtype = PACK_TYPES.QUAT}
end

function M.unpack_quat(t)
	return vmath.quat(t.x, t.y, t.z, t.w)
end

function M.pack_vec4(quat)
	return {x = quat.x, y = quat.y, z = quat.z, w = quat.w, packtype = PACK_TYPES.VECTOR4}
end

function M.unpack_vec4(t)
	return vmath.vector4(t.x, t.y, t.z, t.w)
end

local function prop_exist(object, prop)
	return pcall(function() return object[prop] end)
end

function M.pack_data(table)
	assert(table)
	for k,v in pairs(table) do
		if type(v) == "table" then
			table[k] = M.pack_data(v)
		elseif type(v) == "userdata" and prop_exist(v, "x") then
			if types.is_vector4(v) then
				table[k] = M.pack_vec4(v)
			elseif types.is_vector3(v) then
				table[k] = M.pack_vec3(v)
			elseif types.is_quat(v) then
				table[k] = M.pack_quat(v)
			end
		else
			table[k] = v
		end
	end
	return table
end

function M.pack_data_copy(table)
	assert(table)
	local new_table = {}
	for k,v in pairs(table) do
		if type(v) == "table" then
			new_table[k] = M.pack_data_copy(v)
		elseif type(v) == "userdata" and prop_exist(v, "x") then
			if types.is_vector4(v) then
				new_table[k] = M.pack_vec4(v)
			elseif types.is_vector3(v) then
				new_table[k] = M.pack_vec3(v)
			elseif types.is_quat(v) then
				new_table[k] = M.pack_quat(v)
			end
		else
			new_table[k] = v
		end
	end
	return new_table
end

function M.unpack_data(table)
	assert(table)
	for k,v in pairs(table) do
		if type(v) == "table" then
			if v.packtype then
				if v.packtype == PACK_TYPES.VECTOR3 then
					table[k] = M.unpack_vec3(v)
				elseif v.packtype == PACK_TYPES.VECTOR4 then
					table[k] = M.unpack_vec4(v)
				elseif v.packtype == PACK_TYPES.QUAT then
					table[k] = M.unpack_quat(v)
				end
			else
				table[k] = M.unpack_data(v)
			end
		else
			table[k] = v
		end
	end
	return table
end

return M
