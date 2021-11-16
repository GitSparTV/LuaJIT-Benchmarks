-- Utils
io.stdout:setvbuf("no")
ffi = require("ffi")
local samples = 1000000
print("Iterations: " .. samples)

-- For benchmarking

local function test1(...)
	local t = {}
	for k = 1, select("#", ...) do
		t[k] = select(k, ...)
	end
end

local function test2(times)
end

----------------------
local colors = true
local cs, ce = colors and "\027[44m" or "", colors and "\027[0m" or ""
collectgarbage()
collectgarbage()
collectgarbage("stop")
collectgarbage("setstepmul", 10000)
collectgarbage()
collectgarbage()
print(cs .. "Single test..." .. ce)
print(cs .. "BENCHING 1" .. ce)
test1(1)
print(cs .. "BENCHING 1 DONE" .. ce)
collectgarbage()
collectgarbage()

t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

print(cs .. "BENCHING 2" .. ce)
test2(1)
print(cs .. "BENCHING 2 DONE" .. ce)
collectgarbage()
collectgarbage()

t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}

print(cs .. samples .. " iterations test..." .. ce)

do
	print(cs .. "BENCHING 1" .. ce)

	for warm = 1, samples do
		test1(warm)
		t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
	end


	print(cs .. "BENCHING 1 DONE" .. ce)
	print(cs .. "BENCHING 2" .. ce)

	for warm = 1, samples do
		test2(warm)
		t = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11}
	end


	print(cs .. "BENCHING 2 DONE" .. ce)
end

os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
-- os.execute("pause")