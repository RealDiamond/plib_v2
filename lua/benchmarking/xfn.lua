local function xfn_filter(tab, func)
	local c = 0
	for k, v in ipairs(tab) do
		if func(v) then
			tab[c + 1] = v
			c = c + 1
		end
		tab[k] = nil
	end
	return tab
end

local function xfn_filter3(tab, func)
	local c = 0
	for i = 1, #tab do
		local v = tab[i]
		if func(v) then
			tab[c + 1] = v
			c = c + 1
		end
		tab[i] = nil
	end
	return tab
end

require 'xfn'

local xfn_filter2 = xfn.filter


require 'pbench'
	
for i = 1, 5 do

	local function genData()

		local data = {}
		for k = 1, math.pow(10, i) do
			table.insert(data, k % 2)
		end

		return data
	end

	local data = genData()

	print('data set size: ' .. #data)

	pbench.push()

	for i = 1, 1000 do
		xfn_filter(data, function(el) return el == 1 end)
	end
		
	print('\tstoneds shit: ' .. pbench.pop())
	print('\tdata size: ' .. #data)

	local data = genData()

	pbench.push()

	for i = 1, 1000 do
		xfn_filter2(data, function(el) return el == 1 end)
	end

	print('\tmy shit: ' .. pbench.pop())
	print('\tdata size: ' .. #data)


	local data = genData()

	pbench.push()

	for i = 1, 1000 do
		xfn_filter3(data, function(el) return el == 1 end)
	end

	print('\tstoneds shit modified: ' .. pbench.pop())
	print('\tdata size: ' .. #data)

end
