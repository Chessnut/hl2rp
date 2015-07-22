local PLUGIN = PLUGIN

if (SERVER) then
	function PLUGIN:searchPlayer(client, target)
		if (IsValid(target:getNetVar("searcher")) or IsValid(client.nutSearchTarget)) then
			return false
		end

		if (!target:getChar() or !target:getChar():getInv()) then
			return false
		end

		local inventory = target:getChar():getInv()

		-- Permit the player to move items from their inventory to the target's inventory.
		inventory.oldOnAuthorizeTransfer = inventory.onAuthorizeTransfer
		inventory.onAuthorizeTransfer = function(inventory, client2, oldInventory, item)
			if (IsValid(client2) and client2 == client) then
				return true
			end

			return false
		end
		inventory:sync(client)
		inventory.oldGetReceiver = inventory.getReceiver
		inventory.getReceiver = function(inventory)
			return {client, target}
		end
		inventory.onCheckAccess = function(inventory, client2)
			if (client2 == client) then
				return true
			end
		end

		-- Permit the player to move items from the target's inventory back into their inventory.
		local inventory2 = client:getChar():getInv()
		inventory2.oldOnAuthorizeTransfer = inventory2.onAuthorizeTransfer
		inventory2.onAuthorizeTransfer = function(inventory3, client2, oldInventory, item)
			if (oldInventory == inventory) then
				return true
			end

			return inventory2.oldOnAuthorizeTransfer(inventory3, client2, oldInventory, item)
		end

		-- Show the inventory menu to the searcher.
		netstream.Start(client, "searchPly", target, target:getChar():getInv():getID())

		client.nutSearchTarget = target
		target:setNetVar("searcher", client)

		return true
	end

	function PLUGIN:CanPlayerInteractItem(client, action, item)
		if (IsValid(client:getNetVar("searcher"))) then
			return false
		end
	end

	netstream.Hook("searchExit", function(client)
		local target = client.nutSearchTarget

		if (IsValid(target) and target:getNetVar("searcher") == client) then
			local inventory = target:getChar():getInv()
			inventory.onAuthorizeTransfer = inventory.oldOnAuthorizeTransfer
			inventory.oldOnAuthorizeTransfer = nil
			inventory.getReceiver = inventory.oldGetReceiver
			inventory.oldGetReceiver = nil
			inventory.onCheckAccess = nil
				
			local inventory2 = client:getChar():getInv()
			inventory2.onAuthorizeTransfer = inventory2.oldOnAuthorizeTransfer
			inventory2.oldOnAuthorizeTransfer = nil

			target:setNetVar("searcher", nil)
			client.nutSearchTarget = nil
		end
	end)
else
	function PLUGIN:CanPlayerViewInventory()
		if (IsValid(LocalPlayer():getNetVar("searcher"))) then
			return false
		end
	end

	netstream.Hook("searchPly", function(target, index)
		local inventory = nut.item.inventories[index]

		if (!inventory) then
			return netstream.Start("searchExit")
		end

		nut.gui.inv1 = vgui.Create("nutInventory")
		nut.gui.inv1:ShowCloseButton(true)
		nut.gui.inv1:setInventory(LocalPlayer():getChar():getInv())

		local panel = vgui.Create("nutInventory")
		panel:ShowCloseButton(true)
		panel:SetTitle(target:Name())
		panel:setInventory(inventory)
		panel:MoveLeftOf(nut.gui.inv1, 4)
		panel.OnClose = function(this)
			if (IsValid(nut.gui.inv1) and !IsValid(nut.gui.menu)) then
				nut.gui.inv1:Remove()
			end

			netstream.Start("searchExit")
		end

		local oldClose = nut.gui.inv1.OnClose
		nut.gui.inv1.OnClose = function()
			if (IsValid(panel) and !IsValid(nut.gui.menu)) then
				panel:Remove()
			end

			netstream.Start("searchExit")
			nut.gui.inv1.OnClose = oldClose
		end

		nut.gui["inv"..index] = panel	
	end)
end

nut.command.add("charsearch", {
	onRun = function(client, arguments)
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:getNetVar("restricted")) then
			PLUGIN:searchPlayer(client, target)
		end
	end
})