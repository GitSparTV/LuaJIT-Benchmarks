-- ::setup::
return 10000000, true

-- ::header::
local lnumbers = {}

for k = 1, 10000000 do
	lnumbers[k] = k
end

header = {
	numbers = lnumbers
}

local lheader = header
local lmath = math
local lsin = math.sin
local lcos = math.cos
local ltan = math.tan
local latan = math.atan

local lcollector = {}

for k = 1, 10000000 do
	lcollector[k] = true
end

collector = lcollector
header.collector = lcollector

-- ::test<Global table indexing>::
local key = iteration % 4

if key == 0 then
	header.collector[iteration] = math.sin(header.numbers[iteration])
elseif key == 1 then
	header.collector[iteration] = math.cos(header.numbers[iteration])
elseif key == 2 then
	header.collector[iteration] = math.tan(header.numbers[iteration])
elseif key == 3 then
	header.collector[iteration] = math.atan(header.numbers[iteration])
end

-- ::test<Local table indexing>::
local key = iteration % 4

if key == 0 then
	lheader.collector[iteration] = lmath.sin(lheader.numbers[iteration])
elseif key == 1 then
	lheader.collector[iteration] = lmath.cos(lheader.numbers[iteration])
elseif key == 2 then
	lheader.collector[iteration] = lmath.tan(lheader.numbers[iteration])
elseif key == 3 then
	lheader.collector[iteration] = lmath.atan(lheader.numbers[iteration])
end

-- ::test<Localized>::
local key = iteration % 4

if key == 0 then
	lcollector[iteration] = lsin(lnumbers[iteration])
elseif key == 1 then
	lcollector[iteration] = lcos(lnumbers[iteration])
elseif key == 2 then
	lcollector[iteration] = ltan(lnumbers[iteration])
elseif key == 3 then
	lcollector[iteration] = latan(lnumbers[iteration])
end