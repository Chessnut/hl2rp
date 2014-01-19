local PLUGIN = PLUGIN
local PANEL = {}
	function PANEL:Init()
		local width = ScrW() * nut.config.menuWidth

		self:SetSize(width, ScrH() * nut.config.menuHeight)
		self:MakePopup()
		self:SetTitle("Unknown")
		self:Center()

		self.list = self:Add("DScrollPanel")
		self.list:Dock(LEFT)
		self.list:SetWide(width / 2 - 7)
		self.list:SetDrawBackground(true)

		self.searchTitle = self.list:Add("DLabel")
		self.searchTitle:SetText("Storage")
		self.searchTitle:DockMargin(3, 3, 3, 3)
		self.searchTitle:Dock(TOP)
		self.searchTitle:SetTextColor(Color(60, 60, 60))
		self.searchTitle:SetFont("nut_ScoreTeamFont")
		self.searchTitle:SizeToContents()

		self.weight = self.list:Add("DPanel")
		self.weight:Dock(TOP)
		self.weight:SetTall(18)
		self.weight:DockMargin(3, 3, 3, 4)
		self.weight.Paint = function(panel, w, h)
			local width = self.weightValue or 0
			local color = nut.config.mainColor

			surface.SetDrawColor(color.r, color.g, color.b, 200)
			surface.DrawRect(0, 0, w * width, h)

			surface.SetDrawColor(255, 255, 255, 20)
			surface.DrawRect(0, 0, w * width, h * 0.4)

			surface.SetDrawColor(25, 25, 25, 170)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		self.inv = self:Add("DScrollPanel")
		self.inv:Dock(RIGHT)
		self.inv:SetWide(width / 2 - 7)
		self.inv:SetDrawBackground(true)

		self.invTitle = self.inv:Add("DLabel")
		self.invTitle:SetText(nut.lang.Get("inventory"))
		self.invTitle:DockMargin(3, 3, 3, 3)
		self.invTitle:Dock(TOP)
		self.invTitle:SetTextColor(Color(60, 60, 60))
		self.invTitle:SetFont("nut_ScoreTeamFont")
		self.invTitle:SizeToContents()

		self.weight2 = self.inv:Add("DPanel")
		self.weight2:Dock(TOP)
		self.weight2:SetTall(18)
		self.weight2:DockMargin(3, 3, 3, 4)
		self.weight2.Paint = function(panel, w, h)
			local width = self.weightValue2 or 0
			local color = nut.config.mainColor

			surface.SetDrawColor(color.r, color.g, color.b, 200)
			surface.DrawRect(0, 0, w * width, h)

			surface.SetDrawColor(255, 255, 255, 20)
			surface.DrawRect(0, 0, w * width, h * 0.4)

			surface.SetDrawColor(25, 25, 25, 170)
			surface.DrawOutlinedRect(0, 0, w, h)
		end

		local transfer

		self.money2 = self.inv:Add("DTextEntry")
		self.money2:DockMargin(3, 3, 3, 3)
		self.money2:Dock(TOP)
		self.money2:SetNumeric(true)
		self.money2:SetText(LocalPlayer():GetMoney())
		self.money2.OnEnter = function(panel)
			transfer:DoClick()
		end

		transfer = self.money2:Add("DButton")
		transfer:Dock(RIGHT)
		transfer:SetText("Transfer")
		transfer.DoClick = function(panel)
			local value = tonumber(self.money2:GetText()) or 0

			if (value and value <= LocalPlayer():GetMoney() and value > 0) then
				netstream.Start("nut_SearchTransferMoney", math.abs(value))
			else
				self.money2:SetText(LocalPlayer():GetMoney())
			end
		end

		self.categories = {}
		self.invCategories = {}
	end

	function PANEL:GetPlayer()
		return self.client
	end

	function PANEL:Think()
		if (self.clientSet and !IsValid(self.client) or self.client:GetPos():Distance(LocalPlayer():GetPos()) > 128 or PLUGIN:CanPlayerSearch(LocalPlayer(), self.client) == false) then
			netstream.Start("nut_SearchEnd")
			self:Remove()
		end
	end

	function PANEL:SetPlayer(client)
		self.client = client
		self.clientSet =true
		self:SetupInv() 

		local weight, maxWeight = client:GetInvWeight(client:GetNetVar("inv", {}))
		self.weightValue = weight / maxWeight

		self:SetTitle("Search")
		self.searchTitle:SetText(client:Name())

		self.weightText = self.weight:Add("DLabel")
		self.weightText:Dock(FILL)
		self.weightText:SetDark(true)
		self.weightText:SetContentAlignment(5)
		self.weightText:SetText(math.ceil(self.weightValue * 100).."%")

		local transfer

		self.money = self.list:Add("DTextEntry")
		self.money:DockMargin(3, 3, 3, 3)
		self.money:Dock(TOP)
		self.money:SetNumeric(true)
		self.money:SetText(client:GetNetVar("money", 0))
		self.money.OnEnter = function(panel)
			transfer:DoClick()
		end

		transfer = self.money:Add("DButton")
		transfer:Dock(RIGHT)
		transfer:SetText("Transfer")
		transfer.DoClick = function(panel)
			local value = tonumber(self.money:GetText()) or 0

			if (value and value <= client:GetNetVar("money", 0) and value > 0) then
				netstream.Start("nut_SearchTransferMoney", -math.abs(value))
			else
				self.money:SetText(client:GetNetVar("money", 0))
			end
		end

		local inventory = client:GetNetVar("inv")

		if (inventory) then
			for class, items in pairs(inventory) do
				local itemTable = nut.item.Get(class)

				if (itemTable) then
					local category = itemTable.category
					local category2 = string.lower(category)

					if (!self.categories[category2]) then
						local category3 = self.list:Add("DCollapsibleCategory")
						category3:Dock(TOP)
						category3:SetLabel(category)
						category3:DockMargin(5, 5, 5, 5)
						category3:SetPadding(5)

						local list = vgui.Create("DIconLayout")
							list.Paint = function(list, w, h)
								surface.SetDrawColor(0, 0, 0, 25)
								surface.DrawRect(0, 0, w, h)
							end
						category3:SetContents(list)
						category3:InvalidateLayout(true)

						self.categories[category2] = {list = list, category = category3, panel = panel}
					end

					local list = self.categories[category2].list

					for k, v in SortedPairs(items) do
						local icon = list:Add("SpawnIcon")
						icon:SetModel(itemTable.model or "models/error.mdl", itemTable.skin)
						icon.PaintOver = function(icon, w, h)
							surface.SetDrawColor(0, 0, 0, 45)
							surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

							if (itemTable.PaintIcon) then
								itemTable.data = v.data
									itemTable:PaintIcon(w, h)
								itemTable.data = nil
							end
						end

						local label = icon:Add("DLabel")
						label:SetPos(8, 3)
						label:SetWide(64)
						label:SetText(v.quantity)
						label:SetFont("DermaDefaultBold")
						label:SetDark(true)
						label:SetExpensiveShadow(1, Color(240, 240, 240))

						icon:SetToolTip(nut.lang.Get("item_info", itemTable.name, itemTable:GetDesc(v.data)))
						icon.DoClick = function(icon)
							netstream.Start("nut_SearchUpdate", {class, -1, v.data})
						end
					end
				end
			end
		end
	end

	function PANEL:OnClose()
		netstream.Start("nut_SearchEnd")
	end

	function PANEL:SetupInv()
		local weight, maxWeight = LocalPlayer():GetInvWeight()
		self.weightValue2 = weight / maxWeight

		self.weightText2 = self.weight2:Add("DLabel")
		self.weightText2:Dock(FILL)
		self.weightText2:SetDark(true)
		self.weightText2:SetContentAlignment(5)
		self.weightText2:SetText(math.ceil(self.weightValue2 * 100).."%")

		for class, items in pairs(LocalPlayer():GetInventory()) do
			local itemTable = nut.item.Get(class)

			if (itemTable) then
				local category = itemTable.category
				local category2 = string.lower(category)

				if (!self.invCategories[category2]) then
					local category3 = self.inv:Add("DCollapsibleCategory")
					category3:Dock(TOP)
					category3:SetLabel(category)
					category3:DockMargin(5, 5, 5, 5)
					category3:SetPadding(5)

					local list = vgui.Create("DIconLayout")
						list.Paint = function(list, w, h)
							surface.SetDrawColor(0, 0, 0, 25)
							surface.DrawRect(0, 0, w, h)
						end
					category3:SetContents(list)
					category3:InvalidateLayout(true)

					self.invCategories[category2] = {list = list, category = category3, panel = panel}
				end

				local list = self.invCategories[category2].list

				for k, v in SortedPairs(items) do
					local icon = list:Add("SpawnIcon")
					icon:SetModel(itemTable.model or "models/error.mdl", itemTable.skin)
					icon.PaintOver = function(icon, w, h)
						surface.SetDrawColor(0, 0, 0, 45)
						surface.DrawOutlinedRect(1, 1, w - 2, h - 2)

						if (itemTable.PaintIcon) then
							itemTable.data = v.data
								itemTable:PaintIcon(w, h)
							itemTable.data = nil
						end
					end
					
					local label = icon:Add("DLabel")
					label:SetPos(8, 3)
					label:SetWide(64)
					label:SetText(v.quantity)
					label:SetFont("DermaDefaultBold")
					label:SetDark(true)
					label:SetExpensiveShadow(1, Color(240, 240, 240))

					icon:SetToolTip(nut.lang.Get("item_info", itemTable.name, itemTable:GetDesc(v.data)))
					icon.DoClick = function(icon)
						if (itemTable.CanTransfer and itemTable:CanTransfer(LocalPlayer(), v.data) == false) then
							return false
						end
						
						netstream.Start("nut_SearchUpdate", {class, 1, v.data})
					end
				end
			end
		end
	end

	function PANEL:Reload()
		local parent = self:GetParent()
		local client = self:GetPlayer()
		local x, y = self:GetPos()

		self:Remove()

		nut.gui.search = vgui.Create("nut_Search", parent)
		nut.gui.search:SetPos(x, y)

		if (IsValid(client)) then
			nut.gui.search:SetPlayer(client)
		end
	end
vgui.Register("nut_Search", PANEL, "DFrame")