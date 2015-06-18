local ASCII_OFFSET = 32
local ASCII_UPPER_BOUND = 126
local ASCII_COUNT = 94 -- 126 - 32

local NUM_TO_CHAR = {}
local CHAR_TO_NUM = {}

for i = 0, ASCII_COUNT - 1 do
	local char = string.char(i + ASCII_OFFSET)
	NUM_TO_CHAR[i] = char
	CHAR_TO_NUM[char] = i
end


-- TODO: benchmark. is this faster to pass on stack?
local output = {}
local index = 1

local encode_number1
do
	local depth = 0
	local function _encode_number(num)
		if num == 0 then return end
		depth = depth + 1

		local next = num / 94
		next = next - next % 1
		return 32 + num % 94, _encode_number1(next)
	end

	local string_byte = string.byte 
	function encode_number1(num)
		depth = 32
		return string_byte(depth, _encode_number(num))
	end
end

print(encode_number1(100000))