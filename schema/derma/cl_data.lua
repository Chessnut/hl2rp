local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.data)) then
			nut.gui.data:Remove()
		end

		nut.gui.data = self

		self:SetSize(280, 380)
		self:MakePopup()
		self:Center()

		self.text = self:Add("DTextEntry")
		self.text:Dock(FILL)
		self.text:SetMultiline(true)
		self.text:SetDisabled(true)
		self.text:SetEnabled(false)
	end

	function PANEL:setData(text, title, canEdit)
		self:SetTitle(title)
		self.text:SetText(text or SCHEMA.defaultData)
		self.oldText = text and text:lower() or nil

		if (canEdit) then
			self.text:SetDisabled(false)
			self.text:SetEnabled(true)
		end
	end

	function PANEL:OnRemove()
		local text = !self.text:GetDisabled() and self.text:GetText():sub(1, 750) or nil

		if (text and text:lower() == self.oldText) then
			text = nil
		end

		netstream.Start("dataCls", text)
	end
vgui.Register("nutData", PANEL, "DFrame")