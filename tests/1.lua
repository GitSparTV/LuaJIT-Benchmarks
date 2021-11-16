-- ::setup::
return 10000000, true

-- ::header::
local lnumbers = {}

for k = 1, 10000001 do
	lnumbers[k] = k
end

numbers = lnumbers

-- memprof_start<Global>
-- memprof_start<Local>
function add(a, b)
	return a + b
end

function sub(a, b)
	return a - b
end

function mul(a, b)
	return a * b
end

function div(a, b)
	return a / b
end
-- memprof_end<Global>

local ladd, lsub, lmul, ldiv = add, sub, mul, div
-- memprof_end<Local>

local lcollector = {}

for k = 1, 10000000 do
	lcollector[k] = true
end

collector = lcollector

-- ::test<Global>::
local number1 = numbers[iteration]
local number2 = numbers[iteration + 1]

local key = iteration % 4

if key == 0 then
	collector[iteration] = add(number1, number2)
elseif key == 1 then
	collector[iteration] = sub(number1, number2)
elseif key == 2 then
	collector[iteration] = mul(number1, number2)
elseif key == 3 then
	collector[iteration] = div(number1, number2)
end

-- ::test<Local>::
local lnumbers = lnumbers
local number1 = lnumbers[iteration]
local number2 = lnumbers[iteration + 1]

local key = iteration % 4

if key == 0 then
	lcollector[iteration] = ladd(number1, number2)
elseif key == 1 then
	lcollector[iteration] = lsub(number1, number2)
elseif key == 2 then
	lcollector[iteration] = lmul(number1, number2)
elseif key == 3 then
	lcollector[iteration] = ldiv(number1, number2)
end