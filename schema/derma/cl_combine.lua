local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.combine)) then
			nut.gui.combine:saveData()
			nut.gui.combine:Remove()
		end

		nut.gui.combine = self

		self:SetSize(580, 360)
		self:SetPos(cookie.GetNumber("nutCombineX", ScrW() - self:GetWide()), cookie.GetNumber("nutCombineY", ScrH()*0.5 - self:GetTall()*0.5))
		self:SetMouseInputEnabled(true)
		self:SetTitle("Combine Display Locator")
		self:MakePopup()
		self:SetScreenLock(true)
		self:ShowCloseButton(false)
		self:SetVisible(false)
		self:SetAlpha(math.max(cookie.GetNumber("nutCombineAlpha", 255) * 255), 1)
		self.mult = cookie.GetNumber("nutCombineMult", 0.5)

		self.alpha = self:Add("DAlphaBar")
		self.alpha:Dock(LEFT)
		self.alpha:SetValue(cookie.GetNumber("nutCombineAlpha", 1))
		self.alpha.OnChange = function(this, value)
			self:SetAlpha(math.max(value * 255, 1))
		end

		self.multiplier = self:Add("DAlphaBar")
		self.multiplier:Dock(RIGHT)
		self.multiplier:SetValue(self.mult)
		self.multiplier.OnChange = function(this, value)
			self.mult = value
		end

		self.clear = self:Add("DButton")
		self.clear:Dock(TOP)
		self.clear:SetText("Clear")
		self.clear.DoClick = function()
			SCHEMA.displays = {}
		end

		if (nut.plugin.list.scanner) then
			self.photos = self:Add("DButton")
			self.photos:Dock(TOP)
			self.photos:SetText("View Photos")
			self.photos.DoClick = function()
				RunConsoleCommand("nut_photocache")
			end
		end

		self.oldOnRelease = self.OnMouseReleased

		self.OnMouseReleased = function(this)
			self:oldOnRelease()
			self:saveData()
		end
	end

	function PANEL:PaintOver(w, h)
		surface.SetDrawColor(255, 255, 255, 25)
		surface.DrawLine(0, 24, w, h)
		surface.DrawLine(w, 24, 0, h)
		surface.DrawOutlinedRect(0, 24, w, h - 24)
	end

	function PANEL:saveData()
		cookie.Set("nutCombineX", self.x)
		cookie.Set("nutCombineY", self.y)
		cookie.Set("nutCombineAlpha", self:GetAlpha() / 255)
		cookie.Set("nutCombineMult", self.mult)
	end
vgui.Register("nutCombineDisplay", PANEL, "DFrame")
 
if (IsValid(nut.gui.combine)) then
	vgui.Create("nutCombineDisplay")
end