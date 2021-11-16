-- ::setup::
return 10000000, true

-- ::header::
local values = {}
local y = 0
local max = math.max

do
	local rand = math.random

	for k = 1, 10000000 do -- must be the same as number of iterations
		values[k] = rand(-100, 100)
	end
end

-- ::test<math.max>::
local x = max(values[iteration], y)

-- ::test<if/else>::
local x
do
	local num = values[iteration]

	if (num > y) then
		x = num
	else
		x = y
	end
end

-- ::test<a and b or c>::
local num = values[iteration]
local x = num > y and num or y