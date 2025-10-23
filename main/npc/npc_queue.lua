local M = {}

--=========================QUEUE ORGANIZATION=========================
M.queues = {}
M.ticketers = {}

function M.check_ticket(npc_uid)
	if M.ticketers[npc_uid] then
		local object_uid = M.ticketers[npc_uid]
		if M.queues[object_uid] then
			for k,v in pairs(M.queues[object_uid]) do
				if v == npc_uid then
					return k
				end
			end
		end
	end
	return nil
end


function M.remove_ticket(npc_uid)
	if M.ticketers[npc_uid] then
		local object_uid = M.ticketers[npc_uid]
		if M.queues[object_uid] and M.check_ticket(npc_uid) then
			table.remove(M.queues[object_uid], M.check_ticket(npc_uid))
		end
		M.ticketers[npc_uid] = nil
	end
end

function M.get_ticket(object_uid, npc_uid)
	if object_uid == M.ticketers[npc_uid] then
		return M.check_ticket(npc_uid)
	end

	if M.ticketers[npc_uid] then
		M.remove_ticket(npc_uid)
	end

	M.queues[object_uid] = M.queues[object_uid] or {}
	table.insert(M.queues[object_uid], npc_uid)
	M.ticketers[npc_uid] = object_uid
	return #M.queues[object_uid]
end
--=========================QUEUE ORGANIZATION=========================
-----------------------------------------------------------------------

return M