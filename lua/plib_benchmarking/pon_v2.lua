pon2_dev = {}

local string_char = string.char
local string_byte = string.byte
local string_sub = string.sub
local string_find = string.find
local tonumber = tonumber
local tostring = tostring
local string_format = string.format
local string_len = string.len
local type = type
local pairs = pairs
local table_concat = table.concat
local next = next

local Entity = Entity
local Vector = Vector
local Angle = Angle



local key_types = {
	['ptr'] 		= 0,
	['incr'] 		= 1,
	['string'] 	= 2,
	['number'] 	= 3,
	['table'] 	= 4,
	
	['Entity'] 	= 5,
	['Player'] 	= 5,
	['Vehicle'] = 5,
	['Weapon'] 	= 5,
	['NPC'] 		= 5,
	['NextBot'] = 5,

	['Vector'] 	= 6,
	['Angle'] 	= 7
}

local val_types = {
	['ptr'] 		= 0,
	['string'] 	= 1,
	['number'] 	= 2,
	['float'] 	= 3,
	['table'] 	= 4,

	['Entity'] 	= 5,
	['Player'] 	= 5,
	['Vehicle'] = 5,
	['Weapon'] 	= 5,
	['NPC'] 		= 5,
	['NextBot'] = 5,

	['Vector'] = 6,
	['Angle'] = 7
}

local seperator = string_char(32) -- TODO: simply replace this into the code everywhere it's used

local type_pair_to_id = {}
local id_to_key_type = {}
local id_to_val_type = {}
for ktype, kid in pairs(key_types)do
	local tbl = {} type_pair_to_id[ktype] = tbl
	for vtype, vid in pairs(val_types)do
		local pair_id = string_char(kid*8+vid+33)
		tbl[vtype] = pair_id
		id_to_key_type[pair_id] = ktype
		id_to_val_type[pair_id] = vtype
	end
end

local type_pair_to_id_incr = type_pair_to_id['incr']

local num_to_char = {}
local char_to_num = {}
local char = string.char
for i = 0, 94 do
	num_to_char[i] = string_char(32+i)
	char_to_num[string_char(32+i)] = i
end

local encoders = {}
local decoders = {}

-- local variables + closures are faster
local output = {}
local cache = {}
local output_len = 1
local cache_size = 0

-- local variables + closures for decoding
local index = 1
local str = nil
local strlen = 0

encoders['table'] = function(val, output_len, output)
	cache[val] = cache_size
	cache_size = cache_size + 1

	
	for k,v in ipairs(val) do
		local tk, tv
		if cache[v] then
			tv = 'ptr'
		else
			tv = type(v)
		end

		output[output_len] = type_pair_to_id_incr[tv]
		--output_len = output_len + 1 -- moved to call below rather than pay assignment overhead

		output_len = encoders[tv](v, output_len + 1, output)
	end
	
	--[[for i = 1, arrLen do
		local tk, tv
		local v
		v = val[i]
		if cache[v] then
			tv = 'ptr'
		else
			tv = type(v)
		end

		output[output_len] = type_pair_to_id_incr[tv]
		output_len = output_len + 1

		encoders[tv](v)
	end]]

	local arrLen = #val

	for k,v in next , val , (arrLen ~= 0 and arrLen or nil) do
		local tk, tv
		if cache[v] then
			tv = 'ptr'
		else
			tv = type(v)
		end
		
		if cache[k] then
			tk = 'ptr'
		else
			tk = type(k)
		end

		output[output_len] = type_pair_to_id[tk][tv]

		-- output_len = output_len + 1 -- moved into the call below, saves a variable assignment
		output_len = encoders[tv](v, 
				encoders[tk](k, output_len + 1, output), 
				output)
	end

	output[output_len] = seperator
	return output_len + 1
end

decoders['table'] = function()
	local obj = {}

	cache[cache_size] = obj
	cache_size = cache_size + 1

	local arrayKey = 1
	
	local key, typeChar
	local ktype, vtype
	while(index < strlen)do
		typeChar = string_sub(str, index, index)
		index = index + 1

		if typeChar == seperator then
			break
		end

		ktype = id_to_key_type[typeChar]
		vtype = id_to_val_type[typeChar]

		if ktype == 'incr' then
			key = arrayKey
			arrayKey = arrayKey + 1
		else
			key = decoders[ktype]()
		end

		local value = decoders[vtype]()

		obj[key] = value
	end

	return obj
