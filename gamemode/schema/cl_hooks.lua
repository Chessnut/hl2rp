SCHEMA.overlayText = SCHEMA.overlayText or {}
SCHEMA.overlayID = SCHEMA.overlayID or 0

local SCANNER_PIC_W = 550
local SCANNER_PIC_H = 380

surface.CreateFont("nut_ScannerText", {
	font = "Arial",
	weight = 800,
	size = 26,
	antialias = false,
	outline = true
})

function SCHEMA:DoSchemaIntro()
	timer.Simple(1, function()
		LocalPlayer():SetDSP(133, false)
		LocalPlayer():EmitSound(LocalPlayer():IsCombine() and "npc/overwatch/radiovoice/remindermemoryreplacement.wav" or "vo/breencast/br_welcome02.wav", 100, 90)

		timer.Simple(10, function()
			LocalPlayer():SetDSP(0)
			LocalPlayer():EmitSound("ambient/machines/thumper_hit.wav", 75)
		end)
	end)
end

function SCHEMA:CreateQuickMenu(panel)
	local button = panel:Add("DButton")
	button:Dock(TOP)
	button:SetText("Quick Voice >>")
	button:SetTextColor(Color(5, 5, 5))
	button:SetFont("nut_TargetFontSmall")
	button:SetTall(28)
	button.DoClick = function()
		local menu = DermaMenu()
			for k, v in SortedPairs(nut.voice.buffer) do
				if (k == "dispatch" and !self:CanPlayerDispatch()) then continue end
				if (k == "combine" and !LocalPlayer():IsCombine()) then continue end

				local name = k:sub(1, 1):upper()..k:sub(2)
				local subMenu = menu:AddSubMenu(name)
				subMenu:SetMaxHeight(480)

				for k2, v2 in SortedPairs(v) do
					local option = subMenu:AddOption(k2:sub(1, 1):upper()..k2:sub(2), function()
						if (k == "dispatch") then k2 = "/dispatch "..k2 end

						RunConsoleCommand("say", k2)
					end)
					option:SetToolTip(v2.replacement)
				end
			end
		menu:Open()
	end
end

SCHEMA.deltaColor = SCHEMA.deltaColor or 0
SCHEMA.color = SCHEMA.color or 0
SCHEMA.deltaBlur = SCHEMA.deltaBlur or 0

function SCHEMA:RenderScreenspaceEffects()
	local blur = LocalPlayer():GetNetVar("blur", 0)
	self.deltaBlur = math.Approach(self.deltaBlur, LocalPlayer():GetNetVar("blur", 0), FrameTime() * 0.25)

	if (self.deltaBlur > 0) then
		DrawMotionBlur(0.1, self.deltaBlur, 0.01)
	end
end

