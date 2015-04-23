p = {}

p.print = function(msg)
	return MsgC(Color(175,0,255), '[pLib] ', Color(250,250,250), tostring(msg) .. '\n')
end
/*
p.error = function(error)
	local level = 1
	  
	Msg( "\nTrace: \n" )
	  
	while true do
	  
		local info = debug.getinfo(level, "Sln")
		if (!info) then break end
		
		if (info.what) == "C" then
		
			Msg(level, "\tC function\n")
		  
		else
		
			Msg( string.format( "\t%i: Line %d\t\"%s\"\t%s\n", level, info.currentline, info.name, info.short_src ) )
		  
		end
		
		level = level + 1
		
	end
	  
	Msg( "\n\n" )
end
*/
p.include_sv = (SERVER) and include or function() end
p.include_cl = (SERVER) and AddCSLuaFile or include
p.include_sh = function(p) p.include_sv(p) p.include_cl(p) end
p.include = p.include_sh