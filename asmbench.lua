-- Utils
io.stdout:setvbuf("no")

-- For benchmarking
local TYPE_bool = "bool"
function isbool1(b)
    return type(b) == "bool"
end

function isbool2(b)
    return type(b) == TYPE_bool
end

function test1(arg)
	x = isbool1(false)
end

function test2(arg)
	x = isbool2(false)
end

----------------------
collectgarbage()
collectgarbage()
collectgarbage("stop")
collectgarbage("setstepmul", 10000)
collectgarbage()
collectgarbage()
print("\027[44mSingle test...\027[0m")
print("\027[41mBENCHING 1\027[0m")
test1(1)
print("\027[41mBENCHING 1 DONE\027[0m")
collectgarbage()
collectgarbage()
print("\027[41mBENCHING 2\027[0m")
test2(1)
print("\027[41mBENCHING 2 DONE\027[0m")
collectgarbage()
collectgarbage()
print("\027[44m1000000 test...\027[0m")

do
	print("\027[41mBENCHING 1\027[0m")

	for warm = 1, 1000000 do
		test1(warm)
	end

	print("\027[41mBENCHING 1 DONE\027[0m")
	print("\027[41mBENCHING 2\027[0m")

	for warm = 1, 1000000 do
		test2(warm)
	end

	print("\027[41mBENCHING 2 DONE\027[0m")
end

os.execute("rundll32.exe cmdext.dll,MessageBeepStub")
os.execute("pause")