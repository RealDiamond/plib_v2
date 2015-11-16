function table.Stack( ... )
	local final = {}
	
	for _, tbl in pairs( ... ) do
		table.Add( final, tbl )
	end
end
