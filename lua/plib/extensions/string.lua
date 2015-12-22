function string.Apostrophe(str)
	local len = str:len()
	
	if (str:sub(len, len):lower() == "s") then
		return "\'"
	else
		return "\'s"
	end
end

function string.AOrAn(str)
	return str:match("^h?[AaEeIiOoUu]") and "an" or "a"
end

function string.Random(chars)
	local str = ''
	for i = 1, (chars or 10) do
		str = str .. string.char(math.random(97, 122))
	end
	return str
end

function string.HtmlSafe(str)
    return str:gsub("&", "&amp;"):gsub("<", "&lt;"):gsub(">", "&gt;")
end

function string.ExplodeQuotes(str) -- Re-do this one of these days
	str = ' ' .. str .. ' '
	local res = {}
	local ind = 1
	while true do
		local sInd, start = str:find('[^%s]', ind)
		if not sInd then break end
		ind = sInd + 1
		local quoted = str:sub(sInd, sInd):match('["\']') and true or false
		local fInd, finish = str:find(quoted and '["\']' or '[%s]', ind)
		if not fInd then break end
		ind = fInd + 1
		local str = str:sub(quoted and sInd + 1 or sInd, fInd - 1)
		res[#res + 1] = str
	end
	return res
end

function string.IsSteamID(str)
	return str:match("^STEAM_%d:%d:%d+$")
end

local formatHex = "%%%02X"

function string.URLEncode(str)
	return str:gsub("([^%w%-%_%.%~])", function( hex ) 
		return formatHex:format( hex:byte() ) 
	end )
end

function util.URLDecode(str)
	return str:gsub( "+", " " ):gsub( "%%(%x%x)", function( hex )
		return string.char( tonumber( hex, 16 ) )
	end )
	return r
end
