xbench = {}

local os_clock 	= os.clock
local pairs 	= pairs
local tostring 	= tostring
local MsgC 		= MsgC

local col_white = Color(250,250,250)
local col_red 	= Color(255,0,0)
local col_green = Color(0,255,0)

local stack = {}
function xbench.Push()
	stack[#stack + 1] = os_clock()
end

function xbench.Pop()
	local ret = stack[#stack]
	stack[#stack] = nil
	return os_clock() - ret
end

function xbench.Run(func, calls)
	xbench.Push()
	for i = 1, (calls or 1000) do
		func()
	end
	return xbench.Pop()
end

function xbench.Compare(funcs, calls)
	local lowest = math.huge
	local results = {}
	for k, v in pairs(funcs) do
		local runtime = xbench.Run(v, calls)
		results[k] = runtime
		if (runtime < lowest) then
			lowest = runtime
		end
	end
	for k, v in pairs(results) do
		if (v == lowest) then
			MsgC(col_green, tostring(k):upper() .. ': ', col_white, v .. '\n')
		else
			MsgC(col_red, tostring(k):upper() .. ': ', col_white, v .. '\n')
		end
	end
end