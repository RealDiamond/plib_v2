if SERVER then
	local blacklist = {
		-- Ex: pdraw.lua = true, // No extension needed
	}

	local files, _ = file.Find('includes/modules' .. '/*.lua', 'LUA')
	for _, f in ipairs(files) do
		if (blacklist[f] ~= false) then
			AddCSLuaFile('includes/modules/' .. f)
		end
	end
end

require 'phooks'
require 'putil'

p.print 'Loaded!'