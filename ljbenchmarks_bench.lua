if not arg[1] then
	io.write("LuaJIT Benchmarks. Usage: luajit ljbenchmarks_bench.lua testfile.lua [--raw / --parseonly / --pure / --debug / --hook / --noansi / --wait / --nobeep / --pause]\n")

	return
end

arg_set = {} -- Command line arguments lookup

for i = 1, #arg do
	arg_set[arg[i]] = true
end

-- VM per-line debug
if arg_set["--hook"] then
	function trace(_, line)
		io.write(debug.getinfo(2).short_src .. ":" .. line, "\n")
	end

	debug.sethook(trace, "l")
end

-- For attaching debugger
if arg_set["--wait"] then
	os.execute("timeout 5")
end

io.stdout:setvbuf("no") -- Flush immediately
math.randomseed(os.time())
--
function GCCollect()
	collectgarbage()
	collectgarbage()
	collectgarbage("stop") -- GC bug in LuaJIT and Lua 5.1. You need to call stop again after manual cycle: https://github.com/LuaJIT/LuaJIT/issues/675
end

local clock = arg_set["--pure"] and os.clock or require("ljbenchmarks_clock") -- Requiring clock function used for measuring time
local memprof = require("ljbenchmarks_memprof") -- Requiring memory profiler
memprof.Enable()
local info = require("ljbenchmarks_testgen")

if not info then return end

local testoutput
info, testoutput = info[1], info[2]
----------------------
-- Setup
----------------------
local iterations = info.setup and info.setup[1] or 1000000

local function AbbreviateNumber(n)
	if n >= 1000000 then
		return math.floor(n / 1000000) .. "M"
	elseif n >= 1000 then
		return math.floor(n / 1000) .. "k"
	end

	return n
end

if jit then
	io.write("Testing ", arg[1], " on ", jit.version, " ", jit.status() and "jit.on" or "jit.off", ". Iterations: ", AbbreviateNumber(iterations), "\n")
	testoutput:write("`", arg[1], "`. ", jit.version, " ", jit.status() and "jit.on" or "jit.off", ". Iterations: ", AbbreviateNumber(iterations), "\n\n")
else
	io.write("Testing ", arg[1], " on ", _VERSION, ". Iterations: ", AbbreviateNumber(iterations), "\n")
	testoutput:write("`", arg[1], "`. ", _VERSION, ". Iterations: ", AbbreviateNumber(iterations), "\n\n")
end

GCCollect()

----------------------
-- clock warm-up to minimize the overhead
----------------------
for _ = 1, 1000 do
	clock()
end

----------------------
-- Benchmarking
----------------------
io.write("Benchmarking...\n")
local tests = info.tests

do
	local isdebug = arg_set["--debug"]
	local isnoansi = arg_set["--noansi"]
	local code = [[return function(clock, testpack)
	local samples = {}
	local gcsamples = {}
	local test = testpack[1]
	]] .. (info.reset and "local reset = testpack[2]" or "") .. [[

	-- Warm-up
	io.write("\tWarmup...]] .. (isnoansi and "\\n" or "") .. [[")

	for iteration = 1, ]] .. iterations .. [[ do
		test(]] .. (info.setup[2] and "iteration" or "") .. [[)
	end
	]] .. (info.reset and "reset()" or "") .. [[

	]] .. (isnoansi and "" or [[io.write("\027[1M")]]) .. [[

	local memprof = memprof
	local SetZone = memprof.SetZone
	local ClearZone = memprof.ClearZone
	local GetCounterFor = memprof.GetCounterFor
	local ResetCounter = memprof.ResetCounter

	-- Benchmarking
	io.write("\t0")

	for sample = 1, 100 do
		SetZone("test")
		ResetCounter()
		
		local s = clock()
		
		for iteration = 1, ]] .. iterations .. [[ do
			test(]] .. (info.setup[2] and "iteration" or "") .. [[)
		end
		
		local e = clock()
		
		ClearZone()

		io.write("\r\t", sample)

		]] .. (info.reset and "reset()" or "") .. [[

		samples[sample] = (jit and tonumber(e - s) or e - s) / ]] .. iterations .. [[
		gcsamples[sample] = GetCounterFor("test")

		]] .. (isdebug and [[io.write("\tTook: ", string.format("%.15f", samples[sample]), ", GC: ", string.format("%.15f", gcsamples[sample]), "\n")]] or "") .. [[
	end

	]] .. (isnoansi and [[io.write("\n")]] or [[io.write("\027[1M\027A\027[1M")]]) .. [[

	return samples, gcsamples
end]]
	local Benchmarker = loadstring(code, "Benchmarker")()
	local GCCollect() = GCCollect()
	GCCollect()

	for k = 1, #tests do
		local test = tests[k]
		io.write("Benchmarking test #", k, " \"", test[2], "\":\n")
		test[3], test[4] = Benchmarker(clock, test[1])
		GCCollect()
	end
end

GCCollect()
----------------------
-- Preparing values
----------------------
local round

do
	local stringgsub, stringformat = string.gsub, string.format

	function round(n)
		return (stringgsub(stringformat("%.3f", n), "(%.-)0+$", ""))
	end
end

local bestresult = math.huge

