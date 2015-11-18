cmd = setmetatable({}, {
	__call = function(self, ...)
		return self.Add(...)
	end,
	GetTable = setmetatable({}, {
		__call = function(self)
			return self
		end
	})
})

local cmd_mt = {
	__tostring = function(self)
		return self.Name
	end
}
cmd_mt.__index 	= cmd_mt
cmd_mt.__concat = cmd_mt.__tostring
_R.cmd 			= cmd_mt


function cmd.Add(name, callback)
	local c = setmetatable({
		Name  		= name:lower():gsub(' ', ''),
		NiceName 	= name,
		Params		= {},
		Callback	= callback or function() end
	}, cmd_mt)
	cmd.GetTable[c.Name] = c
	return c
end

function cmd.Get(name)
	return cmd.GetTable[name]
end

function cmd.Remove(name)
	cmd.GetTable[name] = nil
end

function cmd.Run(pl, name, ...)
	if (not hook.Run('cmd.CanRunCommand', pl, cmd, msg, ...)) then return end

	-- Parse shit here. maybe a whole new lib for that??

	local cmd = cmd.Get(name)
	local succ, msg = cmd.Callback(...)
	if (not succ) and msg then
		hook.Run('cmd.OnCommandError', pl, cmd, msg, ...)
	elseif (succ) and msg then
		hook.Run('cmd.OnCommandRun', pl, cmd, msg, ...)
	end
	return succ, msg
end


-- Set
function cmd_mt:SetConCommand(name)

end

function cmd_mt:AddParam(key, type, opts)

end

function cmd_mt:RunOnClient(callback)

end

-- Get
function cmd_mt:GetName()

end

function cmd_mt:GetNiceName()

end

function cmd_mt:GetConCommand()

end