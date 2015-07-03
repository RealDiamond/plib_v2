function string.Apostrophe( str )
  local len = string.len( str )
  
  if ( string.lower( string.sub( str, len, len ) ) == "s" ) then
    return "\'"
  else
    return "\'s"
  end
end

function string.NumberCommas( str )
	str = tostring( str )
	
    return str:reverse():gsub( "(...)", "%1," ):gsub( ",$", "" ):reverse()
end

function string.AOrAn( s )
	return string.match( s, "^h?[AaEeIiOoUu]" ) and "an" or "a"
end
