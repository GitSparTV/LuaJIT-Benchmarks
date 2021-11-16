require("lmemprof")

local ffi = require("ffi")

ffi.cdef([[
	bool IsEnabled();
	const char* GetZone();
	void Enable();
	void Disable();
	void SetZone(const char* name);
	void ClearZone();
	void IncrementCounter(size_t number);
	void DecrementCounter(size_t number);
	void ResetCounter();
	void ResetCounterFor(const char* name);
	double GetCounter();
	double GetCounterFor(const char* name);
]])

local lib = ffi.load("lmemprof.dll")

-- Getting all functions before using, this will remove unexpected allocations on profiling
lib.IsEnabled()
lib.GetZone()
lib.Enable()
lib.Disable()
lib.SetZone("")
lib.ClearZone()
lib.IncrementCounter(0)
lib.DecrementCounter(0)
lib.ResetCounter()
lib.ResetCounterFor("")
lib.GetCounter()
lib.GetCounterFor("")

return lib