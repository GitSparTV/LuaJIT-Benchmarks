-- ::setup::
return 10000000

-- ::header::
local class = {
	test = function() return 1 end
}

-- ::test<Direct call>::
class.test()
class.test()
class.test()

-- ::test<Localized call>::
local test = class.test
test()
test()
test()