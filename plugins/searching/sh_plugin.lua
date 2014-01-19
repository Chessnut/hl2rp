PLUGIN.name = "Searching"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds the ability to search other players."

nut.util.Include("cl_search.lua")

function PLUGIN:CanPlayerSearch(client, target)
	return client:GetNetVar("tied") != true and target:GetNetVar("tied") == true
end

if (SERVER) then
	function PLUGIN:PlayerSearch(client, target)
		if (!self:CanPlayerSearch(client, target)) then
			return nut.util.Notify(nut.lang.Get("no_perm", client:Name()), client)
		end

		target:SetNetVar("inv", target:GetInventory(), client)
		target:SetNetVar("money", target:GetMoney(), client)

		client:SetNutVar("searchTarget", target)
		netstream.Start(client, "nut_PlayerSearch", target)
	end

	local PLUGIN = PLUGIN

	netstream.Hook("nut_SearchUpdate", function(client, data)
		local target = client:GetNutVar("searchTarget")

		if (IsValid(target) and client:GetPos():Distance(target:GetPos()) <= 128 and PLUGIN:CanPlayerSearch(client, target)) then
			local uniqueID = data[1]
			local quantity = data[2]
			local itemData = data[3]
			local itemTable = nut.item.Get(uniqueID)

			if (!itemTable) then
				return
			end

			if (quantity > 0) then
				local item = client:GetItem(uniqueID, nil, itemData)

				if (!item or !target:HasInvSpace(itemTable, 1) or (itemTable.CanTransfer and itemTable:CanTransfer(target, itemData) == false)) then
					return
				end

				client:UpdateInv(uniqueID, -1, itemData)
				target:UpdateInv(uniqueID, 1, itemData)

				target:SetNetVar("inv", target:GetInventory(), client)
				netstream.Start(client, "nut_PlayerSearchRefresh")
			else
				local item = target:GetItem(uniqueID, nil, itemData)

				if (!item or !client:HasInvSpace(itemTable, 1) or (itemTable.CanTransfer and itemTable:CanTransfer(client, itemData) == false)) then
					return
				end

				client:UpdateInv(uniqueID, 1, itemData)
				target:UpdateInv(uniqueID, -1, itemData)

				target:SetNetVar("inv", target:GetInventory(), client)
				netstream.Start(client, "nut_PlayerSearchRefresh")
			end
		elseif (IsValid(client)) then
			client:SetNutVar("searchTarget", nil)
			netstream.Start(client, "nut_SearchEnd")
		end
	end)

	netstream.Hook("nut_SearchEnd", function(client)
		client:SetNutVar("searchTarget", nil)
	end)

	netstream.Hook("nut_SearchTransferMoney", function(client, amount)
		print(client, amount)
		local target = client:GetNutVar("searchTarget")

		if (type(amount) == "number" and amount != 0 and IsValid(target) and client:GetPos():Distance(target:GetPos()) <= 128 and PLUGIN:CanPlayerSearch(client, target)) then
			local amount2 = math.abs(math.Round(amount))

			if (amount > 0) then
				client:TakeMoney(amount2)
				target:GiveMoney(amount2)
			elseif (amount < 0) then
				client:GiveMoney(amount2)
				target:TakeMoney(amount2)
			end

			target:SetNetVar("money", target:GetMoney(), client)
			netstream.Start(client, "nut_PlayerSearchRefresh")
		elseif (IsValid(client)) then
			client:SetNutVar("searchTarget", nil)
			netstream.Start(client, "nut_SearchEnd")
		end
	end)
else
	netstream.Hook("nut_PlayerSearch", function(target)
		if (IsValid(target) and target.character) then
			if (IsValid(nut.gui.search)) then
				nut.gui.search:Remove()
			end

			local search = vgui.Create("nut_Search")
				search:SetPlayer(target)
			nut.gui.search = search
		end
	end)

	netstream.Hook("nut_PlayerSearchRefresh", function()
		if (IsValid(nut.gui.search)) then
			nut.gui.search:Reload()
		end
	end)

	netstream.Hook("nut_SearchEnd", function()
		nut.gui.search:Remove()
	end)
end

local PLUGIN = PLUGIN

nut.command.Register({
	onRun = function(client, arguments)
		if (client:GetNutVar("searchTarget")) then
			return nut.util.Notify("You are already searching another player!", client)
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)
		local target = trace.Entity

		if (IsValid(target)) then
			PLUGIN:PlayerSearch(client, target)
		else
			nut.util.Notify(nut.lang.Get("no_ply"), client)
		end
	end
}, "charsearch")