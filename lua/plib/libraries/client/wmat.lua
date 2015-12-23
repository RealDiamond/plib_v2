wmat = {
	Queue = {},
	Cache = {},
	Busy = false,
	HandlerURL = ''
}

require 'xbench'

function wmat.Create(name, opts, onsuccess, onfailure)
	local crc = util.CRC(name .. '.' .. opts.URL)
	table.insert(wmat.Queue, {
		Name 		= name,
		URL 		= string.JavascriptSafe(opts.URL),
		CRC			= crc,
		Cache		= opts.Cache,
		W 			= (opts.W or 4096),
		H 			= (opts.H or 4096),
		Timeout 	= (opts.Timeout or 5),
		OnSuccess 	= function(html_mat, w, h, wascached)
			local id = util.CRC(opts.URL .. name)
			local rt = GetRenderTarget('wmat_' .. id, w, h, RT_SIZE_NO_CHANGE, 0, 0, 0, 0)

			opts.MaterialData 					= opts.MaterialData 				or {}
			opts.MaterialData['$basetexture'] 	= opts.MaterialData['$basetexture'] or rt:GetName()
			opts.MaterialData['$translucent'] 	= opts.MaterialData['$translucent'] or 1

			local mat = CreateMaterial('wmat_' .. id, (opts.Shader or 'UnlitGeneric'), opts.MaterialData)
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
			
			if (!wascached and opts.Cache) then wmat.Queue[1].CompleteCache() end

			table.remove(wmat.Queue, 1)
			wmat.Cache[name] = mat
			wmat.Busy = false

			if onsuccess then onsuccess(mat) end
		end,
		OnFailure = function()
			if (wmat.Queue[1].NoFail) then return end
			
			table.remove(wmat.Queue, 1)
			wmat.Busy = false
			if onfailure then onfailure() end
		end,
		Base64 = '',
		CacheChunk = function(chunk)
			wmat.Queue[1].Base64 = wmat.Queue[1].Base64 .. chunk		
		end,
		CompleteCache = function()		
			file.WriteStaggered('wmatcache/' .. crc, wmat.Queue[1].Base64, function() end)
		end
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

function wmat.SetHandler(handler)
	wmat.HandlerURL = handler
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
			<canvas id='canvas'/>
		</body>
		<script type='text/JavaScript'>
			var base64 = '';
			var b64size = 0;
			var step = 0;
			var chunkSize = 384 * 1024;
			var timerVar = 0;
			var w = 0;
			var h = 0;
			function handleChunk() {
				console.log('RUNLUA: wmat.Queue[1].CacheChunk("' + base64.substring(step, step+chunkSize) + '")');
				step = step + chunkSize + 1;
				
				if (b64size < step) {
					console.log('RUNLUA: timer.Simple(0.1, function() wmat.Handler:UpdateHTMLTexture() wmat.Queue[1].OnSuccess(wmat.Handler:GetHTMLMaterial(), ' + w + ', ' + h + ') end)');
					clearInterval(timerVar);
				}
			}
				
			function SetImage(handler, url, imgW, imgH, timeout, shouldCache){
				base64 = '';
				b64size = 0;
				step = 0;
				timerVar = 0;
				w = imgW;
				h = imgH;
				
				var loaded = false;

				document.getElementById('cont').innerHTML = "<img id='img' width = '" + w + "' height = '" + h + "'>";
				document.getElementById('img').crossOrigin = 'Anonymous';
				
				setTimeout(function() {
					if (!loaded) {
						console.log('RUNLUA: wmat.Queue[1].OnFailure()');
					}
				}, timeout);
			
				document.getElementById('img').onload = function(){
					loaded = true;
					
					var canvas = document.getElementById('canvas');
					canvas.width = w;
					canvas.height = h;
					var ctx = canvas.getContext('2d');
					var img = document.getElementById('img');
					ctx.drawImage(img, 0, 0, w, h);
					
					if (shouldCache == 1) {
						base64 = canvas.toDataURL();
						b64size = base64.length;
						timerVar = setInterval(handleChunk, 100);
					} else {
						console.log('RUNLUA: timer.Simple(0.1, function() wmat.Handler:UpdateHTMLTexture() wmat.Queue[1].OnSuccess(wmat.Handler:GetHTMLMaterial(), ' + w + ', ' + h + ') end)');
					}
				}
				
				document.getElementById('img').src = handler + encodeURIComponent(url);
			}
			
			function SetImageData(data, w, h){
				document.getElementById('cont').innerHTML = "<img id='img' width = '" + w + "' height = '" + h + "'>";
				
				document.getElementById('img').onload = function() {
					console.log('RUNLUA: timer.Simple(0.5, function() wmat.Handler:UpdateHTMLTexture() wmat.Queue[1].OnSuccess(wmat.Handler:GetHTMLMaterial(), ' + w + ', ' + h + ', true) end)');
				}
				
				document.getElementById('img').src = data;
			}
		</script>
	]])
	
	wmat.Handler.Think = function(self)               
		if (not wmat.Busy) and (#wmat.Queue > 0) then
			local info = wmat.Queue[1]
			
			if (!file.Exists('wmatcache', 'DATA') or !file.IsDir('wmatcache', 'DATA')) then file.CreateDir('wmatcache') end
			
			if (file.Exists('wmatcache/' .. info.CRC .. '/meta.dat', 'DATA')) then
				wmat.Busy = true
				--print("Loading " .. info.Name .. " from cache instead.")
				
				file.ReadStaggered('wmatcache/' .. info.CRC, function(data)
					--print("The data is " .. #data)
					self:RunJavascript('SetImageData("' .. data .. '", "' .. math.Clamp(info.W, 0, 4096)  .. '", "' .. math.Clamp(info.H, 0, 4096) .. '")')
				end)
			else
				self:RunJavascript('SetImage("' .. wmat.HandlerURL .. '", "' .. info.URL.. '", "' .. math.Clamp(info.W, 0, 4096)  .. '", "' .. math.Clamp(info.H, 0, 4096) .. '", "' .. info.Timeout * 1000 .. '", ' .. (info.Cache and 1 or 0) .. ')')
				wmat.Busy = true
			end
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