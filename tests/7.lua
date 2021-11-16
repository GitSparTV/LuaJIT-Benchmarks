-- ::setup::
return 10000000

-- ::header::
local x = 10
local pow = math.pow

-- ::test<Power operator>::
local y = x ^ 2

-- ::test<Multiplication operator>::
local y = x * x

-- ::test<math.pow>::
local y = pow(x, 2)