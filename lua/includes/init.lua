--
-- Load pLib and its dependancies's first
--

if (SERVER) then 
	AddCSLuaFile()
	AddCSLuaFile('includes/plib.lua')
	AddCSLuaFile('garry_init.lua')
end
include('util.lua')
include('extensions/file.lua')
include('plib.lua')

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

function require(name)
	if loaded_modules[name] then return end -- You're an ass hole if you do this
	loaded_modules[name] = true
	if require_blacklist[name] then
		p.print('Overwriting "' .. name .. '" with custom library.')
		include('libraries/' .. name .. '.lua')
		return
	end
	return p.require(name)
end


--
-- Load the garrycode
--
include('garry_init.lua')