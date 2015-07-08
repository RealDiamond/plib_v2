plib 			= {}

plib.IncludeSV 	= (SERVER) and include or function() end
plib.IncludeCL 	= (SERVER) and AddCSLuaFile or include
plib.IncludeSH 	= function(f) plib.IncludeSV(f) plib.IncludeCL(f) end

local color_white 	= Color(225,225,225)
local color_red 	= Color(225,5,5)

function plib.Error(msg)
	Msg('\n\n')
	MsgC(color_red, '[ERROR]: ', color_white, msg .. '\n')
	local level = 1
	while (true) do
		local info = debug.getinfo(level, 'Sln')
		if (info == nil) then break end
		if (info.what == 'C') then
			MsgC(color_red,'       [' .. level .. ']     ', color_white, '[C] function\n')
		else
			MsgC(color_red,'       [' .. level .. ']     ', color_white, 'Line: ' .. info.currentline .. '     ' .. (info.name or 'Unknown') .. '     ' .. info.short_src .. '\n')
		end
		level = level + 1
	end
	Msg('\n\n')
end

-- Module loader
local function LoadDir(dir)
	local ret = {}
	local files, folders = file.Find('plib/' .. dir .. '/*', 'LUA')
	for _, f in ipairs(files) do
		ret[f:sub(1, f:len() - 4)] = 'plib/' .. dir .. '/' .. f
	end
	for _, f in ipairs(folders) do
		ret[f] = 'plib/' .. dir  .. '/' .. f .. '/' .. f ..'.lua'
	end
	return ret
end

local Modules = LoadDir('libraries')
if (SERVER) then
	for k, v in pairs(Modules) do
		AddCSLuaFile(v)
	end
end
for k, v in pairs(LoadDir('extensions')) do
	plib.IncludeSH(v)
end

function plib.Require(name)
	if Modules[name] then
		include(Modules[name])
	else
		plib.Error('Module "' .. name .. '" not found!')
	end
end

local _require = require
function require(name)
	if Modules[name] then
		plib.IncludeSH(Modules[name])
	else
		return _require(name)
	end
end