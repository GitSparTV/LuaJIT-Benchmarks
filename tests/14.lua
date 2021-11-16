-- ::setup::
return 10000000, true

-- ::header::
local T = {}

local CachedTable = {"abc", "def", "ghk"}

-- ::reset::
T = {}

-- ::test<Localized table>::
T[iterations] = CachedTable

-- ::test<New allocation>::
T[iterations] = {"abc", "def", "ghk"}