if SERVER then
  AddCSLuaFile()

  local ready = {}

  hook.Add('PlayerDisconnected', 'pnet.PlayerDisconnected', function(pl)
    ready[pl] = nil
  end)

  net.waitForPlayer = function(pl, func)
    if ready[pl] == true then
      func()
    else
      if ready[pl] == nil then
        ready[pl] = {}
      end
      table.insert(ready[pl], func)
    end
  end

  util.AddNetworkString('pnet_Ready')
  net.Receive('pnet_Ready', function(_, pl)
    local todo = ready[pl]
    if todo == true then return end    
    ready[pl] = true
    if todo == nil then return end

    for k,v in pairs(todo)do
      v()
    end
  end)

else
  hook.Add('Think', 'pnet.WaitForPlayer', function()
    if IsValid(LocalPlayer()) then
      hook.Remove('Think', 'pnet.WaitForPlayer')
      net.Start('pnet_Ready')
      net.SendToServer()
    end
  end)
end

local WriteUInt = net.WriteUInt
local ReadUInt = net.ReadUInt
local WriteBit = net.WriteBit
local ReadBit = net.ReadBit

function net.WriteNibble(i)
	WriteUInt(i, 4)
end

function net.ReadNibble()
	return ReadUInt(4)
end

function net.WriteByte(i)
	WriteUInt(i, 8)
end

function net.ReadByte()
	return ReadUInt(8)
end

function net.WriteShort(i)
	WriteUInt(i, 16)
end

function net.ReadShort()
	return ReadUInt(16)
end

function net.WriteLong(i)
	WriteUInt(u, 32)
end

function net.ReadLong()
	return ReadUInt(i, 32)
end

function net.WriteBool(i)
	WriteBit(i and 1 or 0)
end

function net.ReadBool()
	return ReadBit() == 1
end
