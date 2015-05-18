nw 				= nw 			or {}
nw.Stored 		= nw.Stored 	or {}
nw.VarInfo		= nw.VarInfo 	or {}
nw.Callbacks 	= nw.Callbacks 	or {}

local nw 		= nw
local net 		= net
local pairs 	= pairs
local Entity 	= Entity
local player 	= player

local ENTITY 	= FindMetaTable('Entity')

local ReadType
if (SERVER) then
	util.AddNetworkString('nw.var')
	util.AddNetworkString('nw.clear')
	util.AddNetworkString('nw.delete')
	util.AddNetworkString('nw.ping')

	local function SendVar(ent, var, value, filter)
		if (nw.VarInfo[var] ~= nil) and (nw.VarInfo[var].Write ~= nil) then
			nw.VarInfo[var].Write(ent, value, filter)
		else
			local index = ent:EntIndex()
			
			net.Start('nw.var')
				net.WriteUInt(index, 16)
				net.WriteString(var)
				net.WriteType(value)
			net.Broadcast()

			MsgC(Color(255,0,0), 'UNREGISTERED NW VAR: ' .. var)
		end
	end

	function ENTITY:SetNetVar(var, value)
		local index = self:EntIndex()
		
		if (nw.Stored[index] == nil) then
			nw.Stored[index] = {}
		end

		nw.Stored[index][var] = value

		SendVar(self, var, value)
	end

	net.Receive('nw.ping', function(len, pl)
		if (pl.EntityCreated ~= true) then
			hook.Call('PlayerEntityCreated', GAMEMODE, pl)

			pl.EntityCreated = true

			for index, vars in pairs(nw.Stored) do
				local ent = Entity(index)
				for var, value in pairs(vars) do
					if not nw.VarInfo[var] or not nw.VarInfo[var].LocalVar then
						SendVar(Entity(index), var, value, pl)
					end
				end
			end

			if (nw.Callbacks[pl] ~= nil) then
				for k, v in ipairs(nw.Callbacks[pl]) do
					v(pl)
				end
			end
			nw.Callbacks[pl] = nil
		end
	end)

	function nw.WaitForPlayer(pl, callback)
		if (pl.EntityCreated == true) then
			callback(pl)
		else
			if (nw.Callbacks[pl] == nil) then
				nw.Callbacks[pl] = {}
			end
			nw.Callbacks[pl][#nw.Callbacks[pl] + 1] = callback
		end
	end

	function nw.SetGlobal(var, value)
		game.GetWorld():SetNetVar(var, value)
	end

	hook.Add('EntityRemoved', 'nw.EntityRemoved', function(ent)
		local index = ent:EntIndex()
		if (nw.Stored[index] ~= nil) then
			net.Start('nw.clear')
				net.WriteUInt(index, 12)
			net.Broadcast()
			nw.Stored[index] = nil
		end
	end)
else
	function ReadType()
		local t = net.ReadUInt(8)
		return net.ReadType(t)
	end

	net.Receive('nw.var', function()
		local index = net.ReadUInt(12)
		local var 	= net.ReadString()
		local value = ReadType()

		if (nw.Stored[index] == nil) then
			nw.Stored[index] = {}
		end

		nw.Stored[index][var] = value
	end)

	net.Receive('nw.clear', function()
		nw.Stored[net.ReadUInt(12)] = nil
	end)

	net.Receive('nw.delete', function()
		local index = net.ReadUInt(12)
		if (nw.Stored[index] ~= nil) then
			nw.Stored[index][net.ReadString()] = nil
		end
	end)

	hook.Add('InitPostEntity', 'nw.InitPostEntity', function()
		net.Start('nw.ping')
		net.SendToServer()
	end)
end

function ENTITY:GetNetVar(var)
	local index = self:EntIndex()
	if (nw.Stored[index] ~= nil) then
		return nw.Stored[index][var]
	end
end

function nw.GetGlobal(var)
	return game.GetWorld():GetNetVar(var)
end

function nw.Register(var, info) -- always call this shared
	info = info or {}
	if (SERVER) then
		util.AddNetworkString('nw_' ..  var)
	else
		local ReadFunc = (info.Read or ReadType)

		net.Receive('nw_' ..  var, function(l)
			local value = ReadFunc()
			local index = info.LocalVar and LocalPlayer():EntIndex() or net.ReadUInt(12)

			if (nw.Stored[index] == nil) then
				nw.Stored[index] = {}
			end

			nw.Stored[index][var] = value
		end)
	end

	local WriteFunc = (info.Write or net.WriteType)
	local FilterFunc = (info.Filter or player.GetAll)

	nw.VarInfo[var] = {
		Write = function(ent, value, filter)
			local index = ent:EntIndex()

			if (value == nil) then
				net.Start('nw.delete')
					net.WriteUInt(index, 12)
					net.WriteString(var)
				net.Send(filter or FilterFunc(ent, var, value))
			else
				net.Start('nw_' ..  var)
				WriteFunc(value)
				if info.LocalVar then
					net.Send(ent)
				else
					net.WriteUInt(index, 12)
					net.Send(filter or FilterFunc(ent, var, value))
				end
			end
		end,
		LocalVar = info.LocalVar
	}
end