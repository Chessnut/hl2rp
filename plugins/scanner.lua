PLUGIN.name = "Player Scanners Util"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds functions that allow players to control scanners."

local PICTURE_DELAY = 15

if (SERVER) then
	util.AddNetworkString("nutScannerData")

	function PLUGIN:createScanner(client, class)
		class = class or "npc_cscanner"

		if (IsValid(client.nutScn)) then
			return
		end

		local entity = ents.Create(class)

		if (!IsValid(entity)) then
			return
		end
		
		entity:SetPos(client:GetPos())
		entity:SetAngles(client:GetAngles())
		entity:SetColor(client:GetColor())
		entity:Spawn()
		entity:Activate()
		entity.player = client
		entity:setNetVar("player", client) -- Draw the player info when looking at the scanner.
		entity:CallOnRemove("nutRestore", function()
			if (IsValid(client)) then
				local position = entity.spawn or client:GetPos()

				client:UnSpectate()
				client:SetViewEntity(NULL)

				if (entity:Health() > 0) then
					client:Spawn()
				else
					client:KillSilent()
				end

				timer.Simple(0, function()
					client:SetPos(position)
				end)
			end
		end)

		local name = "nutScn"..os.clock()
		entity.name = name

		local target = ents.Create("path_track")
		target:SetPos(entity:GetPos())
		target:Spawn()
		target:SetName(name)

		entity:Fire("setfollowtarget", name)
		entity:Fire("inputshouldinspect", false)
		entity:Fire("setdistanceoverride", "48")
		entity:SetKeyValue("spawnflags", 8208)

		client.nutScn = entity
		client:StripWeapons()
		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(entity)

		local uniqueID = "nut_Scanner"..client:UniqueID()

		timer.Create(uniqueID, 0.33, 0, function()
			if (!IsValid(client) or !IsValid(entity)) then
				if (IsValid(entity)) then
					entity:Remove()
				end
				
				return timer.Remove(uniqueID)
			end

			local factor = 128

			if (client:KeyDown(IN_SPEED)) then
				factor = 64
			end

			if (client:KeyDown(IN_FORWARD)) then
				target:SetPos((entity:GetPos() + client:GetAimVector()*factor) - Vector(0, 0, 64))
				entity:Fire("setfollowtarget", name)
			elseif (client:KeyDown(IN_BACK)) then
				target:SetPos((entity:GetPos() + client:GetAimVector()*-factor) - Vector(0, 0, 64))
				entity:Fire("setfollowtarget", name)
			elseif (client:KeyDown(IN_JUMP)) then
				target:SetPos(entity:GetPos() + Vector(0, 0, factor))
				entity:Fire("setfollowtarget", name)	
			elseif (client:KeyDown(IN_DUCK)) then
				target:SetPos(entity:GetPos() - Vector(0, 0, factor))
				entity:Fire("setfollowtarget", name)				
			end

			client:SetPos(entity:GetPos())
		end)

		return entity
	end

	function PLUGIN:PlayerSpawn(client)
		if (IsValid(client.nutScn)) then
			client.nutScn.spawn = client:GetPos()
			client.nutScn:Remove()
		end
	end

	function PLUGIN:PlayerDeath(client)
		if (IsValid(client.nutScn)) then
			client.nutScn:TakeDamage(999)
		end
	end

	local SCANNER_SOUNDS = {
		"npc/scanner/scanner_blip1.wav",
		"npc/scanner/scanner_scan1.wav",
		"npc/scanner/scanner_scan2.wav",
		"npc/scanner/scanner_scan4.wav",
		"npc/scanner/scanner_scan5.wav",
		"npc/scanner/combat_scan1.wav",
		"npc/scanner/combat_scan2.wav",
		"npc/scanner/combat_scan3.wav",
		"npc/scanner/combat_scan4.wav",
		"npc/scanner/combat_scan5.wav",
		"npc/scanner/cbot_servoscared.wav",
		"npc/scanner/cbot_servochatter.wav"
	}

	function PLUGIN:KeyPress(client, key)
		if (IsValid(client.nutScn) and (client.nutScnDelay or 0) < CurTime()) then
			local source

			if (key == IN_USE) then
				source = table.Random(SCANNER_SOUNDS)
				client.nutScnDelay = CurTime() + 1.75
			elseif (key == IN_RELOAD) then
				source = "npc/scanner/scanner_talk"..math.random(1, 2)..".wav"
				client.nutScnDelay = CurTime() + 10
			elseif (key == IN_WALK) then
				if (client:GetViewEntity() == client.nutScn) then
					client:SetViewEntity(NULL)
				else
					client:SetViewEntity(client.nutScn)
				end
			end

			if (source) then
				client.nutScn:EmitSound(source)
			end
		end
	end

	function PLUGIN:PlayerNoClip(client)
		if (IsValid(client.nutScn)) then
			return false
		end
	end
	
	function PLUGIN:PlayerUse(client, entity)
		if (IsValid(client.nutScn)) then
			return false
		end
	end

	function PLUGIN:CanPlayerReceiveScan(client, photographer)
		return client.isCombine and client:isCombine()
	end

	net.Receive("nutScannerData", function(length, client)
		if (IsValid(client.nutScn) and client:GetViewEntity() == client.nutScn and (client.nutNextPic or 0) < CurTime()) then
			client.nutNextPic = CurTime() + (PICTURE_DELAY - 1)
			client:GetViewEntity():EmitSound("npc/scanner/scanner_photo1.wav", 140)
			client:EmitSound("npc/scanner/combat_scan5.wav")

			local length = net.ReadUInt(16)
			local data = net.ReadData(length)

			if (length != #data) then
				return
			end

			local receivers = {}

			for k, v in ipairs(player.GetAll()) do
				if (hook.Run("CanPlayerReceiveScan", v, client)) then
					receivers[#receivers + 1] = v
					v:EmitSound("npc/overwatch/radiovoice/preparevisualdownload.wav")
				end
			end

			if (#receivers > 0) then
				net.Start("nutScannerData")
					net.WriteUInt(#data, 16)
					net.WriteData(data, #data)
				net.Send(receivers)

				if (SCHEMA.addDisplay) then
					SCHEMA:addDisplay("Prepare to receive visual download...")
				end
			end
		end
	end)
else
	surface.CreateFont("nutScannerFont", {
		font = "Lucida Sans Typewriter",
		antialias = false,
		outline = true,
		weight = 800,
		size = 18
	})

	local PICTURE_WIDTH, PICTURE_HEIGHT = 580, 420
	local PICTURE_WIDTH2, PICTURE_HEIGHT2 = PICTURE_WIDTH * 0.5, PICTURE_HEIGHT * 0.5

	local view = {}
	local zoom = 0
	local deltaZoom = zoom
	local nextClick = 0

	function PLUGIN:CalcView(client, origin, angles, fov)
		local entity = client:GetViewEntity()

		if (IsValid(entity) and entity:GetClass():find("scanner")) then
			view.angles = client:GetAimVector():Angle()
			view.fov = fov - deltaZoom

			if (math.abs(deltaZoom - zoom) > 5 and nextClick < RealTime()) then
				nextClick = RealTime() + 0.05
				client:EmitSound("common/talk.wav", 100, 180)
			end

			return view
		end
	end

	function PLUGIN:InputMouseApply(command, x, y, angle)
		zoom = math.Clamp(zoom + command:GetMouseWheel()*1.5, 0, 40)
		deltaZoom = Lerp(FrameTime() * 2, deltaZoom, zoom)
	end

	local hidden = false

	function PLUGIN:PreDrawOpaqueRenderables()
		local viewEntity = LocalPlayer():GetViewEntity()

		if (IsValid(self.lastViewEntity) and self.lastViewEntity != viewEntity) then
			self.lastViewEntity:SetNoDraw(false)
			self.lastViewEntity = nil

			hidden = false
		end

		if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
			viewEntity:SetNoDraw(true)
			self.lastViewEntity = viewEntity

			hidden = true
		end
	end

	function PLUGIN:ShouldDrawCrosshair()
		if (hidden) then
			return false
		end
	end

	function PLUGIN:AdjustMouseSensitivity()
		if (hidden) then
			return 0.3
		end
	end

	local data = {}

	function PLUGIN:HUDPaint()
		if (hidden) then
			local scrW, scrH = surface.ScreenWidth() * 0.5, surface.ScreenHeight() * 0.5
			local x, y = scrW - PICTURE_WIDTH2, scrH - PICTURE_HEIGHT2

			if (self.lastPic and self.lastPic >= CurTime()) then
				local percent = math.Round(math.TimeFraction(self.lastPic - PICTURE_DELAY, self.lastPic, CurTime()), 2) * 100
				local glow = math.sin(RealTime() * 15)*25

				draw.SimpleText("RE-CHARGING: "..percent.."%", "nutScannerFont", x, y - 24, Color(255 + glow, 100 + glow, 25, 250))
			end

			local position = LocalPlayer():GetPos()
			local angle = LocalPlayer():GetAimVector():Angle()

			draw.SimpleText("POS ("..math.floor(position[1])..", "..math.floor(position[2])..", "..math.floor(position[3])..")", "nutScannerFont", x + 8, y + 8, color_white)
			draw.SimpleText("ANG ("..math.floor(angle[1])..", "..math.floor(angle[2])..", "..math.floor(angle[3])..")", "nutScannerFont", x + 8, y + 24, color_white)
			draw.SimpleText("ID  ("..LocalPlayer():Name()..")", "nutScannerFont", x + 8, y + 40, color_white)
			draw.SimpleText("ZM  ("..(math.Round(zoom / 40, 2) * 100).."%)", "nutScannerFont", x + 8, y + 56, color_white)

			if (IsValid(self.lastViewEntity)) then
				data.start = self.lastViewEntity:GetPos()
				data.endpos = data.start + LocalPlayer():GetAimVector() * 500
				data.filter = self.lastViewEntity

				local entity = util.TraceLine(data).Entity

				if (IsValid(entity) and entity:IsPlayer()) then
					entity = entity:Name()
				else
					entity = "NULL"
				end

				draw.SimpleText("TRG ("..entity..")", "nutScannerFont", x + 8, y + 72, color_white)
			end

			surface.SetDrawColor(235, 235, 235, 230)

			surface.DrawLine(0, scrH, x - 128, scrH)
			surface.DrawLine(scrW + PICTURE_WIDTH2 + 128, scrH, ScrW(), scrH)
			surface.DrawLine(scrW, 0, scrW, y - 128)
			surface.DrawLine(scrW, scrH + PICTURE_HEIGHT2 + 128, scrW, ScrH())

			surface.DrawLine(x, y, x + 128, y)
			surface.DrawLine(x, y, x, y + 128)

			x = scrW + PICTURE_WIDTH2

			surface.DrawLine(x, y, x - 128, y)
			surface.DrawLine(x, y, x, y + 128)

			x = scrW - PICTURE_WIDTH2
			y = scrH + PICTURE_HEIGHT2

			surface.DrawLine(x, y, x + 128, y)
			surface.DrawLine(x, y, x, y - 128)

			x = scrW + PICTURE_WIDTH2

			surface.DrawLine(x, y, x - 128, y)
			surface.DrawLine(x, y, x, y - 128)

			surface.DrawLine(scrW - 48, scrH, scrW - 8, scrH)
			surface.DrawLine(scrW + 48, scrH, scrW + 8, scrH)
			surface.DrawLine(scrW, scrH - 48, scrW, scrH - 8)
			surface.DrawLine(scrW, scrH + 48, scrW, scrH + 8)
		end
	end

	function PLUGIN:takePicture()
		if ((self.lastPic or 0) < CurTime()) then
			self.lastPic = CurTime() + PICTURE_DELAY

			local flash = DynamicLight(0)

			if (flash) then
				flash.pos = self.lastViewEntity:GetPos()
				flash.r = 255
				flash.g = 255
				flash.b = 255
				flash.brightness = 0.2
				flash.Decay = 5000
				flash.Size = 3000
				flash.DieTime = CurTime() + 0.3

				timer.Simple(0.05, function()
					local data = util.Compress(render.Capture({
						format = "jpeg",
						h = PICTURE_HEIGHT,
						w = PICTURE_WIDTH,
						quality = 35,
						x = ScrW()*0.5 - PICTURE_WIDTH2,
						y = ScrH()*0.5 - PICTURE_HEIGHT2
					}))

					net.Start("nutScannerData")
						net.WriteUInt(#data, 16)
						net.WriteData(data, #data)
					net.SendToServer()
				end)
			end
		end
	end

	local blackAndWhite = {
		["$pp_colour_addr"] = 0, 
		["$pp_colour_addg"] = 0, 
		["$pp_colour_addb"] = 0, 
		["$pp_colour_brightness"] = 0, 
		["$pp_colour_contrast"] = 1.5, 
		["$pp_colour_colour"] = 0, 
		["$pp_colour_mulr"] = 0, 
		["$pp_colour_mulg"] = 0, 
		["$pp_colour_mulb"] = 0
	}

	function PLUGIN:RenderScreenspaceEffects()
		if (hidden) then
			blackAndWhite["$pp_colour_brightness"] = 0.05 + math.sin(RealTime() * 10)*0.01
			DrawColorModify(blackAndWhite)
		end
	end

	function PLUGIN:PlayerBindPress(client, bind, pressed)
		if (bind:lower():find("attack") and pressed and hidden and IsValid(self.lastViewEntity)) then
			self:takePicture()
		end
	end

	PHOTO_CACHE = PHOTO_CACHE or {}

	net.Receive("nutScannerData", function()
		local data = net.ReadData(net.ReadUInt(16))
		data = util.Base64Encode(util.Decompress(data))

		if (data) then
			if (IsValid(CURRENT_PHOTO)) then
				local panel = CURRENT_PHOTO

				CURRENT_PHOTO:AlphaTo(0, 0.25, 0, function()
					if (IsValid(panel)) then
						panel:Remove()
					end
				end)
			end

			local html = Format([[
				<html>
					<body style="background: black; overflow: hidden; margin: 0; padding: 0;">
						<img src="data:image/jpeg;base64,%s" width="%s" height="%s" />
					</body>
				</html>
			]], data, PICTURE_WIDTH, PICTURE_HEIGHT)

			local panel = vgui.Create("DPanel")
			panel:SetSize(PICTURE_WIDTH + 8, PICTURE_HEIGHT + 8)
			panel:SetPos(ScrW(), 8)
			panel:SetDrawBackground(true)
			panel:SetAlpha(150)

			panel.body = panel:Add("DHTML")
			panel.body:Dock(FILL)
			panel.body:DockMargin(4, 4, 4, 4)
			panel.body:SetHTML(html)

			panel:MoveTo(ScrW() - (panel:GetWide() + 8), 8, 0.5)

			timer.Simple(15, function()
				if (IsValid(panel)) then
					panel:MoveTo(ScrW(), 8, 0.5, 0, -1, function()
						panel:Remove()
					end)
				end
			end)

			PHOTO_CACHE[#PHOTO_CACHE + 1] = {data = html, time = os.time()}
			CURRENT_PHOTO = panel
		end
	end)


	concommand.Add("nut_photocache", function()
		local frame = vgui.Create("DFrame")
		frame:SetTitle("Photo Cache")
		frame:SetSize(480, 360)
		frame:MakePopup()
		frame:Center()

		frame.list = frame:Add("DScrollPanel")
		frame.list:Dock(FILL)
		frame.list:SetDrawBackground(true)

		for k, v in ipairs(PHOTO_CACHE) do
			local button = frame.list:Add("DButton")
			button:SetTall(28)
			button:Dock(TOP)
			button:DockMargin(4, 4, 4, 0)
			button:SetText(os.date("%X - %d/%m/%Y", v.time))
			button.DoClick = function()
				local frame2 = vgui.Create("DFrame")
				frame2:SetSize(PICTURE_WIDTH + 8, PICTURE_HEIGHT + 8)
				frame2:SetTitle(button:GetText())
				frame2:MakePopup()
				frame2:Center()

				frame2.body = frame2:Add("DHTML")
				frame2.body:SetHTML(v.data)
				frame2.body:Dock(FILL)
				frame2.body:DockMargin(4, 4, 4, 4)
			end
		end
	end)
end
