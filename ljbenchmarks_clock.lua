local clock

if jit then
	ffi = require("ffi") -- Use FFI on LuaJIT
	ffi.cdef([[
		void* GetCurrentThread();
		void* GetCurrentProcess();
		bool QueryPerformanceFrequency(uint64_t *lpFrequency);
		bool QueryPerformanceCounter(uint64_t *lpPerformanceCount);
		bool SetPriorityClass(void* hProcess, unsigned long dwPriorityClass);
		bool SetThreadPriority(void* hThread, int nPriority);
		void* GetStdHandle(unsigned long nStdHandle);
		bool GetConsoleMode(void* hConsoleHandle, unsigned long* lpMode);
		bool SetConsoleMode(void* hConsoleHandle, unsigned long dwMode);]])
	local C = ffi.C

	if jit.os == "Windows" then
		C.SetPriorityClass(C.GetCurrentProcess(), 0x00000100) -- REALTIME_PRIORITY_CLASS
		C.SetThreadPriority(C.GetCurrentThread(), 15) -- THREAD_PRIORITY_TIME_CRITICAL
		local H = C.GetStdHandle(-11) -- STD_OUTPUT_HANDLE

		if H ~= nil then
			local m = ffi.new("unsigned long[1]")
			assert(C.GetConsoleMode(H, m))
			assert(C.SetConsoleMode(H, bit.bor(m[0], 0x0004))) -- ENABLE_VIRTUAL_TERMINAL_PROCESSING 
		end
	end

	local frequency = ffi.new("uint64_t[1]")
	local counter = ffi.new("uint64_t[1]")
	C.QueryPerformanceFrequency(frequency)
	local tonumber = tonumber
	frequency = tonumber(1000000000 / frequency[0])
	local QC = C.QueryPerformanceCounter

	function clock()
		local counter = counter
		QC(counter)

		return tonumber(counter[0] * frequency)
	end
else
	local dll = package.loadlib("ljbenchmarks" .. (_VERSION == "Lua 5.1" and "-51" or "-54"), "luaopen_ljbenchmarks") -- Windows priority

	if not dll then
		io.write("Failed to load ljbenchmarks module, using os.clock instead\n")
		local osclock = os.clock
		return function() return osclock() * 1e+9 end
	end

	local info = dll()

	package.loaded["ljbenchmarks"] = info -- Lua 5.1 apparently crashes if this table is unreferenced 

	if not info[2] then
		io.write("Warning: Unable to set Windows priority for Lua!\n")
	end

	if not info[3] then
		io.write("Warning: Unable to enable Windows console escapes for Lua!\n")
	end

	clock = info[1]
end

return clock