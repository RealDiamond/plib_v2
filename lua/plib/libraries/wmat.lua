wmat = {
	Queue = {},
	Cache = {},
	Busy = false,
}

function wmat.Create(name, opts, onsuccess, onfailure)
	table.insert(wmat.Queue, {
		Name 		= name,
		URL 		= string.JavascriptSafe(opts.URL),
		W 			= (opts.W or 4096),
		H 			= (opts.H or 4096),
		Timeout 	= (opts.Timeout or 5),
		OnSuccess 	= function(html_mat, w, h)
			local id = util.CRC(opts.URL .. name)
			local rt = GetRenderTarget('wmat_' .. id, w, h, RT_SIZE_NO_CHANGE, 0, 0, 0, 0)

			opts.MaterialData 					= opts.MaterialData 				or {}
			opts.MaterialData['$basetexture'] 	= opts.MaterialData['$basetexture'] or rt:GetName()
			opts.MaterialData['$translucent'] 	= opts.MaterialData['$translucent'] or 1

			local mat = wmat.Cache[name] or CreateMaterial('wmat_' .. id, (opts.Shader or 'UnlitGeneric'), opts.MaterialData)
			local oldrt = render.GetRenderTarget()

			render.SetViewPort(0, 0, w, h)
			render.SetRenderTarget(rt)
			render.Clear(0, 0, 0, 0)
				cam.Start2D()
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(html_mat)
					surface.DrawTexturedRect(0, 0, 4096, 4096)
				cam.End2D()
			render.SetViewPort(0, 0, ScrW(), ScrH())
			render.SetRenderTarget(oldrt)

			table.remove(wmat.Queue, 1)
			wmat.Cache[name] = mat
			wmat.Busy = false

			if onsuccess then onsuccess(mat) end
		end,
		OnFailure = function()
			table.remove(wmat.Queue, 1)
			wmat.Busy = false
			if onfailure then onfailure() end
		end,
	})
end

function wmat.Get(name)
	return wmat.Cache[name]
end

function wmat.Delete(name)
	wmat.Cache[name] = nil
end

function wmat.ClearCache()
	wmat.Cache = {}
end

hook.Add('InitPostEntity', 'wmat.InitPostEntity', function()
	wmat.Handler = vgui.Create 'DHTML'
	wmat.Handler:SetSize(4096, 4096)
	wmat.Handler:SetPaintedManually(true)
	wmat.Handler:SetMouseInputEnabled(false)
	wmat.Handler:SetAllowLua(true)
	wmat.Handler:SetHTML([[ 
		<body style='margin: 0; overflow: hidden;'>
			<div id='cont'></div>
		</body>
		<script type='text/JavaScript'>
			function SetImage(url, w, h, timeout){
				var loaded = false;

				document.getElementById('cont').innerHTML = "<img id='img' src='" + url + "' width = '" + w + "' height = '" + h + "'>";

				setTimeout(function() {
					if (!loaded) {
						console.log('RUNLUA: wmat.Queue[1].OnFailure()');
					}
				}, timeout);
			
				document.getElementById('img').onload = function(){
					loaded = true;
					console.log('RUNLUA: timer.Simple(0.1, function() wmat.Handler:UpdateHTMLTexture() wmat.Queue[1].OnSuccess(wmat.Handler:GetHTMLMaterial(), ' + w + ', ' + h + ') end)');
				}
			}
		</script>
	]])
	wmat.Handler.Think = function(self)
		if (not wmat.Busy) and (#wmat.Queue > 0) then
			local info = wmat.Queue[1]
			self:RunJavascript('SetImage("' .. info.URL.. '", "' .. math.Clamp(info.W, 0, 4096)  .. '", "' .. math.Clamp(info.H, 0, 4096) .. '", "' .. info.Timeout * 1000 .. '")')
			wmat.Busy = true
		end
	end
end)


--[[
wmat.Create('SUP', {
	URL = 'http://portal.superiorservers.co/static/images/favicon.png',
	W 	= 184,
	H 	= 184,
}, function(material)
	print(material)
end, function()
	print 'cunt'
end)

hook.Add('HUDPaint', 'awdawd', function()
	if wmat.Get('SUP') then 
		surface.SetDrawColor(255,255,255,255)
		surface.SetMaterial(wmat.Get('SUP'))
		surface.DrawTexturedRect(10, 10, 184, 184)
	end
end)]]