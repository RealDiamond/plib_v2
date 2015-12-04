--[[
LICENSE:
_p_modules\lua\includes\modules\xfn.luasrc

Copyright 08/24/2014 thelastpenguin
]]
xfn = {};
local xfn = xfn;
local pairs , ipairs , unpack = pairs , ipairs , unpack ;

-- composes functions
function xfn.compose(a, b, ...)
	if not b then return a end
	b = xfn.compose(b, ...)
	return function(...)
		return b(a(...))
	end
end

-- returns the arguments
function xfn.returnArgs(fn)
	return function(...)
		fn(...)
		return ...
	end
end

-- call all the functions with the same arguments
function xfn.parallel(...)
	-- its almost beautiful.
	xfn.compose(xfn.mapStack(xfn.returnArgs, ...))
end

function xfn.filter(tab, func)
	local c = 1
	for i = 1, #tab do
		if func(tab[i]) then
			tab[c] = tab[i]
			c = c + 1
		end
	end
	for i = c, #tab do
		tab[i] = nil
	end
	return tab
end

function xfn.filterStack(...)
  local helper = function(a, ...)
    if fn(a) then
      return a, helper(...)
    else
      return helper(...)
    end
  end
  return helper(...)
end

function xfn.map( tbl, func )
	for k,v in pairs( tbl )do
		tbl[k] = func( v, k );
	end
	return tbl;
end

local function mapStack(fn, a, ...)
	return fn(a), mapStack(fn, ...)
end
xfn.mapStack = mapStack


-- does nothing
function xfn.nothing() end
xfn.noop = xfn.nothing;

-- takes no inputs
function xfn.fn_deafen( func )
	return function() func() end
end
xfn.deafen = xfn.fn_deafen

-- gives no outputs
function xfn.neuter( func )
	return function(...)
		func(...)
	end
end

-- stack manipulation to the higest degree
function xfn.storeArgs(...)
	local function storeArgs(i, a, ...)
		if i == 0 then return end

		local next = storeArgs(i - 1, ...)
		if next then
			return function(after)
				return a, next(after)
			end
		else
			return function(after)
				if after then
					return a, after()
				end
				return a
			end
		end
	end

	local c = select('#', ...)
	if c == 0 then return function() end end

	return storeArgs(c, ...)
end

function xfn.bind(func, ...)
	local _1 = xfn.storeArgs(...)
	return function(...)
		local _2 = xfn.storeArgs(...)
		return func(_1(_2))
	end
end
