local PLAYER = FindMetaTable('Player')

function PLAYER:Timer(name, time, reps, callback)
	timer.Create(self:SteamID64() .. '-' .. name, time, reps, function()
		if IsValid(self) then
			callback(self)
		else
			self:DestroyTimer(name)
		end
	end)
end

function PLAYER:DestroyTimer(name)
	timer.Destroy(self:SteamID64() .. '-' .. name)
end