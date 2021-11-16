-- ::setup::
return 10000

-- ::header::
local bs = string.rep("----------", 1000)
local t = {bs, bs, bs, bs, bs, bs, bs, bs, bs, bs}
local concat = table.concat
local format = string.format

local new, copy, ffistring
if jit then
	new, copy, ffistring = ffi.new, ffi.copy, ffi.string
end

-- ::test<Inlined concatenation>::
local s = bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs

-- ::test<Separate concatenations>::
local s = bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs

-- ::test<Loop concatenation>::
local s = bs

for i = 1, 9 do
    s = s .. bs
end

-- ::test<table.concat>::
concat(t)

-- ::test<string.format>::
format("%s%s%s%s%s%s%s%s%s%s", bs, bs, bs, bs, bs, bs, bs, bs, bs, bs)

-- ::test_luajit<Using ffi.copy>::
local size = #bs
local s = new("char[?]", size * 10, bs)

for i = 1, 9 do
	copy(s + (i * size), bs, size)
end

s = ffistring(s, size)