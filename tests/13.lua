-- ::setup::
return 10000000

-- ::header::
if jit then
	require("table.new")
end

local new = table.new

-- ::test<Allocated on demand>::
local a = {}
a[1] = 1
a[2] = 2
a[3] = 3

-- ::test<Preallocation with nil>::
local a = {nil, nil, nil}

a[1] = 1
a[2] = 2
a[3] = 3

-- ::test<Preallocation with primitives>::
local a = {true, true, true}

a[1] = 1
a[2] = 2
a[3] = 3

-- ::test<Defined in constructor>::
local a = {1, 2, 3}

-- ::test_luajit<table.new>::
local a = new(3, 0)
a[1] = 1
a[2] = 2
a[3] = 3