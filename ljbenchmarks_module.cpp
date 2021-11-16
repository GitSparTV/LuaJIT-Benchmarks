#include <stdint.h>

#include <Windows.h>

#include "lua.hpp"

uint64_t frequency = 0;

int LJBenchmarksGetClock(lua_State* L) {
    LARGE_INTEGER counter;

    QueryPerformanceCounter(&counter);

    lua_pushinteger(L, counter.QuadPart * frequency);

    return 1;
}

// Init
extern "C" __declspec(dllexport) int luaopen_ljbenchmarks(lua_State* L) {
    bool priority_status = true;

    if (!SetPriorityClass(GetCurrentProcess(), REALTIME_PRIORITY_CLASS)) priority_status = false;
    if (!SetThreadPriority(GetCurrentThread(), THREAD_PRIORITY_TIME_CRITICAL)) priority_status = false;

    auto H = GetStdHandle(STD_OUTPUT_HANDLE);
    bool console_status = true;

    if (H) {
        DWORD m;
        if (!GetConsoleMode(H, &m)) console_status = false;
        if (!SetConsoleMode(H, m | ENABLE_VIRTUAL_TERMINAL_PROCESSING)) console_status = false;
    }
    else {
        console_status = false;
    }

    LARGE_INTEGER frequency_query;

    QueryPerformanceFrequency(&frequency_query);

    ::frequency = 1000000000 / frequency_query.QuadPart;

    lua_createtable(L, 3, 0);

    lua_pushcfunction(L, LJBenchmarksGetClock);
    lua_rawseti(L, -2, 1);

    lua_pushboolean(L, priority_status);
    lua_rawseti(L, -2, 2);

    lua_pushboolean(L, console_status);
    lua_rawseti(L, -2, 3);

    return 1;
}