end

encoders['ptr'] = function(val, output_len, output)
	local val = cache[val]
	while(val >= 47)do
		output[output_len] = num_to_char[47+val%47]
		output_len = output_len + 1
		val = val/47
		val = val - val%1
	end
	output[output_len] = num_to_char[val%47]
	return output_len + 1
end

decoders['ptr'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end

	return cache[num]
end

encoders['number'] = function(val, output_len, output)
	
	if val % 1 == 0 then
		if val < 0 then
			output[output_len] = string_format('I%x;', -val)
		else
			output[output_len] = string_format('i%x;', val)
		end
	else
		if val < 0 then
			output[output_len] = 'F'..-val..';'
		else
			output[output_len] = 'f'..val..';'
		end
	end

	return output_len + 1
end

decoders['number'] = function()
	local mode = string_sub(str, index, index)
	local _end = string_find(str, ';', index+1, true)
	local number = string_sub(str, index+1, _end-1)
	index = _end+1

	if mode == 'i' then
		return tonumber(number, 16)
	elseif mode == 'I' then
		return -tonumber(number, 16)
	elseif mode == 'f' then
		return tonumber(number)
	elseif mode == 'F' then
		return -tonumber(number)
	end
end

encoders['string'] = function(val, output_len, output)
	-- cache the string
	cache[val] = cache_size
	cache_size = cache_size + 1

	-- encode it...
	local strlen = string_len(val)

	while(strlen >= 47)do
		output[output_len] = num_to_char[47+strlen%47]
		output_len = output_len + 1
		strlen = strlen/47
		strlen = strlen - strlen % 1
	end
	output[output_len] = num_to_char[strlen%47]
	output_len = output_len + 1

	output[output_len] = val
	return output_len + 1
end

decoders['string'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end

	local str = string_sub(str, index, index+num-1)
	cache[cache_size] = str
	cache_size = cache_size + 1
	index = index+num
	return str
end

encoders['Entity'] = function(val, output_len, output)
	val = val:EntIndex()
	while(val >= 47)do
		output[output_len] = num_to_char[47+val%47]
		output_len = output_len + 1
		val = val/47
		val = val - val%1
	end
	output[output_len] = num_to_char[val%47]
	return output_len + 1
end
encoders['Player'] 	= encoders['Entity']
encoders['Vehicle'] = encoders['Entity']
encoders['Weapon'] 	= encoders['Entity']
encoders['NPC'] 		= encoders['Entity']
encoders['NextBot'] = encoders['Entity']

decoders['Entity'] = function()
	local num = 0
	local val
	local multiplier = 1
	while(true)do
		val = char_to_num[string_sub(str, index, index)]
		index = index + 1
		if val < 47 then
			num = num + val*multiplier
			break
		else
			num = num + (val-47)*multiplier
		end
		multiplier = multiplier * 47
	end
	return Entity(num)
end

decoders['Player'] 	= decoders['Entity']
decoders['Vehicle'] = decoders['Entity']
decoders['Weapon'] 	= decoders['Entity']
decoders['NPC'] 		= decoders['Entity']
decoders['NextBot'] = decoders['Entity']


local writeNumber = encoders['number']
local readNumber = decoders['number']

encoders['Vector'] = function(val, output_len, output)
	return writeNumber(val.z, 
		writeNumber(val.y, 
			writeNumber(val.x, output_len, output), 
			output), 
		output)
end

decoders['Vector'] = function(val)
	return Vector(readNumber(), readNumber(), readNumber())
end

encoders['Angle'] = function(val)
	return writeNumber(val.r, 
		writeNumber(val.y, 
			writeNumber(val.p, output_len, output), 
			output), 
		output)
end
decoders['Angle'] = function(val)
	return Angle(readNumber(), readNumber(), readNumber())
end





pon2_dev.encode = function(val)
	cache_size = 0
	output_len = 1
	encoders['table'](val, output_len, output)
	local result = table_concat(output)

	for i = 1, output_len do
		output[i] = nil
	end
	for k,v in pairs(cache)do
		cache[k] = nil
	end

	return result
end

pon2_dev.decode = function(val)
	cache_size = 0
	index = 1
	str = val
	strlen = string_len(val)
	obj = decoders['table']()

	for i = 0, cache_size do
		cache[i] = nil
	end

	return obj
end
