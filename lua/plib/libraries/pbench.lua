require 'dprint'

pbench = {}

local time = os.clock 

do
	local stack = {}
	function pbench.push()
		stack[#stack+1] = time()
	end

	function pbench.pop()
		local ret = stack[#stack]
		stack[#stack] = nil
		return time() - ret
	end
end

function pbench.toPerSecond(time)
	return math.floor(1 / time)
end


do
	local bmark_mt = {}
	bmark_mt.__index = bmark_mt 

	function bmark_mt:startLap()
		self._began = time()
	end
	function bmark_mt:endLap()
		table.insert(self, time() - self._began)
	end
	function bmark_mt:totalTime()
		local t = 0
		for k,v in ipairs(self)do
			t = t + v
		end
		return t
	end
	bmark_mt.__tostring = function(self)
		return self:totalTime() .. ' seconds'
	end
	function bmark_mt:lapAvg()
		return self:totalTime() / #self
	end

	function pbench.new()
		return setmetatable({}, bmark_mt)
	end
end