-- ::setup::
return 10000000, true

-- ::header::
local fmod = math.fmod

local function jit_fmod(a, b)
	if b < 0 then b = -b end
	if a < 0 then
		return -(-a % b)
	else
		return a % b
	end
end

-- ::test<Modulo operator>::
local x = iteration % 30

-- ::test<math.fmod>::
local x = fmod(iteration, 30)

-- ::test<jit_fmod>::
local x = jit_fmod(iteration, 30)