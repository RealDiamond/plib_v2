--[[
LICENSE:
_p_modules\lua\includes\modules\xfn.luasrc

Copyright 08/24/2014 thelastpenguin
]]
xfn = {};
local xfn = xfn;
local pairs , ipairs , unpack = pairs , ipairs , unpack ;

function xfn.filter(tab, func)
	local c = 0
	for i = 1, #tab do
		if func(v) then
			c = c + 1
			tab[c] = v
		else
			tab[i] = nil
		end
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

function xfn.unique( tbl )
	local cache = {};
	return xfn.filter(tbl, function(el)
		if cache[el] then
			return false;
		else
			cache[el] = true;
			return true;
		end
	end);
end

function xfn.forEach( tbl, func )
	for k,v in pairs( tbl )do
		func( v, k );
	end
end

function xfn.map( tbl, func )
	for k,v in pairs( tbl )do
		tbl[k] = func( v, k );
	end
	return tbl;
end

function xfn.nothing() end
xfn.noop = xfn.nothing;

function xfn.fn_forEach( func )
	return function( tbl )
		for k,v in pairs(tbl)do
			func( v, k );
		end
	end
end

function xfn.fn_deafen( func )
	return function() func() end
end

xfn.table = {}
function xfn.table.inherit(parent, new) 
	setmetatable({}, {
		__index = parent
	})
end

function xfn.table.inheritCopy(parent, new) 
	for k,v in pairs(parent)do
		if not new[k] then
			new[k] = v
		end
	end
end

function xfn.table.indexOf(tbl, value)
	for k,v in pairs(tbl)do
		if v == value then
			return k
		end
	end
end

function xfn.fn_const(val)
	return function()
		return val
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
