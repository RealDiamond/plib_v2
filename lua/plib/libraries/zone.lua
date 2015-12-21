local _R = debug.getregistry()

do
	local PRISM = {}

	_R.Prism = PRISM
	_R.Prism.__index = _R.Prism
	
	function QuadPrism( mins, maxs )
		return setmetatable( {	minX = mins.x, minY = mins.y, minZ = mins.z,
								maxX = maxs.x, maxY = maxs.y, maxZ = maxs.z }, PRISM )
	end

	-- Caching
	local vecX
	local vecY
	local vecZ

	function PRISM:PointInside( point )
		vecX = point.x
		vecY = point.y
		vecZ = point.z
		
		if ( vecX < self.minX or vecX > self.maxX or 
			vecY < self.minY or vecY > self.maxY or
			vecZ < self.minZ or vecZ > self.maxZ ) then
			return false
		end
		
		return true
	end
	
	function PRISM:GetMins()
		return Vector( self.minX, self.minY, self.minZ )
	end
	
	function PRISM:GetMaxs()
		return Vector( self.maxX, self.maxY, self.maxZ )
	end
end

do
	local SPHERE = {}

	_R.Sphere = SPHERE
	_R.Sphere.__index = _R.Sphere
	
	-- No ovoid support for now b/c too expensive
	function Sphere( center, radius )
		return setmetatable( {  x = center.x, y = center.y, z = center.z, 
								radius = radius }, SPHERE )
	end

	-- Caching
	local vecX
	local vecY
	local vecZ
	
	function SPHERE:PointInside( point )
		vecX = point.x
		vecY = point.y
		vecZ = point.z
		
		return ( vecX - self.x )^2 + ( vecY - self.y )^2 + ( vecZ - self.z )^2 <= r^2 -- Check if ^2 or *itself is less expensive
	end
end
