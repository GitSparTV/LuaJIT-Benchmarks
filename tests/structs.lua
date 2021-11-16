-- ::setup::
return 10000

-- ::header::
local m1
local m2

if jit then
	-- memprof_start<Multidimensional FFI array>
	m1 = ffi.new("int [10][10]")
	-- memprof_end<Multidimensional FFI array>

	-- memprof_start<Flattened multidimensional FFI array>
	m2 = ffi.new("int [100]")
	-- memprof_end<Flattened multidimensional FFI array>

	for a = 0, 9 do
		for b = 0, 9 do
			m1[a][b] = math.random()
			m2[a * 10 + b] = math.random()
		end
	end
end

-- memprof_start<Multidimensional Lua array>
local m3 = {
	[0] = {},
	{}, {}, {}, {}, {}, {}, {}, {}, {}
}

for a = 0, 9 do
	for b = 0, 9 do
		m3[a][b] = math.random()
	end
end
-- memprof_end<Multidimensional Lua array>

-- memprof_start<Flattened Lua array>
local m4 = {}

for i = 0, 99 do
	m4[i] = math.random()
end
-- memprof_end<Flattened Lua array>

local acc = 0

-- ::test_luajit<Multidimensional FFI array>::
for a = 0, 9 do
	for b = 0, 9 do
		acc = acc + m1[a][b]
	end
end

-- ::test_luajit<Flattened multidimensional FFI array>::
for a = 0, 9 do
	for b = 0, 9 do
		acc = acc + m2[a * 10 + b]
	end
end

-- ::test<Multidimensional Lua array>::
for a = 0, 9 do
	for b = 0, 9 do
		acc = acc + m3[a][b]
	end
end

-- ::test<Flattened Lua array>::
for a = 0, 9 do
	for b = 0, 9 do
		acc = acc + m4[a * 10 + b]
	end
end