local PANEL = {}
	function PANEL:Init()
		if (IsValid(nut.gui.obj)) then
			nut.gui.obj:Remove()
		end

		nut.gui.obj = self

		self:SetSize(280, 380)
		self:MakePopup()
		self:Center()

		self.text = self:Add("DTextEntry")
		self.text:Dock(FILL)
		self.text:SetMultiline(true)
		self.text:SetDisabled(true)
		self.text:SetEnabled(false)
	end

	function PANEL:setData(text, canEdit)
		self:SetTitle(L"objectives")
		self.text:SetText(text)
		self.oldText = text and text:lower() or nil

		if (canEdit) then
			self.text:SetDisabled(false)
			self.text:SetEnabled(true)
		end
	end

	function PANEL:OnRemove()
		local text = !self.text:GetDisabled() and self.text:GetText():sub(1, 750) or nil

		if (text and text:lower() != self.oldText) then
			netstream.Start("obj", text)
		end
	end
vgui.Register("nutObjective", PANEL, "DFrame")