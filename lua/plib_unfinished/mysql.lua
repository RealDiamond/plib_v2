require 'tmysql'

mysql = setmetatable({}, {
	__call = function(self, ...)
		return self.Connect(...)
	end,
	GetTable = setmetatable({}, {
		__call = function(self)
			return self
		end
	})
})

local database = setmetatable({}, {
	__tostring = function(self)
		return self.Database .. '@' .. self.IP .. ':' ..  self.Port
	end
})
database.__concat 	= database.__tostring
database.__index 	= database
_R.database 		= database


local tostring 		= tostring
local SysTime 		= SysTime

local color_purple 	= Color(185,0,255)
local color_white 	= Color(250,250,250)

PrintTable(tmysql)
PrintTable(FindMetaTable('Database'))

function mysql.Connect(hostname, username, password, database, port, optional_socketpath, optional_clientflags)
	local db_obj = setmetatable({
		Handle 	 = tmysql.Create(hostname, username, password, database, port, optional_socketpath, optional_clientflags),
		Hostname = hostname,
		Username = username,
		Password = password,
		Database = database,
		Port 	 = port,
	}, database)

	mysql.GetTable[tostring(db_obj)] = db_obj

	self:SetOption(MYSQL_SET_CLIENT_IP, GetConVarString('ip'))
	self:Connect()

	return db_obj
end


function database:Connect()
	self.Status, self.Error = self.Handle:Connect()
	if self.Error then
		self:Log(self.Error)
	end
	return self.Error
end

function database:Disconnect()
	self.Status = false
	self.Handle:Disconnect()
end

function database:IsConnected()
	return self.Status
end

function database:Poll()
	self.Handle:Poll()
end

function database:Escape(value)
	return self.Handle:Escape(tostring(value))
end

function database:Log(message)
	MsgC(color_purple, '[MySQL ' .. self .. ']', color_white, tostring(message))
end


function database:Query(query, ...)
	local args = {...}
	local count = 0
	query = query:gsub('?', function()
		count = count + 1
		return '"' .. self:Escape(args[count]) .. '"'
	end)
	self.Handle:Query(query, function(results)

		--args[count]

		
	end)
end

function database:QuerySync(query, ...)
	local data
	local done 	= false
	local start = SysTime() + 0.3
	self:Query(query, ..., function(_data)
		data = _data
	end)
	while (not done) and (start >= SysTime()) do
		self:Poll()
	end
	return data
end


function database:SetCharacterSet(charset)
	self.Handle:SetCharacterSet(charset)
end

function database:SetOption(opt, value)
	self.Handle:SetOption(opt, value)
end


function database:GetServerInfo()
	return self.Handle:GetServerInfo()
end

function database:GetHostInfo()
	return self.Handle:GetHostInfo()
end

function database:GetServerVersion()
	return self.Handle:GetServerVersion()
end