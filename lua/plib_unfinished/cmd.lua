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
end

function cmd.Get(name)

end

function cmd.Remove(name)

end


function cmd_mt:AddParam(key, type, opts)

end

function cmd_mt:RunOnClient(callback)

end