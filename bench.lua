-- Utils
function topf(num)
	return (string.format("%f", num):gsub("(%.-)0+$", ""))
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
local s = math.sin

-- Functions
function test1(arg)
	math.sin(3)
end

function test2(arg)
	s(3)
end

-- Warmup
print("Warming up...")

for warm = 1, 1000000 do
	test1() clock()
end

for warm = 1, 1000000 do
	test2() clock()
end

os.execute("sleep 1")
-- Start benchmarking
print("Benchmarking...")
print("Benchmarking \"" .. name1 .. "\"...")

for take = 1, 100 do
	local START = clock()

	---
	for times = 1, 1000000 do
		test1()
	end

	---
	local END = clock()
	rt1[take] = END - START
end

print("Benchmarking \"" .. name2 .. "\"...")

for take = 1, 100 do
	local START = clock()

	---
	for times = 1, 1000000 do
		test2()
	end

	---
	local END = clock()
	rt2[take] = END - START
end

print(hr) -- Horizontal line
local r1, r2 = math.mean(rt1), math.mean(rt2)
local min, max = math.min(r1, r2), math.max(r1, r2)
local percent2 = max * 100 / min
local percentFor1, percentFor2

if min == r1 then
	percentFor1 = 100
	percentFor2 = percent2
else
	percentFor1 = percent2
	percentFor2 = 100
end

print(name1 .. " = " .. r1 .. " (" .. topf(r1) .. ") second(s) (" .. percentFor1 .. "%) (" .. topf(percentFor1) .. "%)")
print(name2 .. " = " .. r2 .. " (" .. topf(r2) .. ") second(s) (" .. percentFor2 .. "%) (" .. topf(percentFor2) .. "%)")