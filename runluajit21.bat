@echo off
cd tests
for /r %%f in (*.lua) do (
	cd ../
	luajit.exe ljbenchmarks_bench.lua %%f
	cd tests
)
cd ../