require 'pbench'

pbench.push()

local foo = {}
for i = 1, 1000 do
	table.insert(foo, 100)
end
for i = 1, 1000 do
	string.char(unpack(foo))
end
print('took ' .. pbench.pop() .. ' seconds')


pbench.push()
local foo2 = {}
for i = 1, 1000 do
	table.insert(foo2, 'd')
end
for i = 1, 1000 do
	table.concat(foo2)
end
print('took ' .. pbench.pop() .. ' seconds')
