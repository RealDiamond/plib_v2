p = {}

p.print = function(msg)
	return MsgC(Color(175,0,255), '[pLib] ', Color(250,250,250), tostring(msg) .. '\n')
end

p.include_sv = (SERVER) and include or function() end
p.include_cl = (SERVER) and AddCSLuaFile or include
p.include_sh = function(p) p.include_sv(p) p.include_cl(p) end


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

p.print 'Loaded!'