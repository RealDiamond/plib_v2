wmat = wmat or {
	Queue = {},
	Cache = {},
	Busy = false,
}

function wmat.Create(name, url, callback)
	url =  string.JavascriptSafe(url)
	table.insert(wmat.Queue, {
		Name 		= name,
		URL 		= url,
		Callback 	= function(html_mat)
			local id = util.CRC(url..name)
			local w, h = ScrW(), ScrH()
			
			local rt = GetRenderTarget('wmat_' .. id, w, h, RT_SIZE_NO_CHANGE, 0, 0, 0, 0)

			local mat = wmat.Cache[name] or CreateMaterial('wmat_' .. id, 'UnlitGeneric', {
				['$basetexture'] = rt:GetName(),
				['$translucent'] = 1
			})

			local oldrt = render.GetRenderTarget()

			render.SetViewPort(0, 0, w, h)
			render.SetRenderTarget(rt)
			render.Clear(0, 0, 0, 0)
			render.ClearDepth()
				cam.Start2D()
					surface.SetDrawColor(255, 255, 255, 255)
					surface.SetMaterial(html_mat)
					surface.DrawTexturedRect(0, 0, w, h)
				cam.End2D()
			render.SetViewPort(0, 0, w, h)
			render.SetRenderTarget(oldrt)

			table.remove(wmat.Queue, 1)
			wmat.Cache[name] = mat
			wmat.Busy = false

			if callback then callback(mat) end
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

hook.Add('InitPostEntity', 'wmat.InitPostEntity', function()
	wmat.Handler = vgui.Create 'DHTML'
	wmat.Handler:SetPaintedManually(true)
	wmat.Handler:SetMouseInputEnabled(false)
	wmat.Handler:SetAllowLua(true)
	wmat.Handler:SetHTML([[ 
		<body style="margin: 0; overflow: hidden;">
			<div id="cont"></div>
		</body>
		<script type="text/JavaScript">
			function SetImage(url){
				document.getElementById("cont").innerHTML = "<img src='" + url + "' alt='ERROR!!' id='img'>";
				document.getElementById("img").onload = function(){
					console.log("RUNLUA: wmat.Handler:UpdateHTMLTexture() wmat.Queue[1].Callback(wmat.Handler:GetHTMLMaterial())");
				}
			}
		</script>
	]])
end)

hook.Add('Think', 'wmat.Think', function()
	if IsValid(wmat.Handler) and (not wmat.Busy) and (#wmat.Queue > 0) then
		wmat.Handler:RunJavascript('SetImage("' .. wmat.Queue[1].URL..'")')
		wmat.Busy = true
	end
end)


--[[
wmat.Create('Example2', 'http://i.imgur.com/XlMRGDE.png', print)
wmat.Create('Example1', 'http://i.imgur.com/21vNjxl.png', print)
wmat.Create('Example3', 'http://i.imgur.com/prDBxyg.gif', print)
wmat.Create('Example4', 'http://i.imgur.com/HZNUiFy.gif', print)

hook.Add('HUDPaint', 'awdawd', function()
	for i=1, 4 do
		if wmat.Get('Example' .. i) then 
			surface.SetDrawColor(255,255,255,255)
			surface.SetMaterial(wmat.Get('Example' .. i))
			surface.DrawTexturedRect(320 * (i - 1), 0, 300, 250)
		end
	end
end)
]]
