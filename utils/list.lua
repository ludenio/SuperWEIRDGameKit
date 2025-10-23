local List = {}

function List.new ()
	return {first = 2, last = 1, values = {}}
end

-- function List.pairs(list)
-- 	return pairs(list.values)
-- end

function List.get_first(list)
	return list.first
end

function List.get_last(list)
	return list.last
end

function List.size(list)
	return list.last - list.first + 1
end

function List.empty(list)
	return list.first > list.last
end

function List.pushleft (list, value)
	local first = list.first - 1
	list.first = first
	list.values[first] = value
end

function List.pushright (list, value)
	local last = list.last + 1
	list.last = last
	list.values[last] = value
end

function List.popleft (list)
	local first = list.first
	if first > list.last then error("list is empty") end
	local value = list.values[first]
	list.values[first] = nil        -- to allow garbage collection
	list.first = first + 1
	return value
end

function List.popright (list)
	local last = list.last
	if list.first > last then error("list is empty") end
	local value = list.values[last]
	list.values[last] = nil         -- to allow garbage collection
	list.last = last - 1
	return value
end

function List.remove (list, index)
	assert(list.values[index], "index out of bounds")
	local queue = {}
	for i = index, List.get_last(list) do
		queue[i] = List.popright(list)
	end

	queue[index] = nil

	for k,v in pairs(queue) do
		List.pushright(list, v)
	end
	return queue
end
return List
