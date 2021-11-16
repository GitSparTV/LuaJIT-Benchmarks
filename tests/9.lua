-- ::setup::
return 10000000

-- ::header::
local func1 = function(a, b, func) return func(a + b) end
local func2 = function(a) return a * 2 end

-- ::test<Inlined closure>::
local x = func1(1, 2, function(a) return a * 2 end)

-- ::test<Localized closure>::
local x = func1(1, 2, func2)