for k = 1, #tests do
	local test = tests[k]
	local testresults = test[3]
	local len = #testresults

	table.sort(testresults)

	do
		local values = {}

		for i = 1, len do
			local val = test[4][i]

			if val ~= 0 then
				values[#values + 1] = val
			end
		end

		table.sort(values)

		local mem_len = #values

		if mem_len % 2 == 0 then
			local key = mem_len / 2
			test.memmedian = (values[key] + values[key + 1]) / 2
		else
			test.memmedian = testresults[math.ceil(mem_len / 2)]
		end
	end

	-- Median value and IQR
	do
		local median

		if len % 2 == 0 then
			local key = len / 2

			median = (testresults[key] + testresults[key + 1]) / 2
			test.median = median
			key = len / 4

			local Q1 = (testresults[key] + testresults[key + 1]) / 2

			key = len * 0.75

			local Q3 = (testresults[key] + testresults[key + 1]) / 2
			local IQR = Q3 - Q1

			test.iqr = IQR
			test.lfence = Q1 - (1.5 * IQR) -- Left fence
			test.rfence = Q3 + (1.5 * IQR) -- Right fence
		else
			median = testresults[math.ceil(len / 2)]

			test.median = median

			local Q1, Q3 = testresults[math.ceil(len / 4)], testresults[math.ceil(len * 0.75)]
			local IQR = Q3 - Q1

			test.iqr = IQR
			test.lfence = Q1 - (1.5 * IQR) -- Left fence
			test.rfence = Q3 + (1.5 * IQR) -- Right fence
		end

		-- remembering best code cycles to compute percentage/ratio
		if median < bestresult then
			bestresult = median
		end
	end

	do
		test.min, test.max = testresults[1], testresults[len] -- Min and max
	end

	do
		local L, R = test.lfence, test.rfence
		local filtered, n = {}, 0

		for i = 1, len do
			local val = testresults[i]

			if L > val or val < R then
				n = n + 1
				filtered[n] = val
			end
		end

		testresults, len = filtered, n
		test.rawresults, test[3] = test[3], filtered
	end

	-- Mean, mode and standard deviation value
	do
		local ret = 0
		local set = {}

		for i = 1, len do
			local val = testresults[i]
			set[val] = (set[val] or 0) + 1
			ret = ret + val
		end

		local mean = ret / len
		test.mean = mean
		ret = 0

		local mode, n = {0}, 0

		for i = 1, len do
			local val = testresults[i]
			local setval = set[val]

			if setval > mode[1] then
				mode[1] = val
				n = 1
			elseif setval == mode then
				n = n + 1
				mode[n] = val
			end

			ret = (val - mean) ^ 2
		end

		for i = 1, n do
			mode[i] = round(mode[i])
		end

		test.mode = (n > 1 and "[" or "") .. table.concat(mode, ", ", 1, n > 3 and 3 or n) .. (n > 1 and "]" or "")
		test.std = math.sqrt(ret / len) -- STD
	end
end

----------------------
-- Printing results
----------------------
local not_first_line = false
local israw = arg_set["--raw"]

local function format_mem(mem)
	if mem > 1024 * 1024 then
		return round(mem / 1024 * 1024) .. "` MB"
	elseif mem > 1024 then
		return round(mem / 1024) .. "` KB"
	else
		return mem .. "` B"
	end
end

for k = 1, #tests do
	if not_first_line then
		testoutput:write("\n")
	end

	not_first_line = true
	local test = tests[k]

	if not israw then
		testoutput:write("- **", test[2], "**: `", round(test.median), "` ns")

		test.ratio = test.median / bestresult

		if test.ratio >= 1.1 then
			testoutput:write(" (", round(test.ratio), "x slower)")
		end

		testoutput:write(" (Min: `", round(test.min), "`, Max: `", round(test.max), "`, Average: `", round(test.mean), "`")
		testoutput:write(", Mode: `", test.mode, "`, STD: `", round(test.std), "`, IQR: `", round(test.iqr), "`)")

		local mem_init = test[1][3]
		if mem_init then testoutput:write(" [Mem (init): `", format_mem(mem_init), ", ") end
		testoutput:write(mem_init and "" or " [", "Mem (sample): `", format_mem(test.memmedian) ,"]")

	else
		testoutput:write(test[2], "\t", round(test.median), " ns\t", round(test.min), "\t", round(test.max), "\t", round(test.mean), "\t", test.mode, "\t", round(test.std), "\t", round(test.iqr), "\t", test[4] > 1024 and round(test[4] / 1024) .. " MB" or round(test[4]) .. " KB")
		test.ratio = test.median / bestresult

		if test.ratio >= 1.1 then
			testoutput:write("\t", round(test.ratio), "x slower")
		end
	end
end

testoutput:close()

do
	local t = os.clock()
	local lua54compat
	local mj, mn = string.match(_VERSION, "^Lua (%d+)%.(%d+)$")
	mj, mn = tonumber(mj), tonumber(mn)

	if mj == 5 and mn >= 3 then
		lua54compat = math.floor
	elseif mj > 5 then
		lua54compat = math.floor
	else
		lua54compat = function(n) return n end
	end

	io.write("Done by ", string.format("%02d:%02d.%1d", lua54compat(t / 60), lua54compat(t % 60), lua54compat(t * 10) % 10))
end

if arg_set["--nobeep"] then
	os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
end

if arg_set["--pause"] then
	os.execute("pause")
end