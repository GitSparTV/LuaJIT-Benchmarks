-- ::setup::
return 1000000, true

-- ::header::
local a = {
	[0] = 0,
	n = 0
}

local tinsert = table.insert
local len = 0

-- ::reset::
a = {
	[0] = 0,
	n = 0
}

len = 0

-- ::test<table.insert>::
tinsert(a, iteration)

-- ::test<Loop insertion>::
a[iteration] = iteration

-- ::test<#a + 1>::
a[#a + 1] = iteration

-- ::test<Localized length>::
len = len + 1
a[len] = iteration

-- ::test<a.n>::
local n = a.n + 1
a.n = n
a[n] = iteration

-- ::test<a[0]>::
local n = a[0] + 1
a[0] = n
a[n] = iteration