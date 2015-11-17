local pairs = pairs

function table.Add(...)
	local ret = {}
	for _, tbl in pairs(...) do
		for _, v in pairs(tbl) do
			ret[#ret + 1] = v
		end
	end
	return ret
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
	for i = 1, #tab do
		if func(tab[i]) then
			ret[#ret + 1] = tab[i]
		end
	end
	return ret
end
