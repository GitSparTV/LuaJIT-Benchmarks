local head = [[
<html>
	<head>
		<link href="https://fonts.googleapis.com/css?family=Roboto|Ubuntu+Mono&display=swap" rel="stylesheet">
		<title>LuaJIT Benchmark Tests</title>
		<meta name="description" content="LuaJIT Benchmark tests page. Made for understanding the results and for optimization solutions.">
		<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1.5">
		<meta name="keywords" content="Lua, LuaJIT, benchmark, benchmark tests, performance, LuaJIT vs Lua, LuaJIT performance, Lua performance">
		<link rel="stylesheet" href="style.css">
		<script>
		function OpenTab(evt, tabname) {
			var i, tabcontent, tablinks;
			var n = evt.currentTarget.getAttribute("data-testid")
			tabcontent = document.getElementsByClassName("tabcontent");
			for (i = 0; i < tabcontent.length; i++) {
				if (tabcontent[i].getAttribute("data-testid") === n) {
					tabcontent[i].style.display = "none";
				}
			}
			tablinks = document.getElementsByClassName("tablinks");
			for (i = 0; i < tablinks.length; i++) {
				if (tablinks[i].getAttribute("data-testid") === n) {
					tablinks[i].className = tablinks[i].className.replace(" active", "");
				}
			}
			document.getElementById(tabname).style.display = "block";
			evt.currentTarget.className += " active";
		}

		function ToogleDiff(event,name) {
			if (document.getElementById(name).style.maxHeight === "fit-content") {
				document.getElementById(name).style.maxHeight = "0px";
			} else {
				document.getElementById(name).style.maxHeight = "fit-content";
			}
		}
		</script>
	</head>
	<body>
		<a name="top"></a>
		<div id="g">
			<div style="text-align: center; font-size: 34; padding-top: 50">LuaJIT Benchmarks</div>
		</div>
]]
local file = io.open("index.html", "w")
local tags = {}

local function Add(v)
	file:write(v)
end

local function N()
	file:write("\n")
end

local function End()
	file:write("</")
	file:write(table.remove(tags))
	file:write(">")
end

