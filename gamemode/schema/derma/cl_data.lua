local PANEL = {}
	function PANEL:Init()
		self:SetSize(340, 420)
		self:SetTitle("Unknown")
		self:MakePopup()
		self:Center()

		self.content = self:Add("DTextEntry")
		self.content:Dock(FILL)
		self.content:SetMultiline(true)

		self.save = self:Add("DButton")
		self.save:Dock(BOTTOM)
		self.save:DockMargin(0, 4, 0, 0)
		self.save:SetText("Update Data")
		self.save.DoClick = function(this)
			if (IsValid(self.player)) then
				netstream.Start("nut_Data", {self.player, self.content:GetText()})
			else
				self:Remove()
			end
		end
	end

	function PANEL:Setup(client, data, title)
		self.player = client
		self:SetTitle(title)
		self.content:SetText(data)
	end
vgui.Register("nut_Data", PANEL, "DFrame")

netstream.Hook("nut_Data", function(data)
	if (!IsValid(data[1])) then
		return
	end

	nut.gui.data = vgui.Create("nut_Data")
	nut.gui.data:Setup(data[1], data[2], data[3])
end)