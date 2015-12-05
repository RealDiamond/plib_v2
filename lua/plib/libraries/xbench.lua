xbench = {}

local os_clock 	= os.clock
local pairs 	= pairs

local col_white = Color(250,250,250)
local col_red 	= Color(255,0,0)
local col_green = Color(0,255,0)

local start_time = 0
function xbench.Push()
	start_time = os_clock()
end

function xbench.Pop()
	return os_time() - start_time
end

function xbench.Run(func, calls)
	xbench.Push()
	for i = 1, (calls or 1000) do
		func()
	end
	print(xbench.Pop())
end

function xbench.Compare(funcs, calls)
	local lowest = -1
	local results = {}
	for k, v in pairs(funcs) do
		xbench.Push()
		for i = 1, (calls or 1000) do
			v()
		end
		local runtime = xbench.Pop()
		results[k] = runtime
		if (runtime < lowest) then
			lowest = runtime
		end
	end
	for k, v in pairs(results) do
		if (v == lowest) then
			MsgC(col_green, tostring(k):upper() .. ': ', col_white, v)
		else
			MsgC(col_red, tostring(k):upper() .. ': ', col_white, v)
		end
	end
end
