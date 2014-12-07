local PANEL = {}

function PANEL:Init()
	self:SetSize(300, 400)
	self:Center()
	self:SetTitle("Select your Facemap")
	self:MakePopup()
	self:SetSizable(false)
	self:SetDraggable(false)

	self.submit = self:Add("DButton")
	self.submit:Dock(BOTTOM)
	self.submit:SetTall(30)
	self.submit:SetText("Submit")
	self.submit.DoClick = function()
		netstream.Start("charFacemap", math.ceil(self.skins:GetValue()))
		self:Close()
	end

	self.skins = self:Add("DNumSlider")
	self.skins:Dock(BOTTOM)
	self.skins:SetTall(30)
	self.skins:SetText("Facemap")
	self.skins:DockMargin(10, 0, 0, 0)
	self.skins:SetDecimals(0)
	self.skins:SetMin(0)
	self.skins:SetMax(5)
	self.skins:SetValue(0)
	self.skins.OnValueChanged = function(sld)
		local val = sld:GetValue()
		self:ChangeModelTexture(val)
	end

	self.model = self:Add("DModelPanel")
	self.model:Dock(FILL)
	self.model:SetModel(LocalPlayer():GetModel())
	self.model:SetFOV(10)
	self.model:SetCamPos( self.model:GetCamPos() - Vector( 0, 0, 15 ) )

	self.model.LayoutEntity = function(self, ent)
		ent:SetAngles(Angle(0, 45 + math.sin(RealTime())*10, 0))
		ent:SetPos(Vector(0, 0, -25))
	end

	self:InitModel()
end

function PANEL:Think()
	self:MoveToFront()
end

function PANEL:InitModel()
	local ent = self.model.Entity

	if (ent and ent:IsValid()) then
		local mdl = string.lower(ent:GetModel())
		local mdldat = RESKINDATA[mdl]

		if (mdldat and mdldat.facemaps) then
			self.skins:SetMax(#mdldat.facemaps)
		end
	end
end

function PANEL:ChangeModelTexture(value)
	local ent = self.model.Entity

	if (ent and ent:IsValid()) then
		local mdl = string.lower(ent:GetModel())
		local mdldat = RESKINDATA[mdl]
		value = math.ceil(value)

		if (value == 0) then
			ent:SetSubMaterial(mdldat[2] - 1, "")
		else
			local facemap = mdldat.facemaps[value]
			ent:SetSubMaterial(mdldat[2] - 1, facemap)
		end
	end
end

vgui.Register("nutCitizenHead", PANEL, "DFrame")

local PANEL = {}

function PANEL:Init()
	self:SetSize(300, 400)
	self:Center()
	self:SetTitle("Citizen Preview")
	self:MakePopup()
	self:SetSizable(false)
	self:SetDraggable(false)	

	self.submit = self:Add("DButton")
	self.submit:Dock(BOTTOM)
	self.submit:SetTall(30)
	self.submit:SetText("Close")
	self.submit.DoClick = function()
		self:Close()
	end

	self.model = self:Add("DModelPanel")
	self.model:Dock(FILL)
	self.model:SetModel(LocalPlayer():GetModel())
	self.model:SetFOV(40)
	self.model:SetCamPos( self.model:GetCamPos() - Vector( 0, 0, 0 ) )

	self.model.LayoutEntity = function(self, ent)
		ent:SetIK(false)
		ent:SetCycle(.49)
		ent:SetAngles(Angle(0, 45 + RealTime()*70, 0))
		ent:SetPos(Vector(0, 0, 10))
	end

	self.model.PaintOver = function(pnl, w, h)
		if (self.error) then
			local tx, ty = draw.SimpleText(self.error, "DermaDefault", 10, h - 10, Color(255, 20, 20), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP)
		end
	end
end

function PANEL:Think()
	self:MoveToFront()
end

function PANEL:InitModel(sheetdata)
	local ent = self.model.Entity

	if (ent and ent:IsValid()) then
		local mdl = string.lower(ent:GetModel())
		local mdldat = RESKINDATA[mdl]

		if (!mdl) then
			self.error = "This model is not supported (no mdltexcoord)"
			return
		end

		if (mdldat.sheets == sheetdata[1]) then
			local sheet = CITIZENSHEETS[sheetdata[1]][sheetdata[2]]
			if (!sheet) then
				self.error = "Incorrect Sheetdata"
				return	
			end

			ent:SetSubMaterial(mdldat[1] - 1, sheet)
		else
			self.error = "This model is not supported (sheetdata)"
			return
		end
	end
end

vgui.Register("nutCitizenPreview", PANEL, "DFrame")

netstream.Hook("nutCitizenPreview", function(sheetdata)
	if (previewWindow and previewWindow:IsVisible()) then
		previewWindow:Close()
		previewWindow = nil
	end
	
	previewWindow = vgui.Create("nutCitizenPreview")
	previewWindow:InitModel(sheetdata)
end)

netstream.Hook("charFacemapMenu", function()
	local menu = vgui.Create("nutCitizenHead")
end)
