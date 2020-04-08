-- Utils
io.stdout:setvbuf("no")
ffi = require("ffi")
local samples = 1000000
print("Iterations: " .. samples)
-- For benchmarking
local a = {
	[0] = 0,
	n = 0
}

local tinsert = table.insert
local count = 1

-- Note: after each run of the code the table and count variable are restored to predefined state.
-- If you don't clean them after a test, table.insert will be super slow.

local function test1(times)
	a[#a + 1] = times
end

local function test2(times)
	a[0] = a[0] + 1
	a[a[0]] = times
end

local function reset()
	a = {[0] = 0, n = 0}
	count = 0
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
reset()
collectgarbage()
collectgarbage()
print(cs .. "BENCHING 2" .. ce)
test2(1)
print(cs .. "BENCHING 2 DONE" .. ce)
reset()
collectgarbage()
collectgarbage()
print(cs .. samples .. " iterations test..." .. ce)

do
	print(cs .. "BENCHING 1" .. ce)
	for warm = 1, samples do
		test1(warm)
	end
	reset()
	print(cs .. "BENCHING 1 DONE" .. ce)
	print(cs .. "BENCHING 2" .. ce)
	for warm = 1, samples do
		test2(warm)
	end
	reset()
	print(cs .. "BENCHING 2 DONE" .. ce)
end

os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
os.execute("pause")