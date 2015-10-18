function string.Apostrophe(str)
	local len = string.len(str)
	
	if (string.lower(string.sub(str, len, len)) == "s") then
		return "\'"
	else
		return "\'s"
	end
end

function string.NumberCommas(str)
	return str:reverse():gsub("(...)", "%1,"):gsub(",$", ""):reverse()
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