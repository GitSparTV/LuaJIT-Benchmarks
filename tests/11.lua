-- ::setup::
return 10000000

-- ::header::
local a = {}

for i = 1, 100 do
	a[i] = {
		x = 10
	}
end

-- ::test<No localizations>::
for n = 1, 100 do
	a[n].x = a[n].x + 1
end

-- ::test<Localized a and a[n]>::
local a = a

for n = 1, 100 do
	local y = a[n]
	y.x = y.x + 1
end