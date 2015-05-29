require('pon') -- todo, maybe make this use sqlite someday

local file 			= file
local hook 			= hook
local pon 			= pon

cvar 				= {}
local cvar_file 	= 'plib_cvars.txt'
local stored_vars 	= pcall(pon.decode, file.Read(cvar_file, 'DATA')) or {}


local function SaveCVars()
	file.Write(cvar_file, pon.encode(stored_vars))
end

function cvar.Create(name, default_value, callback) -- This is optional
	stored_vars[name] = stored_vars[name] or default_value
	if callback then
		cvar.AddCallback(name, callback)
	end
end

function cvar.AddCallback(name, callback)
	return hook.Add('cvar.' .. name, callback)
end

function cvar.Set(name, value)
	stored_vars[name] = value
	hook.Call('cvar.' ..  name, nil, value)
	SaveCVars()
end

function cvar.Get(name)
	return stored_vars[name]
end