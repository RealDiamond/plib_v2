p = {}

p.print = function(msg)
	return MsgC(Color(175,0,255), '[pLib] ', Color(250,250,250), tostring(msg) .. '\n')
end

p.include_sv = (SERVER) and include or function() end
p.include_cl = (SERVER) and AddCSLuaFile or include
p.include_sh = function(p) p.include_sv(p) p.include_cl(p) end