function SCHEMA:ModifyColorCorrection(color)
	local viewEntity = LocalPlayer():GetViewEntity()
	
	if (LocalPlayer():CharClass() == CLASS_CP_SCN and IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
		color["$pp_colour_colour"] = 0
		color["$pp_colour_brightness"] = -0.1
		color["$pp_colour_contrast"] = 1.2
		color["$pp_colour_addr"] = 0
		color["$pp_colour_addg"] = 0
		color["$pp_colour_addb"] = 0
		color["$pp_colour_mulr"] = 0
		color["$pp_colour_mulg"] = 0
		color["$pp_colour_mulb"] = 0

		return
	end

	if (LocalPlayer():Team() == FACTION_OW) then
		if (LocalPlayer():CharClass() == CLASS_OW_ELITE) then
			color["$pp_colour_addr"] = color["$pp_colour_addr"] + 0.2
		else
			color["$pp_colour_addg"] = color["$pp_colour_addg"] + 0.02
			color["$pp_colour_addb"] = color["$pp_colour_addb"] + 0.06
		end

		color["$pp_colour_brightness"] = color["$pp_colour_brightness"] + 0.03
	end

	if (IsValid(nut.gui.charMenu)) then
		color["$pp_colour_brightness"] = -0.4
		color["$pp_colour_colour"] = 0
		color["$pp_colour_contrast"] = 1.5
	end

	self.color = LocalPlayer():GetNetVar("noDepress") or 0
	self.deltaColor = math.Approach(self.deltaColor, self.color, FrameTime() * 0.25)
	color["$pp_colour_colour"] = math.max(color["$pp_colour_colour"] + self.deltaColor, 0)
end

local COMBINE_OVERLAY

function SCHEMA:AdjustMouseSensitivity(default)
	local viewEntity = LocalPlayer():GetViewEntity()

	if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
		return 0.25
	end
end

local NEXT_CLICK = 0

function SCHEMA:CalcView(client, origin, angles, fov)
	local viewEntity = LocalPlayer():GetViewEntity()

	if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
		local view = {}
			view.angles = client:GetAimVector():Angle()
		return view
	end
end

local highest = 0


function SCHEMA:HUDPaint()
	if (LocalPlayer():IsCombine()) then
		self.target = nil

		local viewEntity = LocalPlayer():GetViewEntity()

		if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
			if (!self.switchedCam) then
				LocalPlayer():EmitSound("buttons/button18.wav")
				self.switchedCam = true
			end

			local scrW, scrH = ScrW(), ScrH()
			local w, h = SCANNER_PIC_W, SCANNER_PIC_H
			local x, y = scrW*0.5 - (w * 0.5), scrH*0.5 - (h * 0.5)
			local x2, y2 = x + w*0.5, y + h*0.5

			surface.SetDrawColor(255, 255, 255, 10 + math.random(0, 1))
			surface.DrawRect(x, y, w, h)

			surface.SetDrawColor(255, 255, 255, 150 + math.random(-50, 50))
			surface.DrawOutlinedRect(x, y, w, h)

			surface.DrawLine(x2, 0, x2, y)
			surface.DrawLine(x2, y + h, x2, ScrH())
			surface.DrawLine(0, y2, x, y2)
			surface.DrawLine(x + w, y2, ScrW(), y2)

			x = x + 8
			y = y + 8

			local position = LocalPlayer():GetPos()

			draw.SimpleText("POS: ("..math.floor(position.x)..","..math.floor(position.y)..","..math.floor(position.z).."); "..string.upper(LocalPlayer():GetNetVar("area", "UNKNOWN")), "nut_ScannerText", x, y, color_white, 0, 0)
			draw.SimpleText("YAW: "..math.floor(LocalPlayer():GetAngles().y).."; PITCH: "..math.floor(-LocalPlayer():GetAngles().p), "nut_ScannerText", x, y + 24, color_white, 0, 0)

			local r, g, b = 185, 185, 185
			local length = 64
			local trace = util.QuickTrace(viewEntity:GetPos(), LocalPlayer():GetAimVector()*3600, viewEntity)
			local entity = trace.Entity

			if (IsValid(entity) and entity:IsPlayer() and entity.character) then
				self.target = entity
				draw.SimpleText("TARGET: "..string.upper(entity.character:GetVar("charname", "John Doe")).."; VITALS: "..entity:Health().."%", "nut_ScannerText", x, y + 48, color_white, 0, 0)
				r = 255
				g = 255
				b = 255
			else
				draw.SimpleText("TARGET: NONE", "nut_ScannerText", x, y + 48, color_white, 0, 0)
			end

			local expire = LocalPlayer():GetNutVar("nextShot", 0) - CurTime()

			if (expire > 0) then
				draw.SimpleText("RECHARGING: "..math.Round(expire, 2), "nut_ScannerText", x, y + 72, Color(255, 175, 125, 160 + math.sin(RealTime()*10)*95), 0, 0)
			end

			surface.SetDrawColor(r, g, b, 175 + math.sin(RealTime()*7.5)*30)

			surface.DrawLine(scrW*0.5 - length, scrH*0.5 - length, scrW*0.5 + length, scrH*0.5 + length)
			surface.DrawLine(scrW*0.5 + length, scrH*0.5 - length, scrW*0.5 - length, scrH*0.5 + length)
		else
			if (self.switchedCam) then
				LocalPlayer():EmitSound("buttons/button18.wav", 100, 95)
				self.switchedCam = false
			end

			if (!COMBINE_OVERLAY) then
				COMBINE_OVERLAY = Material("effects/combine_binocoverlay")
				COMBINE_OVERLAY:SetFloat("$alpha", "0.4")
				COMBINE_OVERLAY:Recompute()
			end

			surface.SetDrawColor(255, 255, 255, 50)
			surface.SetMaterial(COMBINE_OVERLAY)
			surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
		end

		self:HUDPaintOverlayText()
	end
end

function SCHEMA:ShouldDrawCrosshair()
	local viewEntity = LocalPlayer():GetViewEntity()

	if (IsValid(viewEntity) and viewEntity:GetClass():find("scanner")) then
		return false
	end
end

local OVERLAY_BG = Color(0, 0, 0, 175)

function SCHEMA:HUDPaintOverlayText()
	for i = 1, #self.overlayText do
		local data = self.overlayText[i]
		local x, y = 8, (i - 1) * 16 + 8

		surface.SetFont("BudgetLabel")
		local w, h = surface.GetTextSize(data.text)

		surface.SetDrawColor(data.bgColor or OVERLAY_BG)
		surface.DrawRect(x, y + 6, w + 12, h)

		draw.SimpleText(data.text, "BudgetLabel", x + 6, y + 6, color_white, 0, 0)
	end
end

function SCHEMA:GetDrawViewModel(client, weapon)
	if (client:CharClass() == CLASS_CP_SCN) then
		return false
	end
end

SCHEMA.overlayID = SCHEMA.overlayID or 0

function SCHEMA:AddOverlayText(text, bgColor)
	self.overlayID = self.overlayID + 1
	text = "<:: "..string.upper(text)

	if (bgColor) then
		bgColor.a = 175
	end

	local data = {
		text = "",
		bgColor = bgColor
	}

	table.insert(self.overlayText, data)

	if (#self.overlayText > 8) then
		table.remove(self.overlayText, 1)
	end

	local i = 1
	local uniqueID = "nut_OverlayText"..self.overlayID

	timer.Create(uniqueID, 0.005, #text + 1, function()
		data.text = string.sub(text, 1, i + 2)
		i = i + 3

		if (data.text == #text) then
			LocalPlayer():EmitSound("buttons/button24.wav", 40, 135)
			timer.Remove(uniqueID)
		end
	end)

	LocalPlayer():EmitSound("buttons/button24.wav", 40, 160)
end

function SCHEMA:PreDrawOpaqueRenderables()
	local viewEntity = LocalPlayer():GetViewEntity()

	if (IsValid(self.lastViewEntity) and self.lastViewEntity != viewEntity) then
		self.lastViewEntity:SetNoDraw(false)
		self.lastViewEntity = nil
	end

	if (IsValid(viewEntity) and (viewEntity:GetClass() == "npc_cscanner" or viewEntity:GetClass() == "npc_clawscanner")) then
		viewEntity:SetNoDraw(true)
		self.lastViewEntity = viewEntity
	end
end

function SCHEMA:PlayerBindPress(client, bind, pressed)
	if (bind == "+attack" and pressed) then
		self:SendScreenshot()
	end
end

function SCHEMA:SendScreenshot()
	if (LocalPlayer():GetNutVar("nextShotAttempt", 0) < CurTime()) then
		LocalPlayer():SetNutVar("nextShotAttempt", CurTime() + 1)
	else
		return
	end

	if (!LocalPlayer():IsCombine() or !LocalPlayer():CharClass() == FACTION_CP_SCN) then
		return
	end

	local viewEntity = LocalPlayer():GetViewEntity()

	if (!IsValid(viewEntity) or !viewEntity:GetClass():find("scanner")) then
		return
	end

	if (LocalPlayer():GetNutVar("nextShot", 0) >= CurTime()) then
		return LocalPlayer():EmitSound("buttons/combine_button3.wav", 80, 120)
	end

	local light = DynamicLight(0)
	light.Pos = LocalPlayer():GetPos()
	light.r = 255
	light.g = 255
	light.b = 255
	light.Brightness = 4
	light.Size = 2000
	light.Decay = 4000
	light.DieTime = CurTime() + 2
	light.Style = 0

	timer.Simple(FrameTime() * 2, function()
		local scrW, scrH = ScrW(), ScrH()
		local w, h = SCANNER_PIC_W, SCANNER_PIC_H
		local x, y = scrW*0.5 - (w * 0.5), scrH*0.5 - (h * 0.5)
		local data = util.Base64Encode(render.Capture({
			quality = 50,
			x = x,
			y = y,
			w = w,
			h = h,
			format = "jpeg"
		}))

		if (data) then
			netstream.Start("nut_ScannerShot", data)
			LocalPlayer():SetNutVar("nextShot", CurTime() + 20)
		end
	end)
end

IMAGE_ID = IMAGE_ID or 1

function SCHEMA:CreateScannerImage(data)
	local function CreateImagePanel(x, y, w, h)
		local parent = vgui.Create("DPanel")
		parent:SetDrawBackground(false)
		parent:SetPos(x, y)
		parent:SetSize(w, h)
		
		local texture = Material("effects/tvscreen_noise002a")	
		
		local panel = parent:Add("DHTML")
		panel:DockMargin(0, 0, 0, 0)
		panel:Dock(FILL)
		panel:SetHTML([[<html style="padding:0px;margin:0px;overflow:hidden;"><img width="100%" height="100%" src="data:image/jpeg;base64,]]..data..[[" alt="" /></html>]])	
		panel.PaintOver = function(panel, w, h)
			surface.SetDrawColor(255, 255, 255, 25)
			surface.SetMaterial(texture)
			surface.DrawTexturedRect(8, 8, w - 16, h)
				
			local flash = math.abs(math.sin(RealTime() * 3) * 150)
			surface.SetDrawColor(40 + flash, 40 + flash, 40 + flash, 255)
			
			for i = 1, 3 do
				surface.DrawOutlinedRect(7 + i, 7 + i, w - 14 - i*2, h - 6 - i*2)
			end
		end
		
		parent.html = panel
		
		return parent
	end

	local width, height = SCANNER_PIC_W, SCANNER_PIC_H
	local panel = CreateImagePanel(128, 16, width, height)
	local w, h = width * 0.75, height * 0.75

	panel:SetPos(ScrW() + w + 16, 16)
	panel:SetSize(w, h)
	panel:MoveTo(ScrW() - (w*IMAGE_ID + 16), 16, 0.35, 0.1, 0.33)

	IMAGE_ID = IMAGE_ID + 1

	timer.Simple(15, function()
		if (IsValid(panel)) then
			panel:MoveTo(ScrW() + (w + 16), 16, 0.4, 0)
			
			timer.Simple(0.5, function()
				IMAGE_ID = math.max(IMAGE_ID - 1, 0)
				panel:Remove()
			end)
		end
	end)
end

function SCHEMA:IsPlayerRecognized(client)
	if (client:IsCombine()) then
		return true
	end
end

netstream.Hook("nut_ScannerData", function(data)
	SCHEMA:CreateScannerImage(data)
end)

netstream.Hook("nut_OverlayText", function(data)
	if (LocalPlayer():IsCombine()) then
		SCHEMA:AddOverlayText(data[1], data[2])
	end
end)

netstream.Hook("nut_RefreshBusiness", function()
	nut.gui.business:Remove()
	nut.gui.business = vgui.Create("nut_Business", self)
	nut.gui.menu:SetCurrentMenu(nut.gui.business, true)
end)