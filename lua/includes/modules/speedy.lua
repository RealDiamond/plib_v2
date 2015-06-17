-- Many things in garrysmod could be implemented faster but not everything needs a complete recode like the hook library so we'll chuck it here.


-- Net
do 
	local net 		= net
	local IsValid 	= IsValid
	local Entity 	= Entity

	function net.WriteEntity(ent)
		if IsValid(ent) then 
			net.WriteUInt(ent:EntIndex(), 12)
		else
			net.WriteUInt(0, 12)
		end
	end

	function net.ReadEntity()
		local i = net.ReadUInt(12)
		if not i then return end
		return Entity(i)
	end
end


if (SERVER) then return end

-- Surface
do
	local SetFont 		= surface.SetFont
	local GetTextSize 	= surface.GetTextSize

	local Font 			= 'TargetID'
	local SizeCache 	= {}

	function surface.SetFont(font)
		Font = font
		return SetFont(font)
	end
	 
	function surface.GetTextSize(text)
		if (not SizeCache[Font]) then
			SizeCache[Font] = {}
		end
		   
		if (not SizeCache[Font][text]) then
			local x, y = GetTextSize(text)
			SizeCache[Font][text] = {
				x = x, 
				y = y
			}
		end
		   
		return SizeCache[Font][text].x, SizeCache[Font][text].y
	end
	 
	timer.Create('PurgeFontCache', 1200, 0, function()
		SizeCachehe = {}
	end)
end
