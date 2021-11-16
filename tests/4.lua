-- ::setup::
return 100000000

-- ::header::
local min = math.min
local unpack = unpack
local a = {100, 200, 300, 400}

local function unpack4(a)
	return a[1], a[2], a[3], a[4]
end

local function runpack(t, k)
	local val = t[k]
	if val ~= nil then return val, runpack(k + 1) end
end

-- ::test<Inlined unpacking>::
min(a[1], a[2], a[3], a[4])

-- ::test<unpack>::
min(unpack(a))

-- ::test<Templated unpacking>::
min(unpack4(a))

-- ::test<Recursive unpack>::
min(runpack(a, 1))