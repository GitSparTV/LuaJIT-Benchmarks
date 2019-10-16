-- Utils
function topf(num)
	return (string.format("%.10f", num):gsub("(%.-)0+$", ""))
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
local clock = os.clock
-- For benchmarking


----------------------
function test1(arg)
end

function test2(arg)
end

-- Warmup
print("Warming up...")

for warm = 1, 1000000 do
	test1(warm)
	clock()
end

for warm = 1, 1000000 do
	test2(warm)
	clock()
end

collectgarbage()
collectgarbage()
collectgarbage("stop")
collectgarbage("setpause", 0)
collectgarbage("setstepmul", 1000)
collectgarbage()
collectgarbage()
local T = 0

while true do
	T = T + 1
	if T > 1000000 then break end
end

-- Start benchmarking
print("Benchmarking...")
print("Benchmarking \"" .. name1 .. "\"...")

for take = 1, 100 do
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

print("Benchmarking \"" .. name2 .. "\"...")

for take = 1, 100 do
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

print(hr) -- Horizontal line
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

print(name1 .. ": " .. rmax1 .. " (Min: " .. topf(rmin1) .. ", Average: " .. topf(ra1) .. ") second(s) (" .. percentFor1 .. "%) (" .. topf(percentFor1) .. "%)")
print(name2 .. ": " .. rmax2 .. " (Min: " .. topf(rmin2) .. ", Average: " .. topf(ra2) .. ") second(s) (" .. percentFor2 .. "%) (" .. topf(percentFor2) .. "%)")
os.execute("rundll32.exe cmdext.dll,MessageBeepStub")