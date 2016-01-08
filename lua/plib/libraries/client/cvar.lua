require 'pon1'

cvar = setmetatable({}, {
	__call = function(self, ...)
		return self.Register(...)
	end
})
cvar.GetTable = setmetatable({}, {
	__call = function(self)
		return self
	end
})

local cvar_mt 	= {}
cvar_mt.__index = cvar_mt

local function encode(data)
	return util.Compress(pon1.encode(data))
end

local function decode(data)
	return pon1.dencode(util.Decompress(data))
end

local function load()
	if (not file.IsDir('cvar', 'DATA')) then
		file.CreateDir('cvar')
	else
		local files, _ = file.Find('*.dat', 'cvar', 'DATA')
		for k, v in ipairs(files) do
			local c = setmetatable({decode(file.Read('cvar/' .. v, 'DATA'))}, cvar_mt)
			cvar.GetTable[c.Name] = c
		end
	end
end

function cvar_mt:SetValue(value)
	hook.Call('cvar.' ..  self.Name, nil, self.Value, value)
	self.Value = value
	file.Write('cvar/' .. self.ID .. '.dat', encode(self))
	return self
end

function cvar_mt:SetDefault(value)
	if (not self.Value) then
		self.Value = value
	end
	return self
end

function cvar_mt:AddMetadata(key, value)
	self.Metadata[key] = value
	return self
end

function cvar_mt:AddCallback(callback)
	hook.Add('cvar.' .. self.Name, callback)
	return self
end

function cvar_mt:GetName()
	return self.Name
end

function cvar_mt:GetValue()
	return self.Value
end

function cvar_mt:GetMetadata(key)
	return self.Metadata[key]
end

function cvar.Register(name)
	if (not cvar.GetTable[name]) then
		cvar.GetTable[name] = setmetatable({
			Name = name,
			ID 	= util.CRC(name),
			Metadata = {}
		}, cvar_mt)
	end
	return cvar.GetTable[name]
end

function cvar.Get(name)
	if (not cvar.GetTable[name]) then
		cvar.Register(name)
	end
	return cvar.GetTable[name]
end

function cvar.SetValue(name, value)
	cvar.Get(name):SetValue(value)
end

function cvar.GetValue(name)
	return (cvar.GetTable[name] ~= nil) and cvar.GetTable[name].Value
end

load()