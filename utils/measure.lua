local M = {}

local measures = {}

local MEASURE_OUTPUT_ENABLED = false

local function measure_new(measure_name)
	measures[measure_name] = {
		steps = {},
		step_last_delta = {},
		step_max_delta = {},
	}
end

function M.measure_start(measure_name)
	if not measures[measure_name] then
		measure_new(measure_name)
	end
	local measure = measures[measure_name]
	local time = os.clock()
	measure.steps = {}
	table.insert(measure.steps, "start")
	measure.step_last_delta["start"] = time
end

function M.measure_end(measure_name)
	if not measures[measure_name] then
		return
	end
	local measure = measures[measure_name]
	local time = os.clock()
	local last = measure.steps[#measure.steps]
	measure.step_last_delta[last] = time - measure.step_last_delta[last]
	measure.step_max_delta[last] = math.max(measure.step_max_delta[last] or 0, measure.step_last_delta[last])
end

function M.step(measure_name, name)
	if not measures[measure_name] then
		return
	end
	local measure = measures[measure_name]
	local time = os.clock()
	local last = measure.steps[#measure.steps]
	measure.step_last_delta[last] = time - measure.step_last_delta[last]
	measure.step_max_delta[last] = math.max(measure.step_max_delta[last] or 0, measure.step_last_delta[last])
	measure.step_last_delta[name] = time
	table.insert(measure.steps, name)
end

function M.print_stats(measure_name)
	if not measures[measure_name] or not MEASURE_OUTPUT_ENABLED then
		return
	end
	local measure = measures[measure_name]
	
	local last_sum = 0
	local fragmented_max_sum = 0
	
	print("================")
	print(string.format("MEASURE DATA: %s", measure_name))
	print(string.format(" MAX     LAST"))
	for i, name in ipairs(measure.steps) do
		print(string.format("[%.3f] [%.3f] - %s", measure.step_max_delta[name], measure.step_last_delta[name], name))
		last_sum = last_sum + measure.step_last_delta[name]
		fragmented_max_sum = fragmented_max_sum + measure.step_max_delta[name]
	end
	print(string.format("[%.3f] - FRAGMENTED MAX SUM (1/%d sec)", fragmented_max_sum, math.ceil(1 / fragmented_max_sum)))
	print("MEASURE DATA END")
	print("================")
end

------------------------------------------------
function M.Upack(...)
	local res = {}
	for k,v in pairs({...}) do
		table.insert(res, v)
	end
	return res
end

function M.profile_scope_begin(scope_name)
	if profiler then
		profiler.scope_begin(scope_name or "begin scope")
	end
end

function M.profile_scope_end()
	if profiler then
		profiler.scope_end()
	end
end

function M.profile_function(scope_name, func, ...)
	local result = nil
	if profiler then
		profiler.scope_begin(scope_name or "begin scope")
		result = M.Upack(func(unpack({...})))
		profiler.scope_end()
	else
		result = M.Upack(func(unpack({...})))
	end
	return unpack(result)
end
--------------------------------------------


return M
