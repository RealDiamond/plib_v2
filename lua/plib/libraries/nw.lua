nw 				= {}

local vars 		= {}
local mappings 	= {}
local data 		= {
	[0] = {}
}
local globals 	= data[0]
local callbacks = {}

local nw_mt 	= {}
nw_mt.__index 	= nw_mt

local bitmap = {
	[3]		= 3,
	[7] 	= 4,
	[15] 	= 5,
	[31] 	= 6,
	[63] 	= 7,
	[127] 	= 8
}

local bitcount 	= 2

local ENTITY 	= FindMetaTable('Entity')

local net 		= net
local pairs 	= pairs
local ipairs 	= ipairs
local Entity 	= Entity

function nw.Register(var, info) -- You must always call this on both the client and server. It will serioulsy break shit if you don't.
	local t = {
		Name = var,
		NetworkString = 'nw_' .. var,
		_Write = function(self, ent, value)
			net.WriteUInt(ent:EntIndex(), 12)
			net.WriteType(value)
		end,
		_Read = function(self)
			return net.ReadUInt(12), net.ReadType()
		end,
		SendFunc = net.Broadcast,
	}
	setmetatable(t, nw_mt)
	vars[var] = t

	if (SERVER) then
		util.AddNetworkString(t.NetworkString)
	else
		net.Receive(t.NetworkString, function()
			local index, value = t:_Read()
				
			if (not data[index]) then
				data[index] = {}
			end
			data[index][var] = value
		end)
	end

	if (info ~= nil) then -- info arg is only for backwards support, plz dont use
		if info.Read then t:Read(info.Read) end
		if info.Write then t:Write(info.Write) end
		if info.LocalVar then t:SetLocal() end
		if info.GlobalVar then t:SetGlobal() end
		if info.Filter then t:Filter(info.Filter) end
	end

	return t:_Construct()
end

function nw_mt:Write(func, opt)
	self.WriteFunc = function(value)
		func(value, opt)
	end
	return self:_Construct()
end

function nw_mt:Read(func, opt)
	self.ReadFunc = function()
		return func(opt)
	end
	return self:_Construct()
end

function nw_mt:Filter(func)
	self.SendFunc = function(self, ent, value, recipients)
		net.Send(recipients or func(ent, value))
	end
	return self:_Construct()
end

function nw_mt:SetLocal()
	self.LocalVar = true
	return self:_Construct()
end

function nw_mt:SetGlobal()
	self.GlobalVar = true
	return self:_Construct()
end

function nw_mt:_Send(ent, value, recipients)
	net.Start(self.NetworkString)
		self:_Write(ent, value)
	self:SendFunc(ent, value, recipients)
end

function nw_mt:_Construct()
	local WriteFunc = self.WriteFunc
	local ReadFunc 	= self.ReadFunc

	if self.LocalVar then
		local Send = net.Send

		self._Write = function(self, ent, value)
			WriteFunc(value)
		end
		self._Read = function(self)
			return LocalPlayer():EntIndex(), ReadFunc()
		end
		self.SendFunc = function(self, ent, value, recipients)
			Send(ent)
		end
	elseif self.GlobalVar then
		self._Write = function(self, ent, value)
			WriteFunc(value)
		end
		self._Read = function(self)
			return 0, ReadFunc()
		end
	end

	mappings = {}
	for k, v in SortedPairsByMemberValue(vars, 'Name', false) do
		local c = #mappings + 1
		vars[k].ID = c
		mappings[c] = v
		if bitmap[c] then
			bitcount = bitmap[c]
		end
	end

	return self
end

function nw.GetGlobal(var)
	return globals[var]
end

function ENTITY:GetNetVar(var)
	local index = self:EntIndex()
	return data[index] and data[index][var]
end

if (SERVER) then
	util.AddNetworkString('nw.PlayerSync')
	util.AddNetworkString('nw.NullVar')
	util.AddNetworkString('nw.EntityRemoved')

	net.Receive('nw.PlayerSync', function(len, pl)
		if (pl.EntityCreated ~= true) then
			hook.Call('PlayerEntityCreated', GAMEMODE, pl)

			pl.EntityCreated = true

			for index, _vars in pairs(data) do
				for var, value in pairs(_vars) do
					local ent = Entity(index)
					if (not vars[var].LocalVar) or (ent == pl) then
						vars[var]:_Send(ent, value, pl)
					end
				end
			end

			if (callbacks[pl] ~= nil) then
				for k, v in ipairs(callbacks[pl]) do
					v(pl)
				end
			end
			callbacks[pl] = nil
		end
	end)

	hook.Add('EntityRemoved', 'nw.EntityRemoved', function(ent)
		local index = ent:EntIndex()
		if (index ~= 0) and (data[index] ~= nil) then -- For some reason this kept getting called on Entity(0), not sure why...
			net.Start('nw.EntityRemoved')
				net.WriteUInt(index, 12)
			net.Broadcast()
			data[index] = nil
		end
	end)

	function nw.WaitForPlayer(pl, cback)
		if (pl.EntityCreated == true) then
			cback(pl)
		else
			if (callbacks[pl] == nil) then
				callbacks[pl] = {}
			end
			callbacks[pl][#callbacks[pl] + 1] = cback
		end
	end

	function nw.SetGlobal(var, value)
		globals[var] = value
		if (value ~= nil) then
			vars[var]:_Send(0, value)
		else
			net.Start('nw.NullVar')
				net.WriteUInt(0, 12)
				net.WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(0, value)
		end
	end

	function ENTITY:SetNetVar(var, value)
		local index = self:EntIndex()

		if (not data[index]) then
			data[index] = {}
		end

		data[index][var] = value
		
		if (value ~= nil) then
			vars[var]:_Send(self, value)
		else
			net.Start('nw.NullVar')
				net.WriteUInt(index, 12)
				net.WriteUInt(vars[var].ID, bitcount)
			vars[var]:SendFunc(self, value)
		end
	end
else
	hook.Add('InitPostEntity', 'nw.InitPostEntity', function()
		net.Start('nw.PlayerSync')
		net.SendToServer()
	end)

	net.Receive('nw.NullVar', function()
		data[net.ReadUInt(12)][mappings[net.ReadUInt(bitcount)].Name] = nil
	end)
	
	net.Receive('nw.EntityRemoved', function()
		data[net.ReadUInt(12)] = nil
	end)
end