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