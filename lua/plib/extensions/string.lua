function string.Apostrophe(str)
	local len = string.len(str)
	
	if (string.lower(string.sub(str, len, len)) == "s") then
		return "\'"
	else
		return "\'s"
	end
end

function string.AOrAn(s)
	return string.match(s, "^h?[AaEeIiOoUu]") and "an" or "a"
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
	while (true) do
		local sInd, start = string.find(str, '[^%s]', ind)
		if not sInd then break end
		ind = sInd + 1
		local quoted = str:sub(sInd, sInd):match('["\']') and true or false
		local fInd, finish = string.find(str, quoted and '["\']' or '[%s]', ind)
		if not fInd then break end
		ind = fInd + 1
		local str = str:sub(quoted and sInd + 1 or sInd, fInd - 1)
		res[#res + 1] = str
	end
	return res
end

function string.IsSteamID(str)
	return str:match('^STEAM_%d:%d:%d+$')
end