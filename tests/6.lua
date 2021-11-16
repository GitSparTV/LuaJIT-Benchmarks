-- ::setup::
return 10000000, true

-- ::header::
local values = {}

do
	local rand = math.random

	-- must be the same as number of iterations
	for k = 1, 10000000 do
		if rand(2) == 1 then
			values[k] = 0
		end
	end
end

-- ::test<if not x>::
local x = values[iteration]
if not x then
    x = 1
end

-- ::test<a or b>::
local x = values[iteration] or 1