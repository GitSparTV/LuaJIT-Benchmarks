-- ::setup::
return 10000000

-- ::header::
local s = ""
local cstring
local C

if jit then
	C = ffi.C
	cstring = ffi.cast("const char*", s)
	ffi.cdef([[
    size_t strlen ( const char * str );
]])
end

-- ::test<#s == 0>::
local x = #s == 0

-- ::test<s == "">::
local x = s == ""

-- ::test_luajit<Indexing 0th element>::
local x = cstring[0] == 0

-- ::test_luajit<strlen>::
local x = C.strlen(cstring) == 0