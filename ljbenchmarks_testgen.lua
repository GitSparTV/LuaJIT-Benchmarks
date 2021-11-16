local info = {
	setup = false, -- preallocation
	header = false,
	reset = false,
	tests = {}
}

local isparseonly = arg_set["--parseonly"]
local testoutput

----------------------
-- Parsing
----------------------
do
	local testfilepath = arg[1]

	if not testfilepath then
		io.write("No test file were given\n")

		return
	end

	local testfile, err = io.open(testfilepath)

	if not testfile then
		error("unable to open test file (" .. testfilepath .. "): " .. err)
	end

	if not isparseonly then
		local testoutputpath, testname = string.match(testfilepath, "^\"?(.*[/\\])([^/\\]*)%.lua\"?$")
		testoutputpath = testoutputpath .. "/results/" .. testname .. "_" .. (jit and "lj" .. (jit.status() and ".on_" or ".off_") .. jit.version:match("LuaJIT (%d+%.?%d*%.?%d*)") or _VERSION:match("Lua (%d+%.?%d*)")) .. "_result" .. (arg_set["--raw"] and ".txt" or ".md")
		testoutput, err = io.open(testoutputpath, "w")

		if not testoutput then
			error("unable to open output file (" .. testoutputpath .. "): " .. err)
		end

		testoutput:setvbuf("full")
	end

	local temp, collecting = {}, false
	-- parsing test file
	local linek = 0

	for line in testfile:lines() do
		linek = linek + 1

		-- token
		if line:sub(1, 5) == "-- ::" then
			if collecting then
				collecting = false
				temp = {}
			end

			line = string.match(line, "^-- ::([^:]+)::%s*$")

			if not line then
				error("Error on reading a line " .. linek .. ". Missing closing token")
			end

			-- setup information
			if line == "setup" then
				collecting = true
				info.setup = temp
			elseif line == "header" then
				-- shared header for tests
				collecting = true
				info.header = temp
			elseif line == "reset" then
				-- reset function
				collecting = true
				info.reset = temp
			elseif line:sub(1, 4) == "test" then
				-- test code
				local exclusive, name = line:match("^test_?([^<]*)<([^>]+)>$")

				if #exclusive == 0 then
					exclusive = nil
				end

				if isparseonly or not exclusive or (jit and exclusive ~= "lua") or (not jit and exclusive ~= "luajit") then
					collecting = true

					info.tests[#info.tests + 1] = {
						temp, name, false, false, mean = false,
						median = false,
						iqr = false,
						std = false,
						min = false,
						max = false,
						lfence = false,
						rfence = false,
						mode = false,
						ratio = false,
						percentage = false,
						rawresults = false,
						exclusive = exclusive,
						memmedian = false,
					}
				elseif exclusive then
					io.write("Test #", #info.tests + 1, " <", name, "> is intended for ", exclusive, ", ignoring.\n")
				end
			end
		elseif collecting and #line ~= 0 then
			temp[#temp + 1] = line
		end
	end
end

----------------------
-- Generating
----------------------
local function memprof_parse(header, test_name)
	return header:gsub("-- memprof_([^<]+)<([^>]+)>[^\n]*\n", function(switch, name)
		if name == test_name then
			if switch == "start" then
				return "memprof.SetZone(\"header_test\") memprof.ResetCounter()\n"
			elseif switch == "end" then
				return "memprof.ClearZone() memprof_result = memprof.GetCounterFor(\"header_test\")\n"
			end
		end
	end)
end

do
	local tableconcat = table.concat

	if not loadstring then
		loadstring = load
	end

	if info.setup then
		local f, err = loadstring(tableconcat(info.setup, "\n"))

		if not f then
			error(err)
		end

		info.setup = {f()}

		if isparseonly then
			io.write("-- Setup:\nIterations: ", info.setup[1], "\nProvide iteration number as argument: ", info.setup[2] and "true" or "false", "\n\n")
		end
	end

	local hasheader = 0 -- If we don't header, tests will be concated from [0]
	local header = info.header

	if header then
		hasheader = -1

		-- Appending reset function
		if info.reset then
			local len = #header
			header[len + 1] = "-- Reset function:\nlocal function reset()"
			local reset = tableconcat(info.reset, "\n")
			info.reset = reset
			header[len + 2] = reset
			header[len + 3] = "end"
		end

		header = tableconcat(header, "\n")

		if isparseonly then
			io.write("-- Header:\n", header, "\n\n")
		end

		info.header = header
	end

	local tests = info.tests

	for k = 1, #tests do
		local v = tests[k]
		local test = v[1]

		if header then
			if not isparseonly then
				test[-1] = memprof_parse(header, v[2])
			else
				test[-1] = header
			end
		end

		test[0] = "local function test(" .. (info.setup[2] and "iteration" or "") .. ")"
		test[#test + 1] = "end\nreturn test, reset, memprof_result"
		local func, err = loadstring(tableconcat(test, "\n", hasheader))

		if not func then
			error("Test #" .. k .. " <" .. v[2] .. "> failed to compile: " .. tostring(err))
		end

		if isparseonly then
			io.write("-- Test #", k, v.exclusive and " (" .. v.exclusive .. " only)" or "", " <", v[2], ">:\n", tableconcat(test, "\n", 0), "\n\n")
		end

		v[1] = {func()}
	end
end

if isparseonly then return false end

return {info, testoutput}