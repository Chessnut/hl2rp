local PANEL = {}
	function PANEL:Init()
		self:SetSize(340, 420)
		self:SetTitle("Objectives")
		self:MakePopup()
		self:Center()
	end

	function PANEL:SetText(text, noEdit)
		self.text = text
		
		self.scroll = self:Add("DScrollPanel")
		self.scroll:Dock(FILL)

		self.panel = self.scroll:Add("DPanel")
		self.panel:Dock(FILL)
		self.panel.Paint = function(panel, w, h)
			if (!panel.markup or (IsValid(self.scroll.VBar) and self.scroll.VBar:IsVisible() and !self.resized)) then
				panel.markup = nil
				panel.markup = nut.markup.Parse(text, w + 6)
				panel:SetTall(math.max(panel.markup:GetHeight(), panel:GetTall()))

				if (IsValid(self.scroll.VBar) and self.scroll.VBar:IsVisible()) then
					self.resized = true
				end
			end

			panel.markup:Draw(0, 0)
		end

		if (noEdit) then return end

		local canNotEdit = nut.schema.Call("PlayerCanEditObjectives", LocalPlayer()) == false

		self.edit = self:Add("DButton")
		self.edit:Dock(BOTTOM)
		self.edit:DockMargin(0, 4, 0, 0)
		self.edit:SetText("Objectives Editor")
		self.edit:SetDisabled(canNotEdit)
		self.edit.DoClick = function(this)
			if (!canNotEdit) then
				vgui.Create("nut_ObjectivesEditor")
			end
		end
	end
vgui.Register("nut_Objectives", PANEL, "DFrame")

local PANEL = {}
	function PANEL:Init()
		local preview

		self:SetTitle("Objectives Editor")
		self:Center()
		self:SetSize(340, 420)
		self:MakePopup()

		self.content = self:Add("DTextEntry")
		self.content:Dock(FILL)
		self.content:SetMultiline(true)

		if (IsValid(nut.gui.objectives)) then
			self.content:SetText(nut.gui.objectives.text)
		end

		self.buttons = self:Add("DPanel")
		self.buttons:Dock(BOTTOM)
		self.buttons:DockMargin(0, 3, 0, 0)
		self.buttons:SetDrawBackground(false)

		self.save = self.buttons:Add("DButton")
		self.save:Dock(LEFT)
		self.save:SetWide(164)
		self.save:SetText("Save")
		self.save.DoClick = function(this)
			netstream.Start("nut_Objectives", self.content:GetText())

			if (IsValid(nut.gui.objectives)) then
				nut.gui.objectives:Remove()
			end

			if (IsValid(preview)) then
				preview:Remove()
			end

			self:Remove()
		end

		self.preview = self.buttons:Add("DButton")
		self.preview:SetText("Preview")
		self.preview:SetWide(164)
		self.preview:Dock(RIGHT)
		self.preview.DoClick = function(this)
			if (IsValid(preview)) then preview:Remove() end

			preview = vgui.Create("nut_Objectives")
			preview:SetText(self.content:GetText(), true)
			preview:SetTitle("Objectives Preview")
		end
	end
vgui.Register("nut_ObjectivesEditor", PANEL, "DFrame")

netstream.Hook("nut_Objectives", function(data)
	if (IsValid(nut.gui.objectives)) then
		nut.gui.objectives:Remove()
	end

	nut.gui.objectives = vgui.Create("nut_Objectives")
	nut.gui.objectives:SetText(data)
end)