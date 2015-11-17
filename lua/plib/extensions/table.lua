local pairs 	= pairs
local ipairs 	= ipairs

function table.Add( ... )
	local final = {}
	
	for _, tbl in pairs( ... ) do
		for _, v in pairs( tbl ) do
			table.insert( final, v )
		end
	end
	
	return final
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
