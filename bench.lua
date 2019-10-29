-- Utils
io.stdout:setvbuf("no")
ffi = require("ffi")
ffi.cdef([[
	typedef int BOOL;
	typedef unsigned long DWORD;
	typedef long LONG;
	 typedef __int64 LONGLONG; 
	typedef union _LARGE_INTEGER {
	  struct {
	    DWORD LowPart;
	    LONG  HighPart;
	  };
	  struct {
	    DWORD LowPart;
	    LONG  HighPart;
	  } u;
	  LONGLONG QuadPart;
	} LARGE_INTEGER, *PLARGE_INTEGER;
	BOOL QueryPerformanceCounter(
	  LARGE_INTEGER *lpPerformanceCount
	);
	BOOL QueryPerformanceFrequency(
	  LARGE_INTEGER *lpFrequency
	);
]])
local t, f, C = ffi.new("LARGE_INTEGER"), ffi.new("LARGE_INTEGER"), ffi.C

local function clock()
	C.QueryPerformanceCounter(t)
	C.QueryPerformanceFrequency(f)

	return tonumber(t.QuadPart) / tonumber(f.QuadPart)
end

function topf(num)
	return (string.format("%.5f", num):gsub("(%.-)0+$", ""))
end

function time(t)
	return math.floor(t / 3600) .. ":" .. math.floor(t % 3600 / 60) .. ":" .. topf(t % 60)
end

function math.mean(t)
	local ret, len = 0, #t

	for i = 1, len do
		ret = ret + t[i]
	end

	return ret / len
end

-- Setup
local name1, name2 = "1", "2"
local hr = string.rep("-", 36)
local rt1, rt2 = {}, {}

-- For benchmarking
local s = math.sin
----------------------
function test1(arg)
	x = math.sin(3.14)
end

function test2(arg)
	x = s(3.14)
end

----------------------
-- Warmup
print("Warming up...")

do
	local START = clock()

	for warm = 1, 1000000 do
		test1(warm)
		clock()
	end

	local END = clock()
	local res1 = END - START
	print("\tWarm-up for \"" .. name1 .. "\" took: " .. topf(END - START) .. " second(s)")
	START = clock()

	for warm = 1, 1000000 do
		test2(warm)
		clock()
	end

	END = clock()
	local res2 = END - START
	print("\tWarm-up for \"" .. name2 .. "\" took: " .. topf(END - START) .. " second(s)")
	print("\tWhole test should take about: " .. time(res1 * 100 + res2 * 100))
end

collectgarbage()
collectgarbage()
collectgarbage("stop")
collectgarbage("setstepmul", 10000)
collectgarbage()
collectgarbage()
local T = 0

while true do
	T = T + 1
	if T > 1000000 then break end
end

-- Start benchmarking
print("Benchmarking...")
io.write("\tBenchmarking \"" .. name1 .. "\"")

for take = 1, 100 do
	io.write(".")
	local START = clock()

	---
	for times = 1, 1000000 do
		test1(times)
	end

	---
	local END = clock()
	collectgarbage()
	collectgarbage()
	rt1[take] = END - START
end

io.write("\n\tBenchmarking \"" .. name2 .. "\"")

for take = 1, 100 do
	io.write(".")
	local START = clock()

	---
	for times = 1, 1000000 do
		test2(times)
	end

	---
	local END = clock()
	collectgarbage()
	collectgarbage()
	rt2[take] = END - START
end

print("\n" .. hr) -- Horizontal line
local ra1, ra2 = math.mean(rt1), math.mean(rt2)
local rmax1, rmax2 = math.max(unpack(rt1)), math.max(unpack(rt2))
local rmin1, rmin2 = math.min(unpack(rt1)), math.min(unpack(rt2))
local min, max = math.min(rmax1, rmax2), math.max(rmax1, rmax2)
local percent2 = max * 100 / min
local percentFor1, percentFor2

if min == rmax1 then
	percentFor1 = 100
	percentFor2 = percent2
else
	percentFor1 = percent2
	percentFor2 = 100
end

print(name1 .. ": " .. topf(rmax1) .. " (Min: " .. topf(rmin1) .. ", Average: " .. topf(ra1) .. ") second(s) (" .. topf(percentFor1) .. "%)")
print(name2 .. ": " .. topf(rmax2) .. " (Min: " .. topf(rmin2) .. ", Average: " .. topf(ra2) .. ") second(s) (" .. topf(percentFor2) .. "%)")
os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
-- os.execute("pause")