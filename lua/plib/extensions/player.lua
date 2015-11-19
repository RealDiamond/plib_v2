function player.FindByInfo(info)
	info = tostring(info)
	for _, pl in ipairs(player.GetAll()) do
		if (info == pl:SteamID()) then
			return pl
		elseif (info == pl:SteamID64()) then
			return pl
		elseif string.find(string.lower(pl:Name()), string.lower(info), 1, true) ~= nil then
			return pl
		end
	end
end

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