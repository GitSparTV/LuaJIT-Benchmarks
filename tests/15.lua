-- ::setup::
return 10000000

-- ::header::
local text = "12345678901234567890"
local cstring

if jit then
	cstring = ffi.cast("const char*", text)
end

local char = string.char
local sub, gsub, gmatch = string.sub, string.gsub, string.gmatch

local gsubfunc = function(s)
	local x = s
end

-- ::reset::
local temp = {}

for i = 1, 20 do
	temp[i] = string.char(math.random(48,57))
end

if jit then
	cstring = ffi.cast("const char*", text)
end

-- ::test<string.sub>::
for i = 1, #text do
	local x = sub(text, i, i)
end

-- ::test<string.gmatch>::
for k in gmatch(text, ".") do
	local x = k
end

-- ::test<string.gsub>::
gsub(text, ".", gsubfunc)

-- ::test_luajit<char* array>::
for i = 0, #text - 1 do
	local x = char(cstring[i])
end