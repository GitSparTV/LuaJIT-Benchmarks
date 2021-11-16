if jit then
	memprof = require("lmemprof-luajit")
else
	local dll = package.loadlib("lmemprof" .. (_VERSION == "Lua 5.1" and "-51" or "-54"), "luaopen_lmemprof") -- Lua Memory Profiler

	if not dll then
		io.write("Failed to load lmemprof module, memory profiling is disabled\n")
		
		local return_nothing = function() end
		local return_number = function() return 0 end
		local return_string = function() return "" end
		
		memprof = {
			IsEnabled = return_number,
			GetZone = return_string,
			Enable = return_nothing,
			Disable = return_nothing,
			SetZone = return_nothing,
			ClearZone = return_nothing,
			IncrementCounter = return_nothing,
			DecrementCounter = return_nothing,
			ResetCounter = return_nothing,
			ResetCounterFor = return_nothing,
			GetCounter = return_number,
			GetCounterFor = return_number,
		}

		return memprof
	end

	memprof = dll()

	package.loaded["lmemprof"] = memprof
end

return memprof