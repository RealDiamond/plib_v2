local chunkSize		= 512 * 1024	-- Number of bytes to store in each chunk
local interval		= 0.1			-- Time between each chunk read/write

local w = 1
local r = 2

local staggeredOps	= {}

local function handleStaggeredOps()
	local op = staggeredOps[1]
	
	if (!op) then
		timer.Destroy('file.DoStaggeredOperations')
		return
	end
	
	if (op.Type == w) then
		if (op.Parts == 0 and !file.IsDir(op.Name, 'DATA')) then
			file.CreateDir(op.Name)
			
			return
		end
		
		if (#op.Data < op.Step) then
			file.Write(op.Name .. '/meta.dat', tostring(op.Parts))
			
			if (op.Callback) then
				op.Callback(op.Parts)
			end
			
			table.remove(staggeredOps, 1)
			
			return
		end
		
		op.Parts = op.Parts + 1
		file.Write(op.Name .. '/' .. op.Parts .. '.dat', op.Data:sub(op.Step, op.Step + chunkSize))
		op.Step = op.Step + chunkSize + 1
	elseif (op.Type == r) then
		if (op.Parts == op.Step) then
			if (op.Callback) then
				op.Callback(op.Data)
			end
			
			table.remove(staggeredOps, 1)
			
			return
		end
		
		op.Step = op.Step + 1
		op.Data = op.Data .. file.Read(op.Name .. '/' .. op.Step .. '.dat', 'DATA')
	end
end

function file.WriteStaggered(name, data, callback)
	table.insert(staggeredOps, {
		Type	= w,
		Name	= name,
		Data	= data,
		Parts	= 0,
		Step	= 1,
		Callback = callback
	})
	
	if (!timer.Exists('file.DoStaggeredOperations')) then
		timer.Create('file.DoStaggeredOperations', interval, 0, handleStaggeredOps)
	end
end

function file.ReadStaggered(name, callback)
	if (file.Exists(name .. '/meta.dat', 'DATA')) then
		table.insert(staggeredOps, {
			Type		= r,
			Name		= name,
			Data		= '',
			Parts		= tonumber(file.Read(name .. '/meta.dat')),
			Step		= 0,
			Callback	= callback
		})
		
		if (!timer.Exists('file.DoStaggeredOperations')) then
			timer.Create('file.DoStaggeredOperations', interval, 0, handleStaggeredOps)
		end
	else
		callback('')
	end
end