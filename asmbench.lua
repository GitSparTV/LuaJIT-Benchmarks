-- Utils
io.stdout:setvbuf("no")
ffi = require("ffi")
local samples = 1000000
print("Iterations: " .. samples)
-- For benchmarking
local a = {
	[0] = 0
}
local function clear()
	a = {
	[0] = 0
}
end

local tinsert = table.insert
local count = 1

local function test1(q)
	a[q] = q
end

local function test2(q)
	a[0] = a[0] + 1
	a[a[0]] = q
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
clear()
print(cs .. "BENCHING 1 DONE" .. ce)
collectgarbage()
collectgarbage()
print(cs .. "BENCHING 2" .. ce)
test2(1)
clear()
print(cs .. "BENCHING 2 DONE" .. ce)
collectgarbage()
collectgarbage()
print(cs .. samples .. " iterations test..." .. ce)

do
	print(cs .. "BENCHING 1" .. ce)
	for warm = 1, samples do
		test1(warm)
	end
	clear()
	print(cs .. "BENCHING 1 DONE" .. ce)
	print(cs .. "BENCHING 2" .. ce)
	for warm = 1, samples do
		test2(warm)
	end
	clear()
	print(cs .. "BENCHING 2 DONE" .. ce)
end

os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
os.execute("pause")