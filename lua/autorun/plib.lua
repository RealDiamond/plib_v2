-- AddCSLua modules
local files, _ = file.Find('includes/modules/*.lua', 'LUA')
for _, f in ipairs(files) do
	if (SERVER) then
		AddCSLuaFile('includes/modules/' .. f)
	end
end

-- Load p-utils
require('plib')