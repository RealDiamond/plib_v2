--
-- load pLib and its dependancies's first
--
include('util.lua')
include('extensions/file.lua')

include('plib.lua')
if (SERVER) then AddCSLuaFile('includes/plib.lua') end

local require_blacklist = {}
local loaded_modules 	= {}
local files, _ = file.Find('includes/modules/*.lua', 'LUA')
for _, f in ipairs(files) do
	if (SERVER) then
		AddCSLuaFile('includes/modules/' .. f)
	end
end

local files, _ = file.Find('includes/libraries/*.lua', 'LUA')
for _, f in ipairs(files) do
	if (SERVER) then
		AddCSLuaFile('includes/libraries/' .. f)
	end
	require_blacklist[f:sub(1, f:match('.+()%.%w+$') - 1)] = true
end

local old_require = require
function require(name)
	if require_blacklist[name] and not loaded_modules[name] then
		loaded_modules[name] = true
		p.print('Overwriting "' .. name .. '" with custom library.')
		--return include('../includes/libraries/' .. name .. '.lua') -- you still need to manually include them for now.
	end
	return old_require(name)
end

include('../includes/libraries/hook.lua')

--
-- Load the garrycode
--
local garrycode = file.Read('lua/includes/init.lua', 'GAME')
RunString(garrycode)