local function OpenTag(t)
	tags[#tags + 1] = t
end

local function Link(link, text)
	Add([[<a href="]])
	Add(link)
	Add([[">]])

	if text then
		Add(text)
	end

	Add("</a>")
end

local function AddHead()
	Add(head)
end

local function EndHTML()
	Add([[</body></html>]])
	print("Unclosed tags: " .. #tags)
end

--style="padding-top: 3em;"
local function AddHeader(title)
	Add([[<div id="header1">]])
	Add(title)
	Add([[</div>]])
	N()
end

local function AddBottom()
	Add([[
<script>
	var buttons = document.getElementsByClassName("tablinks");
	for (i = 0; i < buttons.length; i++) {
		if (buttons[i].id === "defaultOpen") {
			buttons[i].click()
		}
	}
</script>]])
	Add([[<div id="bottom">]])
	OpenTag("div")
	Link("#top", "Up")
	N()
	Add([[<img src="http://hits.dwyl.io/GitSparTV/LuaJIT-Benchmarks/index.html.svg">]]) N()
	Add([[Made by Spar (Spar#6665)]])
	N()
	Link("https://github.com/GitSparTV/LuaJIT-Benchmarks/", "New benchmark tests are welcome")
	Add([[

Public Domain
2020]])
	End()
end

local function Text()
	Add([[<div id="text">]])
	OpenTag("div")
end

local function Code(code)
	Add([[<div id="code">]])
	Add(code)
	Add([[</div>]])
end

local function InlineCode(code)
	Add([[<a class="inlcode">]])
	Add(code)
	Add([[</a>]])
end

local function TableStart()
	Add([[<div id="tbldiv"><table>]])
end

local function TableEnd()
	Add([[</table></div>]])
end

local function TableLine(r)
	Add("<tr")

	if r then
		Add([[ style="background-color: #e56060;"]])
	end

	Add(">")
	OpenTag("tr")
end

local function TableHeader(c)
	Add([[<th>]])
	Add(c)
	Add([[</th>]])
end

local function TableColumn(c)
	Add([[<td>]])
	Add(c)
	Add([[</td>]])
end

local AnchorHeaders = {}

local function ConstructContent(t)
	AnchorHeaders = t
	Text()

	for i = 1, #t do
		Link("#test" .. i, i .. ". " .. t[i])
		N()
	end

	End()
end

local CurrentTest = 1
local NCodes = 1

local function StartTest(n)
	CurrentTest = n
	NCodes = 1
	AddHeader([[<div id="test]] .. n .. [[">]] .. n .. ". " .. AnchorHeaders[n] .. [[<a class="headinganchor" href="#test]] .. n .. [[">🔗&#xFE0E;</a></div>]])
end

local function Predefines()
	Add([[<div id="subh">Predefines:</div>]])
end

local function TestCode(code, append)
	Add([[<div id="subh">Code ]] .. NCodes .. (append and " (" .. append .. ")" or ""))
	Add([[:</div>]])
	NCodes = NCodes + 1
	Code(code)
end

local function K(n)
	if n >= 1000000 then
		return math.floor(n / 1000000) .. "M"
	elseif n >= 1000 then
		return math.floor(n / 1000) .. "k"
	end

	return n
end

local function PropertySheet(samples, notplain)
	Add([[<div id="subh">Results (]] .. K(samples) .. [[ iterations):</div>]])
	Add(string.format([[
<div class="tab" id="property_sheet%d">
  <button data-testid="%d" class="tablinks" onclick="OpenTab(event, 'jiton_test%d')" id="defaultOpen">LuaJIT</button>
  <button data-testid="%d" class="tablinks" onclick="OpenTab(event, 'jitoff_test%d')">LuaJIT Interpreter</button>]] .. (notplain and "" or [[<button data-testid="%d" class="tablinks" onclick="OpenTab(event, 'plain_test%d')">Lua 5.1</button>]]) .. [[</div>]], CurrentTest, CurrentTest, CurrentTest, CurrentTest, CurrentTest, CurrentTest, CurrentTest, CurrentTest))
end

local function LuaJITOn()
	Add([[<div data-testid="]].. CurrentTest .. [[" id="jiton_test]] .. CurrentTest .. [[" class="tabcontent">]])
	OpenTag("div")
end

local function LuaJITOff()
	Add([[<div data-testid="]].. CurrentTest .. [[" id="jitoff_test]] .. CurrentTest .. [[" class="tabcontent">]])
	OpenTag("div")
end

local function PlainLua()
	Add([[<div data-testid="]].. CurrentTest .. [[" id="plain_test]] .. CurrentTest .. [[" class="tabcontent">]])
	OpenTag("div")
end

local function Diff(code)
	local output = {}

	for line in string.gmatch(code, "[^\n]+") do
		if line:sub(1, 1) == "-" then
			output[#output + 1] = [[<a class="delete">]] .. line .. [[</a>]]
		elseif line:sub(1, 1) == "+" then
			output[#output + 1] = [[<a class="insert">]] .. line .. [[</a>]]
		else
			output[#output + 1] = "  " .. line
		end
	end

	return table.concat(output, "\n")
end

local function Asm(lines, asm)
	Add([[<div id="subh">Assembler Results:</div><ol>]])

	for line in string.gmatch(lines, "[^\n]+") do
		Add([[<li>]])
		local addasm, red

		if line:sub(1, 1) == "!" then
			Add([[<a id="highlight">]])
			line = line:sub(2)
			red = true
		end

		local append = " "

		line = line:gsub(" NYI2%.(%d)", function(n)
			append = append .. [[<a id="redinline" class="inlcode">NYI on LuaJIT 2.]] .. n .. [[</a>]]

			return ""
		end)

		line = line:gsub(" RET2%.(%d)", function(n)
			append = append .. [[<a id="redinline" class="inlcode">Fallbacks to interpreter on LuaJIT 2.]] .. n .. [[</a>]]

			return ""
		end)

		line = line:gsub(" STITCH", function(n)
			append = append .. [[<a id="yellowinline" class="inlcode">Stitches on LuaJIT 2.1</a>]]

			return ""
		end)

		-- line = line:gsub("DEF",function(n)
		-- 	append = append .. [[<a id="yellowinline" class="inlcode">Requires changes in the optimization settings</a>]]
		-- 	return ""
		-- end)
		if line:sub(-1, -1) == "?" then
			line = line:sub(1, -3)
			addasm = true
		end

		Add(line)

		if line:find(": %d+") then
			Add(" instructions total.")
		end

		if red then
			Add([[</a>]])
		end

		if #append ~= 1 then
			Add(append)
		end

		if addasm then
			Add([[<div class="wrap-collabsible">
<input id="collapsible]] .. CurrentTest .. [[" class="toggle" type="checkbox" onclick="ToogleDiff(event,'diff]] .. CurrentTest .. [[')">
<label for="collapsible]] .. CurrentTest .. [[" class="lbl-toggle">Diff</label>
</div><div class="collapsible-content" id="diff]].. CurrentTest .. [[">
<div id="bytecode">]] .. Diff(asm) .. [[
</div>
</div>]])
		end

		Add([[</li>]])
	end

	Add([[</ol>]])
end

local function Benchmark(bench)
	Add([[<div id="subh">Benchmark Results:</div>]])
	TableStart()
	TableLine()
	TableHeader("#")
	TableHeader("Name")
	TableHeader("Median")
	TableHeader("Minimum")
	TableHeader("Maximum")
	TableHeader("Average")
	TableHeader("Percentage")
	End()
	local i = 1

	for line in string.gmatch(bench, "[^\n]+") do
		if line:sub(1, 1) == "!" then
			TableLine(true)
			line = line:sub(2)
		else
			TableLine()
		end

		TableColumn(i)
		i = i + 1
		local Name, Med, Min, Max, Aver, Prefix = string.match(line, "^(.-): ([%d%.]+) %(Min: ([%d%.]+), Max: ([%d%.]+), Average: ([%d%.]+)%) second%(s%)(.+)")
		-- print(Name, Med, Min, Max, Aver, Prefix) -- .. (#Times ~= 0 and " " .. Times:match("%((.-)%)") or "")
		TableColumn(Name)
		TableColumn(Med .. " sec(s)")
		TableColumn(Min)
		TableColumn(Max)
		TableColumn(Aver)
		local Times = string.match(Prefix, "%(%d+ times .-%)")
		TableColumn(string.match(Prefix, " (%(.-%))") .. (Times and " " .. Times or ""))
		End()
	end

	TableEnd()
end

local function Conclusion()
	Add([[<div id="subh">Conclusion:</div><div style="padding: 10px 0px 10px 10px; white-space: pre; overflow: auto;">]])
	OpenTag("div")
end


----------------------------------------------------------------

AddHead()

AddHeader("About")
	Text()
		Add([[These benchmark tests demonstrate the performance of LuaJIT compiler, LuaJIT interpreter and Lua 5.1.
LuaJIT stated that globals and locals now has the same performance unlike in plain Lua.
LuaJIT stated that it's faster than Lua. Even Lua suggests to use LuaJIT for more performance.
LuaJIT uses its own interpreter and compiler and many other optimizations to improve the performance. But is it really fast?]])
	End()

AddHeader("About tests")
	Text()
	Add([[This site contains results and conclusions for LuaJIT compiler, LuaJIT interpreter and Lua 5.1.
LuaJIT interpreter is accounted because it's a useful information for functions in which you 100% sure they won't compile.
Or maybe you're using embedded LuaJIT 2.0 which aborts on any C function (And FFI is disabled).
Lua 5.1 is accounted for you decision in what to choose, or just out of curiosity.
First 14 benchmark tests were taken from ]]) Link("https://springrts.com/wiki/Lua_Performance","this page") N()
		Link("https://github.com/GitSparTV/LuaJIT-Benchmarks/issues/new/","New benchmark tests are welcome.") N() N()
		Add([[Specs: Intel i5-6500 3.20 GHz. 64-bit. LuaJIT 2.1.0-beta3. (Lua 5.1.4 for plain Lua tests) (LuaJIT 2.0.4 for LuaJIT 2.0 assembler tests)
(JIT: ON SSE2 SSE3 SSE4.1 BMI2 fold cse dce fwd dse narrow loop abc sink fuse)]])
	End()

AddHeader("Benchmark Code")
	Text()
		Link("https://github.com/GitSparTV/LuaJIT-Benchmarks/blob/master/bench.lua","Source code") N()
		Add([[For benchmark tests we use the median of 100 takes of the given amount of iterations of the code.]])
		Code([[
for take = 1, 100 do
    local START = os.clock()

    for times = 1, iterations do
        ...
    end

    local END = os.clock()
end]])
		Add([[For assembler tests we use ]]) InlineCode("luajit -jdump=+Arsa asmbench.lua") Add(".\n")
		Add([[The total amount of instructions is based on maximum possible amount (Last jump or RET).
Bytecode size is used from -jdump, not -bl, so it also counts sub-functions instructions and headers.]]) N()
		Link("https://github.com/GitSparTV/LuaJIT-Benchmarks/blob/master/asmbench.lua","Script for bytecode test") Add(".")
	End()

AddHeader("Useful links")
	Text()
		Link("http://wiki.luajit.org/NYI","Things which are likely to cause NYI aborts from the JIT compiler") N()
		Link("http://wiki.luajit.org/Numerical-Computing-Performance-Guide","Tips for writing performant Lua code") N()
		Link("http://wiki.luajit.org/Bytecode-2.0","LuaJIT 2.0 Bytecode reference") N()
		Link("https://luajit.org/","LuaJIT official site")
	End()

AddHeader("Contents")
	ConstructContent({
	"Local vs Global",
	"Local vs Global table indexing",
	"Localized method (3 calls)",
	"Unpack",
	"Find and return maximum value",
	"\"not a\" vs \"a or b\"",
	"\"x ^ 2\" vs \"x * x\" vs \"math.pow\"",
	"\"math.fmod\" vs \"%\" operator",
	"Predefined function or anonymous function in the argument",
	"for loops",
	"Localizing table value for multiple usage",
	"Array insertion",
	"Table with and without pre-allocated size",
	"Table initialization before or each time on insertion",
	"String split (by character)",
	"Empty string check",
	"C array size (FFI)",
	"String concatenation",
	"String in a function",
	"Taking a value from a function with multiple returns",
	})

StartTest(1) -- Local vs Global
	Text()
		Predefines()
			Code([[local t = type]])
		TestCode([[type(3)]])
		TestCode([[t(3)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
!Global: 29
Local: 18 ?
]],[[
mov dword [0x3e2d0410], 0x1	
movsd xmm7, [rdx+0x40]	
cvttsd2si eax, xmm7	
xorps xmm6, xmm6	
cvtsi2sd xmm6, eax	
ucomisd xmm7, xmm6	
jnz 0x7ffa543c0010        ->0	
jpe 0x7ffa543c0010        ->0	
cmp eax, 0x7ffffffe	
jg 0x7ffa543c0010 ->0	
cvttsd2si edi, [rdx+0x38]	
cmp dword [rdx+0x14], -0x09	
jnz 0x7ffa543c0010        ->0	
cmp dword [rdx+0x10], 0x3e2d8228	
- jnz 0x7ffa543c0010        ->0	
- mov edx, [0x3e2d8230]	
- cmp dword [rdx+0x1c], +0x3f	
- jnz 0x7ffa543c0010        ->0	
- mov ecx, [rdx+0x14]	
- mov rsi, 0xfffffffb3e2d2f88	
- cmp rsi, [rcx+0x5a8]	
- jnz 0x7ffa543c0010        ->0	
- cmp dword [rcx+0x5a4], -0x09	
- jnz 0x7ffa543c0010        ->0	
- cmp dword [rcx+0x5a0], 0x3e2d2ef0	
jnz 0x7ffa543c0010        ->0	
add edi, +0x01	
cmp edi, eax	
jg 0x7ffa543c0014 ->1]])
			Conclusion()
				Add([[Each global lookup can cost around 11 instructions. They both run almost on the same speed, but this benchmark tests only one global.
This is still a good practice to localize all variables you need.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
Global: 0.24571 (Min: 0.23929, Max: 0.29617, Average: 0.24856) second(s) (102.83%)
Local: 0.23894 (Min: 0.22918, Max: 0.32741, Average: 0.24434) second(s) (100%)]])
			Conclusion()
				Add([[JIT matches the performance of globals and upvalues. This is a good practice to localize all variables you need, upvalues are still faster.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!Global: 0.9605 (Min: 0.937, Max: 1.075, Average: 0.97355) second(s) (111.42%)
Local: 0.862 (Min: 0.845, Max: 0.939, Average: 0.86418) second(s) (100%)]])
			Conclusion()
				Add([[Upvalues are faster than globals.]])
			End()
		End()
	End()

StartTest(2) -- Local vs Global table indexing
	Text()
		Predefines()
			Code([[local s = math.sin]])
		TestCode([[math.sin(3.14)]])
		TestCode([[s(3.14)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
!Global table indexing: 38
Local: 18 ?]],[[
mov dword [0x24660410], 0x1
movsd xmm7, [rdx+0x40]
cvttsd2si eax, xmm7
xorps xmm6, xmm6
cvtsi2sd xmm6, eax
ucomisd xmm7, xmm6
jnz 0x7ffa543c0010        ->0
jpe 0x7ffa543c0010        ->0
cmp eax, 0x7ffffffe
jg 0x7ffa543c0010 ->0
cvttsd2si edi, [rdx+0x38]
cmp dword [rdx+0x14], -0x09
- jnz 0x7ffa543c0010        ->0
- cmp dword [rdx+0x10], 0x2467f788
- jnz 0x7ffa543c0010        ->0
- mov ebp, [0x2467f790]
- cmp dword [rbp+0x1c], +0x3f
- jnz 0x7ffa543c0010        ->0
- mov ebx, [rbp+0x14]
- mov rsi, 0xfffffffb24665fd8
- cmp rsi, [rbx+0x518]
- jnz 0x7ffa543c0010        ->0
- cmp dword [rbx+0x514], -0x0c
jnz 0x7ffa543c0010        ->0
+ cmp dword [rdx+0x18], 0x2466aca0
- mov edx, [rbx+0x510]
- cmp dword [rdx+0x1c], +0x1f
- jnz 0x7ffa543c0010        ->0
- mov ecx, [rdx+0x14]
- mov rsi, 0xfffffffb24666548
- cmp rsi, [rcx+0x230]
- jnz 0x7ffa543c0010        ->0
- cmp dword [rcx+0x22c], -0x09
- jnz 0x7ffa543c0010        ->0
- cmp dword [rcx+0x228], 0x24666520
jnz 0x7ffa543c0010        ->0
add edi, +0x01
cmp edi, eax
jg 0x7ffa543c0014 ->1]])
			Conclusion()
				Add([[As the first test concluded, each table indexing can cost around 11 additional instructions. Localizing ]]) InlineCode("math") Add(" table won't help much. Localize your variables.")
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!Global table indexing: 0.36948 (Min: 0.36357, Max: 0.3908, Average: 0.37024) second(s) (146.27%)
Local: 0.25259 (Min: 0.24956, Max: 0.26611, Average: 0.25344) second(s) (100%)]])
			Conclusion()
				Add([[Localizing exact value will get you more performance.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!Global table indexing: 0.9335 (Min: 0.884, Max: 1.039, Average: 0.93893) second(s) (120.84%)
Local: 0.7725 (Min: 0.733, Max: 0.889, Average: 0.77743) second(s) (100%)]])
			Conclusion()
				Add([[Localizing exact value will get you more performance.]])
			End()
		End()
	End()

StartTest(3) -- Localized method (3 calls)
	Text()
		Predefines()
			Code([[
local class = {
	test = function() return 1 end
}]])
		TestCode([[
class.test()
class.test()
class.test()]])
		TestCode([[
local test = class.test
test()
test()
test()]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
Direct call: 35
Localized call: 35]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.
However, LuaJIT suggests not to second-guess the JIT compiler, because unnecessary localization can create more complicated code.
Localizing ]]) InlineCode("local c = a+b") Add([[ for ]]) InlineCode("z = x[a+b] + y[a+b]") Add([[ is redundant. JIT perfectly compiles such code as ]]) InlineCode("a[i][j] = a[i][j] * a[i][j+1]") Add(".")
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!Direct call: 0.5611 (Min: 0.55, Max: 0.6099, Average: 0.56474) second(s) (120.64%)
Localized call: 0.46508 (Min: 0.4563, Max: 0.5834, Average: 0.46996) second(s) (100%)]])
			Conclusion()
				Add([[Unlike JIT compiler, JIT interpreter still runs faster with localized functions due to ]]) InlineCode("MOV") Add([[ instruction.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!Direct call: 1.6065 (Min: 1.516, Max: 1.843, Average: 1.62501) second(s) (120.38%)
Localized call: 1.3345 (Min: 1.297, Max: 1.647, Average: 1.35458) second(s) (100%)]])
			Conclusion()
				Add([[Localized function speeds up the code due to ]]) InlineCode("MOV") Add([[ instruction.]])
			End()
		End()
	End()

StartTest(4) -- Unpack
	Text()
		Predefines()
			Code([[
local min = math.min
local unpack = unpack
local a = {100, 200, 300, 400}

local function unpack4(a)
	return a[1], a[2], a[3], a[4]
end]])
		TestCode([[min(a[1], a[2], a[3], a[4])]])
		TestCode([[min(unpack(a))]])
		TestCode([[min(unpack4(a))]])
		PropertySheet(100000000)
		LuaJITOn()
			Benchmark([[
Indexing and unpack4: 0.03403 (Min: 0.0316, Max: 0.05607, Average: 0.03531) second(s) (100%)
!unpack: 4.71555 (Min: 4.54112, Max: 5.6054, Average: 4.75909) second(s) (13858.80%) (138 times slower)]])
			Asm([[
Indexing: 36
!unpack: 46 NYI2.0 RET2.1 ?
unpack4: 36]],[[
mov dword [0x30100410], 0x1
+ movsd xmm6, [0x30149c60]
movsd xmm7, [rdx+0x58]
cvttsd2si eax, xmm7
xorps xmm6, xmm6
cvtsi2sd xmm6, eax
ucomisd xmm7, xmm6
jnz 0x7ffa538b0010        ->0
jpe 0x7ffa538b0010        ->0
cmp eax, 0x7ffffffe
jg 0x7ffa538b0010 ->0
cvttsd2si edi, [rdx+0x50]
cmp dword [rdx+0x2c], -0x09
jnz 0x7ffa538b0010        ->0
cmp dword [rdx+0x28], 0x3010d498
jnz 0x7ffa538b0010        ->0
mov ebx, [0x30110c60]
add ebx, -0x18
cmp ebx, edx
jnz 0x7ffa538b0010        ->0
cmp dword [rdx+0x1c], -0x0c
jnz 0x7ffa538b0010        ->0
- mov edx, [rdx+0x18]
- cmp dword [rdx+0x18], +0x04
- jbe 0x7ffa538b0010        ->0
- mov ecx, [rdx+0x8]
- cmp dword [rcx+0xc], 0xfffeffff
- jnb 0x7ffa538b0010        ->0
- cmp dword [rcx+0x14], 0xfffeffff
- jnb 0x7ffa538b0010        ->0
- cmp dword [rcx+0x1c], 0xfffeffff
- jnb 0x7ffa538b0010        ->0
- cmp dword [rcx+0x24], 0xfffeffff
- jnb 0x7ffa538b0010        ->0
- add edi, +0x01
- cmp edi, eax
- jg 0x7ffa538b0014 ->1
+ xorps xmm7, xmm7
+ cvtsi2sd xmm7, esi
+ mov eax, [0x301004b0]
+ mov eax, [rax+0x20]
+ sub eax, edx
+ cmp eax, 0xa0
+ jb 0x7ffa538b0014 ->1
+ mov dword [rdx+0x94], 0xfffffff4
+ mov [rdx+0x90], edi
+ mov dword [rdx+0x8c], 0x30110bdc
+ mov dword [rdx+0x88], 0x301032c8
+ mov dword [rdx+0x84], 0xfffffff7
+ mov dword [rdx+0x80], 0x30106ae0
+ movsd [rdx+0x78], xmm6
+ mov dword [rdx+0x74], 0x30111748
+ mov dword [rdx+0x70], 0x3010c7a8
+ movsd [rdx+0x68], xmm7
+ movsd [rdx+0x50], xmm7
+ add edx, 0x90
+ mov eax, 0x2
+ mov esi, 0x301004a8
+ mov ebx, 0x30100fe0
+ jmp 0x7ffa297d43c1]])
			Conclusion()
				Add([[Avoid using ]]) InlineCode("unpack") Add([[ for small table with known size. As an alternative you can use this function:]])
				Code([[
do
	local concat = table.concat
	local loadstring = loadstring

	function createunpack(n)
		local ret = {"local t = ... return "}

		for k = 1, n do
			ret[1 + (k-1) * 4] = "t["
			ret[2 + (k-1) * 4] = k
			ret[3 + (k-1) * 4] = "]"
			if k ~= n then ret[4 + (k-1) * 4] = "," end
		end

		return loadstring(concat(ret))
	end
end]])
				Add([[This function has 1 limitation. The maximum number of returned values is 248. The limit of LuaJIT ]]) InlineCode([[unpack]]) Add([[ function is 7999 with default settings.]]) N()
Add([[At least ]]) InlineCode([[createunpack]]) Add([[ can create JIT-compiled unpack (]]) InlineCode([[unpack4]]) Add([[ is basically ]]) InlineCode([[createunpack(4)]]) Add([[)]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
Indexing: 3.73678 (Min: 3.60006, Max: 4.61773, Average: 3.78408) second(s) (100%)
!unpack: 5.56231 (Min: 5.12473, Max: 6.89518, Average: 5.69063) second(s) (148.85%)
unpack4: 4.17394 (Min: 4.12066, Max: 4.90567, Average: 4.34065) second(s) (111.69%)]])
			Conclusion()
				Add([[Avoid using ]]) InlineCode("unpack") Add([[ for small table with known size. As an alternative you can use the function mentioned on LuaJIT tab.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
Indexing: 12.272 (Min: 11.929, Max: 14.207, Average: 12.38047) second(s) (115.97%)
unpack: 10.5815 (Min: 10, Max: 11.586, Average: 10.56572) second(s) (100%)
unpack4: 14.855 (Min: 14.491, Max: 18.836, Average: 15.07444) second(s) (140.38%)]])
			Conclusion()
				Add([[Any method is ok, ]]) InlineCode([[unpack4]]) Add([[ is the slowest probably because of the function call overhead.]])
			End()
		End()
	End()

StartTest(5) -- Find and return maximum value
	Text()
		Predefines()
			Code([[
local max = math.max
local num = 100
local y = 0]])
		TestCode([[local x = max(num, y)]])
		TestCode([[
if (num > y) then
	local x = num
end]])
		TestCode([[local x = num > y and num or x]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
math.min: 18
if (num > y) then: 18
a and b or c: 18]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!math.min: 0.23708 (Min: 0.22686, Max: 0.28223, Average: 0.23841) second(s) (147.10%)
if (num > y) then: 0.16116 (Min: 0.15814, Max: 0.169, Average: 0.16173) second(s) (100%)
a and b or c: 0.18716 (Min: 0.18291, Max: 0.19907, Average: 0.18795) second(s) (116.13%)]])
			Conclusion()
				InlineCode([[math.min]]) Add([[ has a function overhead, which probably makes it slower.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!math.min: 0.647 (Min: 0.621, Max: 0.731, Average: 0.65725) second(s) (134.93%)
if (num > y) then: 0.4795 (Min: 0.464, Max: 0.56, Average: 0.48323) second(s) (100%)
a and b or c: 0.528 (Min: 0.501, Max: 0.726, Average: 0.54099) second(s) (110.11%)]])
			Conclusion()
				InlineCode([[math.min]]) Add([[ has a function overhead, which probably makes it slower.]])
			End()
		End()
	End()

StartTest(6) -- nil check (if vs a or b)
	Text()
		Predefines()
			Code([[local y]])
		TestCode([[if not y then
    local x = 1
else
    local x = y
end]])
		TestCode([[local x = y or 1]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
if: 24
a or b: 24]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
if: 0.13572 (Min: 0.13033, Max: 0.19183, Average: 0.13831) second(s) (100%)
a or b: 0.13608 (Min: 0.12298, Max: 0.23668, Average: 0.13989) second(s) (100.26%)]])
			Conclusion()
				InlineCode([[a or b]]) Add([[ should be faster due to unary test and copy instructions ]]) InlineCode([[ISTC]]) Add([[ and ]]) InlineCode([[ISFC]]) Add([[.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
if: 0.398 (Min: 0.382, Max: 0.484, Average: 0.40146) second(s) (112.11%)
a or b: 0.355 (Min: 0.349, Max: 0.367, Average: 0.35508) second(s) (100%)]])
			Conclusion()
				InlineCode([[a or b]]) Add([[ should be faster due to ]]) InlineCode([[TESTSET]]) Add([[ instruction.]])
			End()
		End()
	End()

StartTest(7) -- x^2 vs x*x vs math.pow
	Text()
		Predefines()
			Code([[local x = 10
local pow = math.pow]])
		TestCode([[local y = x ^ 2]])
		TestCode([[local y = x * x]])
		TestCode([[local y = pow(x, 2)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
x ^ 2: 18
x * x: 18
math.pow: 18]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
x ^ 2: 0.60192 (Min: 0.5671, Max: 0.85234, Average: 0.61451) second(s) (442.13%) (4 times slower)
x * x: 0.13614 (Min: 0.13237, Max: 0.19182, Average: 0.13845) second(s) (100%)
math.pow: 0.69741 (Min: 0.59753, Max: 0.95067, Average: 0.70204) second(s) (512.26%) (5 times slower)
]])
			Conclusion()
				Add([[Use multiply instead of power if you know the exact exponent. ]]) InlineCode([[math.pow]]) Add([[ has a function overhead.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
x ^ 2: 1.044 (Min: 1.023, Max: 1.242, Average: 1.05641) second(s) (269.07%) (2 times slower)
x * x: 0.388 (Min: 0.376, Max: 0.456, Average: 0.39083) second(s) (100%)
math.pow: 1.3125 (Min: 1.211, Max: 1.529, Average: 1.32576) second(s) (338.27%) (3 times slower)]])
			Conclusion()
				Add([[Use multiply instead of power if you know the exact exponent. ]]) InlineCode([[math.pow]]) Add([[ has a function overhead.]])
			End()
		End()
	End()

StartTest(8) -- math.fmod vs % operator
	Text()
		Predefines()
			Code([[local fmod = math.fmod

local function jit_fmod(a, b)
	if b < 0 then b = -b end
	if a < 0 then
		return -(-a % b)
	else
		return a % b
	end
end]])
		TestCode([[local x = fmod(times, 30)]])
		TestCode([[local x = (times % 30)]])
		TestCode([[local x = jit_fmod(times, 30)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
!fmod: 55 NYI2.0 STITCH
%: 18
JITed fmod: 20 ?]],[[
mov dword [0x2add0410], 0x4
movsd xmm7, [rdx+0x48]
cvttsd2si eax, xmm7
xorps xmm6, xmm6
cvtsi2sd xmm6, eax
ucomisd xmm7, xmm6
jnz 0x7ffa543c0010        ->0
jpe 0x7ffa543c0010        ->0
cmp eax, 0x7ffffffe
jg 0x7ffa543c0010 ->0
cvttsd2si edi, [rdx+0x40]
cmp dword [rdx+0x24], -0x09
jnz 0x7ffa543c0010        ->0
cmp dword [rdx+0x20], 0x2adf2c00
jnz 0x7ffa543c0010        ->0
+ test edi, edi
+ jl 0x7ffa543c0014 ->1
add edi, +0x01
cmp edi, eax
jg 0x7ffa543c0018 ->2]])
			Benchmark([[
!fmod: 0.2961 (Min: 0.2885, Max: 0.4984, Average: 0.30364) second(s) (7670.98%) (76 times slower)
% and JITed fmod: 0.00386 (Min: 0.00305, Max: 0.00643, Average: 0.00401) second(s) (100%)]])
			Conclusion()
				Add([[Use ]]) InlineCode([[%]]) Add([[ for positive modulo. For negative or mixed modulo use JITed fmod.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!fmod: 0.33687 (Min: 0.3147, Max: 0.42487, Average: 0.34024) second(s) (239.59%) (2 times slower)
%: 0.1406 (Min: 0.13166, Max: 0.21037, Average: 0.14226) second(s) (100%)
!JITed fmod: 0.35584 (Min: 0.34378, Max: 0.52199, Average: 0.36319) second(s) (253.07%) (2 times slower)]])
			Conclusion()
				Add([[JITed fmod solves compilation problem but it's slower in interpreter mode]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!fmod: 0.7055 (Min: 0.657, Max: 0.842, Average: 0.7135) second(s) (182.77%)
%: 0.386 (Min: 0.374, Max: 0.471, Average: 0.39029) second(s) (100%)
!JITed fmod: 0.858 (Min: 0.812, Max: 1.127, Average: 0.8753) second(s) (222.27%) (2 times slower)]])
			Conclusion()
				Add([[JITed fmod is not recommended for plain Lua. Use module operator for positive numbers and ]]) InlineCode([[math.fmod]]) Add([[ for negative and mixed.]])
			End()
		End()
	End()

StartTest(9) -- Predefined function or anonymous function in argument
	Text()
		Predefines()
			Code([[local func1 = function(a, b, func) return func(a + b) end
local func2 = function(a) return a * 2 end]])
		TestCode([[local x = func1(1, 2, function(a) return a * 2 end)]])
		TestCode([[local x = func1(1, 2, func2)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
!Function in argument: NYI2.1 
Localized function: 18]])
			Benchmark([[
!Function in argument: 0.61696 (Min: 0.57184, Max: 0.81876, Average: 0.62018) second(s) (18791.11%) (187 times slower)
Localized function: 0.00328 (Min: 0.00307, Max: 0.00733, Average: 0.00354) second(s) (100%)]])
			Conclusion()
				Add([[If it's possible, localize your function and re-use it. If you need to provide a local to the closure try different approach of passing values. Simple example is changing state iterator to stateless.
Example of different value passing:]])
				Code([[
function func()
	local a, b = 50, 10

	timer.Simple(5, function()
		print(a + b)
	end)
end]])
			Add([[In this example ]]) InlineCode([[timer.Simple]]) Add([[ can't pass arguments to the function, we can change the style of value passing from function upvalues to main chunk upvalues:]])
			Code([[
local Ua, Ub

local function printAplusB()
	print(Ua + Ub)
end

function func()
	local a, b = 50, 10
	Ua, Ub = a, b
	timer.Simple(5, printAplusB)
end]])
			Add([[Moving function outside allows to compile ]]) InlineCode([[func]]) Add([[.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!Function in argument: 0.61991 (Min: 0.58707, Max: 0.88968, Average: 0.63932) second(s) (166.80%)
Localized function: 0.37165 (Min: 0.33582, Max: 0.4346, Average: 0.37056) second(s) (100%)]])
			Conclusion()
				Add([[If it's possible, localize your function and re-use it. See a possible solution on LuaJIT tab.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!Function in argument: 1.7375 (Min: 1.646, Max: 2.083, Average: 1.75102) second(s) (185.63%)
Localized function: 0.936 (Min: 0.915, Max: 1.028, Average: 0.94642) second(s) (100%)]])
			Conclusion()
				Add([[If it's possible, localize your function and re-use it. See a possible solution on LuaJIT tab.]])
			End()
		End()
	End()

StartTest(10) -- for loops
	Text()
		Predefines()
			Code([[local a = {}

for i = 1, 100 do
	a[i] = i
end

a.n = 100
a[0] = 100
local length = #a
local nxt = next

function jit_pairs(t)
	return nxt, t
end]])
		TestCode([[
for k, v in pairs(a) do
	local x = v
end]])
		TestCode([[
for k, v in jit_pairs(a) do
	local x = v
end]],[[Using <a href="https://github.com/LuaJIT/LuaJIT/pull/275">JITed next on 2.1.0-beta2</a>]])
		TestCode([[
for k, v in ipairs(a) do
	local x = v
end]])
		TestCode([[
for i = 1, 100 do
	local x = a[i]
end]])
		TestCode([[
for i = 1, #a do
	local x = a[i]
end]])
		TestCode([[
for i = 1, length do
	local x = a[i]
end]])
		TestCode([[
for i = 1, a.n do
	local x = a[i]
end]])
		TestCode([[
for i = 1, a[0] do
	local x = a[i]
end]])
		PropertySheet(1000000)
		LuaJITOn()
			Asm([[
!pairs: NYI2.1
JITed pairs: 119
Known length: 56
ipairs: 104
#a: 78
Upvalued length: 60
a.n: 89
a[0]: 80]])
			Benchmark([[
!pairs: 0.51975 (Min: 0.48428, Max: 0.63495, Average: 0.52525) second(s) (757.87%) (7 times slower)
!JITed pairs: 0.41983 (Min: 0.39041, Max: 0.52863, Average: 0.41906) second(s) (612.17%) (6 times slower)
ipairs: 0.12707 (Min: 0.12164, Max: 0.20861, Average: 0.13086) second(s) (185.28%)
Known length: 0.11527 (Min: 0.11252, Max: 0.15329, Average: 0.1175) second(s) (168.08%)
#a: 0.12063 (Min: 0.10235, Max: 0.17138, Average: 0.1199) second(s) (175.89%)
Upvalued length: 0.08333 (Min: 0.07875, Max: 0.17807, Average: 0.08744) second(s) (121.50%)
a.n: 0.08724 (Min: 0.08448, Max: 0.10026, Average: 0.08813) second(s) (127.20%)
a[0]: 0.06858 (Min: 0.06673, Max: 0.09873, Average: 0.07049) second(s) (100%)]])
			Conclusion()
				Add([[a[0] or a.n are the best solution you can use. (If you have ]]) InlineCode([[table.pack]]) Add([[ you may remember it creates a sequential table and adds ]]) InlineCode([[n]]) Add([[ with the size of the created table this can be used for iteration)]]) N()
				Add([[JITed pairs is still slow but it will compile.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
pairs: 0.51711 (Min: 0.48241, Max: 0.67666, Average: 0.5224) second(s) (100%)
JITed pairs: 1.80467 (Min: 1.62461, Max: 2.02158, Average: 1.77821) second(s) (348.99%) (3 times slower)
ipairs: 1.70326 (Min: 1.64163, Max: 2.1924, Average: 1.72125) second(s) (329.38%) (3 times slower)
Known length: 0.67382 (Min: 0.6603, Max: 0.85948, Average: 0.68079) second(s) (130.30%)
#a: 0.6967 (Min: 0.68416, Max: 0.74215, Average: 0.70065) second(s) (134.72%)
Upvalued length: 0.67209 (Min: 0.6611, Max: 0.77354, Average: 0.67794) second(s) (129.97%)
a.n: 0.69201 (Min: 0.66747, Max: 1.00413, Average: 0.7115) second(s) (133.82%)
a[0]: 0.6715 (Min: 0.66014, Max: 0.77048, Average: 0.67611) second(s) (129.85%)]])
			Conclusion()
				Add([[These results requires an explanation, no conclusion can be made.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!pairs: 3.5325 (Min: 3.241, Max: 3.968, Average: 3.51657) second(s) (193.03%)
ipairs: 3.226 (Min: 3.059, Max: 4.155, Average: 3.24595) second(s) (176.28%)
Known length: 1.83 (Min: 1.753, Max: 2.005, Average: 1.83169) second(s) (100%)
#a: 1.8305 (Min: 1.755, Max: 2.114, Average: 1.84612) second(s) (100.02%)
Upvalued length: 1.8775 (Min: 1.794, Max: 2.452, Average: 1.9197) second(s) (102.59%)
a.n: 1.8815 (Min: 1.773, Max: 2.248, Average: 1.89361) second(s) (102.81%)
a[0]: 1.841 (Min: 1.779, Max: 2.197, Average: 1.86906) second(s) (100.60%)
]])
			Conclusion()
				Add([[a[0] and a.n are fast as in compiled LuaJIT.]])
			End()
		End()
	End()

StartTest(11) -- Localizing table value for multiple uses
	Text()
		Predefines()
			Code([[local a = {}

for i = 1, 100 do
	a[i] = {
		x = 10
	}
end]])
		TestCode([[for n = 1, 100 do
	a[n].x = a[n].x + 1
end]])
		TestCode([[local a = a

for n = 1, 100 do
	local y = a[n]
	y.x = y.x + 1
end]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
No localization: 64
Localized a and a[n]: 64 ?]],[[
mov dword [0x29550410], 0x4
mov edx, [0x295504b4]
movsd xmm15, [0x295807c0]
movsd xmm14, [0x29580790]
movsd xmm6, [0x29580780]
cmp dword [rdx-0x4], 0x2955bb3c
jnz 0x7ffa5abd0014        ->1
add edx, -0x60
mov [0x295504b4], edx
movsd xmm13, [rdx+0x40]
movsd xmm7, [rdx+0x38]
addsd xmm7, xmm15
ucomisd xmm13, xmm7
jb 0x7ffa5abd0018 ->2
cmp dword [rdx+0x14], -0x09
+ jnz 0x7ffa5abd001c        ->3
+ cmp dword [rdx+0x18], 0x2959ab30
+ jnz 0x7ffa5abd001c        ->3
+ mov edi, [0x2959ab20]
+ add edi, -0x08
+ cmp edi, edx
jnz 0x7ffa5abd001c        ->3
cmp dword [rdx+0x10], 0x2959aaf0
jnz 0x7ffa5abd001c        ->3
+ mov edi, [rdx+0x8]
+ movsd [rdx+0x88], xmm15
movsd [rdx+0x80], xmm15
movsd [rdx+0x78], xmm15
movsd [rdx+0x70], xmm14
- movsd [rdx+0x68], xmm15
+ mov dword [rdx+0x6c], 0xfffffff4
+ mov [rdx+0x68], edi
movsd [rdx+0x60], xmm6
mov dword [rdx+0x5c], 0x2955bb3c
mov dword [rdx+0x58], 0x2959aaf0
movsd [rdx+0x38], xmm7
add edx, +0x60
mov [0x295504b4], edx
jmp 0x7ffa5abdfdc1
mov dword [0x29550410], 0x2
movsd xmm0, [0x29592110]
cvttsd2si edi, [rdx+0x8]
- mov r10d, [rdx-0x8]
- mov esi, [r10+0x14]
- mov r9d, [rsi+0x10]
- mov ebx, r9d
- sub ebx, edx
- cmp ebx, +0x30
- jbe 0x7ffa5abd0010        ->0
cmp dword [r9+0x4], -0x0c
jnz 0x7ffa5abd0010        ->0
mov r8d, [r9]
cmp dword [r8+0x18], +0x64
jbe 0x7ffa5abd0010        ->0
mov eax, [r8+0x8]
cmp dword [rax+rdi*8+0x4], -0x0c
jnz 0x7ffa5abd0010        ->0
mov edx, [rax+rdi*8]
- cmp ebx, +0x38
- jbe 0x7ffa5abd0010        ->0
cmp dword [rdx+0x1c], +0x01
jnz 0x7ffa5abd0010        ->0
mov ecx, [rdx+0x14]
mov rsi, 0xfffffffb2955a520
cmp rsi, [rcx+0x20]
jnz 0x7ffa5abd0010        ->0
cmp dword [rcx+0x1c], 0xfffeffff
jnb 0x7ffa5abd0010        ->0
movsd xmm1, [rcx+0x18]
addsd xmm1, xmm0
movsd [rcx+0x18], xmm1
add edi, +0x01
cmp edi, +0x64
jg 0x7ffa5abd0014 ->1]])
			Conclusion()
				Add([[You may localize your values for interpreter.
However, LuaJIT suggests not try to second-guess the JIT compiler because in compiled code locals and upvalues are used directly by their reference pointer, making over-localization may complicate the compiled code.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
!No localization: 19.37724 (Min: 19.18286, Max: 21.82537, Average: 19.48628) second(s) (137.26%)
Localized a and a[n]: 14.11709 (Min: 13.8045, Max: 17.69585, Average: 14.28717) second(s) (100%)]])
			Conclusion()
				Add([[If your code can't compile, localization is best you can do here.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
!No localization: 58.832 (Min: 56.511, Max: 70.485, Average: 60.3759) second(s) (120.64%)
Localized a and a[n]: 48.7655 (Min: 41.021, Max: 53.683, Average: 46.57903) second(s) (100%)]])
			Conclusion()
				Add([[Localization speeds up the code.]])
			End()
		End()
	End()

StartTest(12) -- Array insertion
	Text()
		Predefines()
			Code([[local a = {
	[0] = 0
}

local tinsert = table.insert
local count = 1]])
		TestCode([[tinsert(a, times)]])
		TestCode([[a[times] = times]])
		TestCode([[a[#a + 1] = times]])
		TestCode([[a[count] = times
count = count + 1]])
		TestCode([=[a[0] = a[0] + 1
a[a[0]] = times]=])
		PropertySheet(1000000)
		LuaJITOn()
			Asm([=[
tinsert: 77
a[times]: 74
a[#a + 1]: 85
a[count]: 102
a[a[0]]: 100]=])
			Benchmark([=[
tinsert: 0.09991 (Min: 0.09609, Max: 0.15484, Average: 0.10376) second(s) (100%)
a[times]: 0.00604 (Min: 0.00521, Max: 0.01118, Average: 0.00618) second(s) (6.04%) (16 times faster)
a[#a + 1]: 0.10071 (Min: 0.09641, Max: 0.22354, Average: 0.10418) second(s) (100.80%)
!a[count]: 0.11952 (Min: 0.08053, Max: 0.1938, Average: 0.1229) second(s) (119.62%)
a[a[0]]: 0.00943 (Min: 0.00864, Max: 0.01265, Average: 0.00972) second(s) (9.43%) (10 times faster)
]=])
			Conclusion()
				Add([[Please notice that percentage calculation is taken from other result.
Using a local or a constant value is the fastest method. If possible use ]]) InlineCode([=[a[0]++; a[a[0]] = times]=]) Add([[, otherwise use ]]) InlineCode([[#a + 1]]) Add([[.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([=[
tinsert: 0.14412 (Min: 0.13741, Max: 0.21978, Average: 0.14607) second(s) (105.38%)
a[times]: 0.01975 (Min: 0.01839, Max: 0.03411, Average: 0.02016) second(s) (14.44%) (6 times faster)
a[#a + 1]: 0.13676 (Min: 0.13096, Max: 0.19211, Average: 0.13932) second(s) (100%)
!a[count]: 0.19627 (Min: 0.14492, Max: 0.28874, Average: 0.20626) second(s) (143.51%)
a[a[0]]: 0.03491 (Min: 0.03222, Max: 0.0404, Average: 0.03516) second(s) (25.52%) (3 times faster)]=])
			Conclusion()
Add([[Please notice that percentage calculation is taken from other result.
Using a local or a constant value is the fastest method. If possible use ]]) InlineCode([=[a[0]++; a[a[0]] = times]=]) Add([[, otherwise use ]]) InlineCode([[#a + 1]]) Add([[.]])
			End()
		End()
			
		PlainLua()
			Benchmark([=[
tinsert: 0.137 (Min: 0.131, Max: 0.175, Average: 0.14059) second(s) (228.33%) (2 times slower)
a[times]: 0.06 (Min: 0.057, Max: 0.069, Average: 0.06068) second(s) (100%)
a[#a + 1]: 0.137 (Min: 0.13, Max: 0.236, Average: 0.14064) second(s) (228.33%) (2 times slower)
!a[count]: 0.5095 (Min: 0.146, Max: 1.106, Average: 0.55534) second(s) (849.16%) (8 times slower)
a[a[0]]: 0.115 (Min: 0.111, Max: 0.149, Average: 0.11667) second(s) (191.66%)
]=])
			Conclusion()
				Add([[Please notice that percentage calculation is taken from other result.
Using a local or a constant value is the fastest method. If possible use ]]) InlineCode([=[a[0]++; a[a[0]] = times]=]) Add([[, otherwise use ]]) InlineCode([[#a + 1]]) Add([[.]])
			End()
		End()
	End()

StartTest(13) -- Table with and without pre-allocated size
	Text()
		Predefines()
			Code([[local a
require("table.new")
local new = table.new
local ffinew = ffi.new]])
		TestCode([[local a = {}
a[1] = 1
a[2] = 2
a[3] = 3]])
		TestCode([[local a = {true, true, true}
a[1] = 1
a[2] = 2
a[3] = 3]])
		TestCode([[local a = new(3,0)
a[1] = 1
a[2] = 2
a[3] = 3]],[[table.new is available since LuaJIT v2.1.0-beta1]])
		TestCode([[local a = {1, 2, 3}]])
		TestCode([[local a = ffinew("int[3]", 1, 2, 3)]],"FFI")
		TestCode([[local a = ffinew("int[3]")
a[0] = 1
a[1] = 2
a[2] = 3]],"FFI")
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
!Allocated on demand: 96
Pre-allocated with dummy values: 18
!Pre-allocated by table.new: 82
Defined in constructor: 18
(FFI) Defined in constructor: 18
(FFI) Defined after: 18]])
			Benchmark([[
!Allocated on demand: 1.26337 (Min: 1.24794, Max: 1.53786, Average: 1.2751) second(s) (39480.31%) (394 times slower)
Pre-allocated with dummy values: 0.0032 (Min: 0.00312, Max: 0.00358, Average: 0.00322) second(s) (100%)
!Pre-allocated by table.new: 0.41859 (Min: 0.4055, Max: 0.49486, Average: 0.42476) second(s) (13080.93%) (130 times slower)
Defined in constructor: 0.00325 (Min: 0.00306, Max: 0.00411, Average: 0.00329) second(s) (101.56%)
(FFI) Defined in constructor: 0.00325 (Min: 0.0031, Max: 0.00425, Average: 0.00331) second(s) (101.56%)
(FFI) Defined after: 0.00339 (Min: 0.00312, Max: 0.00463, Average: 0.00351) second(s) (105.93%)
]])
			Conclusion()
				Add([[Pre-allocation will speed up your code if you need more speed.
In 50% cases tables are used without pre-allocated space, so it's ok to allocate them on demand.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
Allocated on demand: 1.73737 (Min: 1.7137, Max: 1.90643, Average: 1.74489) second(s) (310.27%) (3 times slower)
Pre-allocated with dummy values: 0.61846 (Min: 0.61472, Max: 0.6396, Average: 0.61924) second(s) (110.44%)
Pre-allocated by table.new: 0.86155 (Min: 0.81076, Max: 1.41348, Average: 0.86788) second(s) (153.86%)
Defined in constructor: 0.55995 (Min: 0.53821, Max: 0.63602, Average: 0.56426) second(s) (100%)
(FFI) Defined in constructor: 3.09061 (Min: 2.94983, Max: 3.91517, Average: 3.18377) second(s) (551.94%) (5 times slower)
(FFI) Defined after: 4.46811 (Min: 4.18024, Max: 5.32326, Average: 4.61457) second(s) (797.94%) (7 times slower)]])
			Conclusion()
				Add([[Pre-allocation will speed up your code if you need more speed.
In 50% cases tables are used without pre-allocated space, so it's ok to allocate them on demand.
If you don't need to use FFI array don't use it for the CPU optimization (unless for RAM).]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
Allocated on demand: 5.304 (Min: 5.243, Max: 5.694, Average: 5.32726) second(s) (196.88%)
Pre-allocated with dummy values: 2.863 (Min: 2.676, Max: 3.763, Average: 2.9231) second(s) (106.27%)
Defined in constructor: 2.694 (Min: 2.303, Max: 3.364, Average: 2.65954) second(s) (100%)]])
			Conclusion()
				Add([[Pre-allocation will speed up your code if you need more speed.
In 50% cases tables are used without pre-allocated space, so it's ok to allocate them on demand.]])
			End()
		End()
	End()

StartTest(14) -- (REDO) Table initialization before or each time on insertion
	Text()
		Predefines() 
			Code([[local T = {}
local CachedTable = {"abc", "def", "ghk"}]])
		TestCode([[T[times] = CachedTable]])
		TestCode([[T[times] = {"abc", "def", "ghk"}]])
		PropertySheet(1000000)
		LuaJITOn()
			Asm([[
Cached table for all insertion: 101
!Table constructor for each insertion: 110]])
			Benchmark([[
Cached table for all insertion: 0.00101 (Min: 0.00077, Max: 0.00259, Average: 0.0011) second(s) (100%)
Table constructor for each insertion: 0.02134 (Min: 0.01942, Max: 0.16945, Average: 0.02367) second(s) (2105.28%) (21 times slower)]])
			Conclusion()
				Add([[If this possible, cache your table.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
Cached table for all insertion: 0.0181 (Min: 0.01671, Max: 0.02724, Average: 0.0186) second(s) (100%)
Table constructor for each insertion: 0.03385 (Min: 0.03194, Max: 0.12204, Average: 0.03555) second(s) (186.97%)]])
			Conclusion()
				Add([[If this possible, cache your table.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
Cached table for all insertion: 0.048 (Min: 0.045, Max: 0.061, Average: 0.0493) second(s) (100%)
Table constructor for each insertion: 0.211 (Min: 0.19, Max: 0.356, Average: 0.21706) second(s) (439.58%) (4 times slower)]])
			Conclusion()
				Add([[If this possible, cache your table.]])
			End()
		End()
	End()

StartTest(15) -- String split (by character)
	Text()
		Predefines()
			Code([[local text = "Hello, this is an example text"
local cstring = ffi.cast("const char*", text)
local char = string.char
local sub, gsub, gmatch = string.sub, string.gsub, string.gmatch

local gsubfunc = function(s)
	local x = s
end]])
		TestCode([[for i = 1, #text do
	local x = sub(text, i, i)
end]])
		TestCode([[for k in gmatch(text, ".") do
    local x = k
end]])
		TestCode([[gsub(text, ".", gsubfunc)]])
		TestCode([[for i = 0, #text - 1 do
	local x = char(cstring[i])
end]],"FFI")
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
sub(i,i): 49
gmatch: 114 NYI2.0 STITCH
gsub: 65 NYI2.0 STITCH
(FFI) const char indexing: 48 NYI2.0]])
			Benchmark([[
sub: 0.03063 (Min: 0.0257, Max: 0.06535, Average: 0.03253) second(s) (114.12%)
gmatch: 1.66512 (Min: 1.6147, Max: 2.3234, Average: 1.75248) second(s) (6203.87%) (62 times slower)
gsub: 2.28969 (Min: 2.21768, Max: 2.77874, Average: 2.32719) second(s) (8530.88%) (85 times slower)
(FFI) const char indexing: 0.02684 (Min: 0.02552, Max: 0.03212, Average: 0.02705) second(s) (100%)]])
			Conclusion()
				Add([[If you're using FFI on LuaJIT 2.1.0 and higher, splitting will be the fastest.
Probably you wouldn't need to split it because ffi arrays are mutable, so all text manipulations can be done directly. Otherwise use ]]) InlineCode([[string.sub]]) Add([[.
It's recommended to use ]]) InlineCode([[string.find]]) Add([[, ]]) InlineCode([[string.match]]) Add([[, etc if possible. Splitting each char wastes GC.]])
			End()
		End()

		LuaJITOff()
			Benchmark([[
sub: 0.70481 (Min: 0.68331, Max: 1.25768, Average: 0.75732) second(s) (100%)
gmatch: 1.4904 (Min: 1.44831, Max: 2.05846, Average: 1.53365) second(s) (211.46%) (2 times slower)
gsub: 2.12422 (Min: 2.07281, Max: 2.61494, Average: 2.16115) second(s) (301.38%) (3 times slower)
(FFI) const char indexing:: 2.31658 (Min: 2.18599, Max: 3.02638, Average: 2.35951) second(s) (328.68%) (3 times slower)]])
			Conclusion()
				Add([[Use ]]) InlineCode([[string.sub]]) Add([[.
It's recommended to use ]]) InlineCode([[string.find]]) Add([[, ]]) InlineCode([[string.match]]) Add([[, etc if possible. Splitting each char wastes GC.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
sub: 1.6025 (Min: 1.558, Max: 2.258, Average: 1.68562) second(s) (100%)
gmatch: 2.157 (Min: 2.092, Max: 2.394, Average: 2.16154) second(s) (134.60%)
gsub: 2.6765 (Min: 2.273, Max: 3.131, Average: 2.57897) second(s) (167.02%)]])
			Conclusion()
				Add([[Use ]]) InlineCode([[string.sub]]) Add([[.
It's recommended to use ]]) InlineCode([[string.find]]) Add([[, ]]) InlineCode([[string.match]]) Add([[, etc if possible. Splitting each char wastes GC.]])
			End()
		End()
	End()

StartTest(16) -- Empty string check
	Text()
		Predefines()
			Code([=[local s = ""
local cstring = ffi.cast("const char*", s)
ffi.cdef([[
    size_t strlen ( const char * str );
]])
local C = ffi.C]=])
		TestCode([[local x = #s == 0]])
		TestCode([[local x = s == ""]])
		TestCode([[local x = cstring[0] == 0]],"FFI")
		TestCode([[local x = C.strlen(cstring) == 0]],"FFI")
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
#s == 0: 18
s == "": 18
cstring[0] == 0: 21
!C.strlen(cstring) == 0: 59]])
			Benchmark([[
#s == 0 and s == "": 0.00328 (Min: 0.00308, Max: 0.01392, Average: 0.00364) second(s) (100%)
cstring[0] == 0: 0.00362 (Min: 0.00307, Max: 0.00699, Average: 0.00391) second(s) (110.36%)
!C.strlen(cstring) == 0: 0.02658 (Min: 0.02398, Max: 0.04405, Average: 0.02779) second(s) (810.36%) (8 times slower)]])
			Conclusion()
				Add([[If you're using FFI, use Lua syntax to check empty string.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
#s == 0: 0.17336 (Min: 0.16405, Max: 0.27169, Average: 0.18419) second(s) (125.75%)
s == "": 0.13785 (Min: 0.13267, Max: 0.18884, Average: 0.1399) second(s) (100%)
cstring[0] == 0: 0.66383 (Min: 0.64888, Max: 0.7367, Average: 0.66915) second(s) (481.55%) (4 times slower)
!C.strlen(cstring) == 0: 2.19199 (Min: 2.1318, Max: 2.52241, Average: 2.19931) second(s) (1590.12%) (15 times slower)]])
			Conclusion()
				Add([[If you're using FFI, use Lua syntax to check empty string.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
#s == 0: 0.4685 (Min: 0.456, Max: 0.649, Average: 0.48129) second(s) (107.82%)
s == "": 0.4345 (Min: 0.412, Max: 0.545, Average: 0.44393) second(s) (100%)]])
			Conclusion()
				Add([[String comparison is a little bit faster than length comparison.]])
			End()
		End()
	End()

StartTest(17) -- C array size (FFI)
	Text()
		Predefines()
			Code([[new = ffi.new]])
		TestCode([[new("const char*[16]")
new("const char*[1024]")
new("int[16]")
new("int[1024]")]])
		TestCode([[new("const char*[?]", 16)
new("const char*[?]", 1024)
new("int[?]", 16)
new("int[?]", 1024)]])
		PropertySheet(1000000,true)
		LuaJITOn()
			Asm([[
[n]: 113 NYI2.0
VLA: 105 NYI2.0]])
			Benchmark([[
[n]: 2.64742 (Min: 2.20694, Max: 4.07516, Average: 2.68361) second(s) (105.73%)
VLA: 2.50381 (Min: 2.01546, Max: 3.85597, Average: 2.47497) second(s) (100%)]])
			Conclusion()
				Add([[For some reason LuaJIT 2.0 is not able to compile any C type. Use VLA if possible.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
[n]: 4.32618 (Min: 3.7442, Max: 5.66979, Average: 4.37286) second(s) (102.28%)
VLA: 4.22957 (Min: 3.54316, Max: 5.77651, Average: 4.20961) second(s) (100%)]])
			Conclusion()
				Add([[Use VLA if possible.]])
			End()
		End()
	End()

StartTest(18) -- String concatenation
	Text()
		Predefines()
			Code([[local bs = string.rep("----------", 1000)
local t = {bs, bs, bs, bs, bs, bs, bs, bs, bs, bs}
local concat = table.concat
local format = string.format]])
		TestCode([[local s = bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs .. bs]])
		TestCode([[local s = bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs
s = s .. bs]])
		TestCode([[local s = bs

for i = 1, 9 do
    s = s .. bs
end]])
		TestCode([[concat(t)]])
		TestCode([[format("%s%s%s%s%s%s%s%s%s%s", bs, bs, bs, bs, bs, bs, bs, bs, bs, bs)]])
		PropertySheet(100000)
		LuaJITOn()
			Asm([[
Inline concat: 18 NYI2.0
Separate concat: 18 NYI2.0
!Loop concat: 94 NYI2.0
table.concat: 39 NYI2.0
string.format: 18 NYI2.0]])
			Benchmark([[
Inline, separate concat and string.format: 0.00003 (Min: 0.00003, Max: 0.00415, Average: 0.00012) second(s) (0.009986%) (10014 times faster)
!Loop concat: 6.70725 (Min: 5.60963, Max: 8.0101, Average: 6.57035) second(s) (2232.55%) (22 times slower)
table.concat: 0.30043 (Min: 0.26492, Max: 0.37815, Average: 0.30172) second(s) (100%)
]])
			Conclusion()
				Add([[Please notice that percentage calculation is taken from other result.
This is an example when LuaJIT fails to optimize and compile code efficiently. The loop wasn't unrolled properly.
LuaJIT suggest to find a balance between loops and unrolls and use templates.
]]) InlineCode([[table.concat]]) Add([[ is best solution in complicated code, however, if it's possible make concats inline or unroll loops.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
Inline concat: 1.44256 (Min: 1.42674, Max: 1.76183, Average: 1.46447) second(s) (100%)
!Separate concat: 5.82289 (Min: 5.44671, Max: 7.76331, Average: 5.9645) second(s) (403.64%) (4 times slower)
!Loop concat: 6.61971 (Min: 5.70944, Max: 7.64707, Average: 6.6218) second(s) (458.88%) (4 times slower)
table.concat: 1.49022 (Min: 1.41849, Max: 1.95012, Average: 1.56112) second(s) (103.30%)
string.format: 1.46481 (Min: 1.42773, Max: 2.05097, Average: 1.52796) second(s) (101.54%)]])
			Conclusion()
				Add([[If it's possible inline your concats, otherwise use ]]) InlineCode([[table.concat]]) Add([[.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
Inline concat: 1.023 (Min: 1.01, Max: 1.296, Average: 1.04552) second(s) (100%)
!Separate concat: 10.445 (Min: 9.918, Max: 12.909, Average: 10.63149) second(s) (1021.01%) (10 times slower)
!Loop concat: 11.723 (Min: 9.919, Max: 14.472, Average: 11.64345) second(s) (1145.94%) (11 times slower)
table.concat: 2.151 (Min: 2.083, Max: 2.378, Average: 2.16366) second(s) (210.26%) (2 times slower)
string.format: 2.179 (Min: 2.116, Max: 3.099, Average: 2.26572) second(s) (213%) (2 times slower)]])
			Conclusion()
				Add([[If it's possible inline your concats, otherwise use ]]) InlineCode([[table.concat]]) Add([[.]])
			End()
		End()
	End()

StartTest(19) -- Constant variables in functions
	Text()
		Predefines()
			Code([[local TYPE_bool = "bool"
local type = type
local function isbool1(b)
    return type(b) == "bool"
end

local function isbool2(b)
    return type(b) == TYPE_bool
end]])
		TestCode([[isbool1(false)]])
		TestCode([[isbool2(false)]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
KGC string: 18
Upvalued string: 18]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
KGC string: 0.39173 (Min: 0.37698, Max: 0.63159, Average: 0.41579) second(s) (100%)
Upvalued string: 0.40781 (Min: 0.3934, Max: 0.51813, Average: 0.4151) second(s) (104.10%)]])
			Conclusion()
				Add([[If possible use literal strings in the function.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
KGC string: 1.324 (Min: 1.26, Max: 1.99, Average: 1.37005) second(s) (100%)
Upvalued string: 1.3915 (Min: 1.268, Max: 1.773, Average: 1.40522) second(s) (105.09%)]])
			Conclusion()
				Add([[If possible use literal strings in the function.]])
			End()
		End()
	End()

StartTest(20) -- Taking value from "Multiple Return" function
	Text()
		Predefines()
			Code([[local function funcmret()
    return 1, 2
end

local select = select]])
		TestCode([[local _, arg2 = funcmret()
return arg2]])
		TestCode([[local arg2 = select(2, funcmret())
return arg2]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[
With dummy variables: 18
select: 18]])
			Conclusion()
				Add([[LuaJIT compiles them with the same performance.]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[
With dummy variables: 0.25193 (Min: 0.24568, Max: 0.27575, Average: 0.25267) second(s) (100%)
!select: 0.38455 (Min: 0.37498, Max: 0.4397, Average: 0.38579) second(s) (152.63%)]])
			Conclusion()
				InlineCode([[select]]) Add([[ makes no sense for functions with less than 10 (at least) returned values, all returned values are pushed to the stack. Any value you choose will can be pushed up individually.
Tip: if you need only first argument wrap the function call in the parenthesizes.]])
				Code([[print( (math.frexp(0)) )]])
				Add([[This will print only the first value.]])
			End()
		End()
			
		PlainLua()
			Benchmark([[
With dummy variables: 0.611 (Min: 0.6, Max: 0.702, Average: 0.61562) second(s) (100%)
!select: 0.813 (Min: 0.786, Max: 0.926, Average: 0.81984) second(s) (133.06%)]])
			Conclusion()
				InlineCode([[select]]) Add([[ makes no sense for functions with less than 10 (at least) returned values, all returned values are pushed to the stack. Any value you choose will can be pushed up individually.
Tip: if you need only first argument wrap the function call in the parenthesizes.]])
				Code([[print( (math.frexp(0)) )]])
				Add([[This will print only the first value.]])
			End()
		End()
	End()

AddBottom()	
EndHTML()

--[==[
StartTest(2) -- Local vs Global
	Text()
		Predefines()
			Code([[]])
		TestCode([[]])
		TestCode([[]])
		PropertySheet(10000000)
		LuaJITOn()
			Asm([[]],[[]])
			Conclusion()
				Add([[]])
			End()
		End()
			
		LuaJITOff()
			Benchmark([[]])
			Conclusion()
				Add([[]])
			End()
		End()
			
		PlainLua()
			Benchmark([[]])
			Conclusion()
				Add([[]])
			End()
		End()
	End()
]==]