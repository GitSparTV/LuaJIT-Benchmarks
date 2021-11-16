-- ::setup::
return 1000000

-- ::header::
local a = {}
local length = 100

for i = 1, length do
	a[i] = i
end

a.n = length
a[0] = length
local pairs = pairs
local ipairs = ipairs
local next = next
local inext = ipairs({})

local function jit_pairs(t)
	return next, t
end

local function lua_inext(t, k)
	k = k + 1
	local v = t[k]
	if v ~= nil then return k, v end
end

-- ::test<pairs>::
for k, v in pairs(a) do
	local x = v
end

-- ::test<next>::
for k, v in next, a do
	local x = v
end

-- ::test<jit_pairs>::
for k, v in jit_pairs(a) do
	local x = v
end

-- ::test<ipairs>::
for k, v in ipairs(a) do
	local x = v
end

-- ::test<inext>::
for k, v in inext, a, 0 do
	local x = v
end

-- ::test<lua_inext>::
for k, v in lua_inext, a, 0 do
	local x = v
end

-- ::test<Literal number>::
for i = 1, 100 do
	local x = a[i]
end

-- ::test<Length operator>::
for i = 1, #a do
	local x = a[i]
end

-- ::test<Localized length>::
for i = 1, length do
	local x = a[i]
end

-- ::test<a.n>::
for i = 1, a.n do
	local x = a[i]
end

-- ::test<a[0]>::
for i = 1, a[0] do
	local x = a[i]
end