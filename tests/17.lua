-- ::setup::
return 100000

-- ::header::
local new = ffi.new

-- ::test_luajit<[n]>::
new("const char*[16]")
new("const char*[1024]")
new("int[16]")
new("int[1024]")

-- ::test_luajit<VLA>::
new("const char*[?]", 16)
new("const char*[?]", 1024)
new("int[?]", 16)
new("int[?]", 1024)