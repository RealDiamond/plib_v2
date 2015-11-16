local pairs 	= pairs
local ipairs 	= ipairs

function table.Stack( ... ) --- ???
	local final = {}
	
	for _, tbl in pairs( ... ) do
		table.Add( final, tbl )
	end
end

function table.Filter(tab, func)
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

function table.FilterCopy(tab, func)
	local ret = {}
	for k, v in ipairs(tab) do
		if func(v) then
			ret[#ret + 1] = v
		end
	end
	return ret
end