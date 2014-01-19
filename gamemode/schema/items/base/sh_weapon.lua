BASE.name = "Base Weapon"
BASE.uniqueID = "base_wep"
BASE.category = "Weapons"
BASE.class = "weapon_crowbar"
BASE.type = "melee"
BASE.price = 50
BASE.flag = "v"
BASE.data = {
	Equipped = false,
	CombineLocked = 0,
	ClipOne = 0
}

BASE.functions = {}
BASE.functions.Equip = {
	run = function(itemTable, client, data)
		if (SERVER) then
			if (client:HasWeapon(itemTable.class)) then
				nut.util.Notify("You already has this weapon equipped.", client)

				return false
			end
			
			if (data.CombineLocked == 1) then
				
				if (!client:IsCombine()) then
				
				nut.util.Notify("You cannot use any biolocked weapons.", client)
				return false
				
				end
				
			end

			if (nut.config.noMultipleWepSlots and IsValid(client:GetNutVar(itemTable.type))) then
				nut.util.Notify("You already have a weapon in the "..itemTable.type.." slot.", client)

				return false
			end
			

			
			local weapon = client:Give(itemTable.class)


			if (IsValid(weapon)) then
				client:SetNutVar(itemTable.type, weapon)
				client:SelectWeapon(itemTable.class)
			end

			local newData = table.Copy(data)
			
			local clipOne = data.ClipOne
			
			if (clipOne > 0) then
				weapon:SetClip1(clipOne)
				newData.ClipOne = 0
			
			else
			
				weapon:SetClip1(0)
				newData.ClipOne = 0
			
			end
			
			newData.Equipped = true

			client:UpdateInv(itemTable.uniqueID, 1, newData)
		end
	end,
	shouldDisplay = function(itemTable, data, entity)
		return !data.Equipped or data.Equipped == nil
	end
}

BASE.functions.DisableBiolock = {
	text = "Disable Biolock",
	run = function(itemTable, client, data)
		if (SERVER) then
			if (!client:HasFlag("R")) then
				nut.util.Notify("You do not have the necessary supplies to do this!", client)

				return false
			end
			
			local newData = table.Copy(data)
			
			newData.CombineLocked = 0

			client:UpdateInv(itemTable.uniqueID, 1, newData)
			nut.util.Notify("You have succesfully nulled the biolock!", client)
		end
	end,
	shouldDisplay = function(itemTable, data, entity) -- should prolly change this to if they have the flag, jus saying.
		return data.CombineLocked == 1
	end
}

BASE.functions.Unequip = {
	run = function(itemTable, client, data)
		if (SERVER) then
			if (client:HasWeapon(itemTable.class)) then
				shotsLeft = client:GetActiveWeapon():Clip1()
				client:SetNutVar(itemTable.type, nil)
				client:StripWeapon(itemTable.class)
			end

			local newData = table.Copy(data)
			newData.Equipped = false
			
			newData.ClipOne = shotsLeft

			client:UpdateInv(itemTable.uniqueID, 1, newData)

			return true
		end
	end,
	shouldDisplay = function(itemTable, data, entity)
		return data.Equipped == true
	end
}

local size = 16
local border = 4
local distance = size + border
local tick = Material("icon16/tick.png")

function BASE:PaintIcon(w, h)

	if (self.data.Equipped) then
		surface.SetDrawColor(0, 0, 0, 50)
		surface.DrawRect(w - distance - 1, w - distance - 1, size + 2, size + 2)

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(tick)
		surface.DrawTexturedRect(w - distance, w - distance, size, size)
	end
	
end

function BASE:CanTransfer(client, data)
	if (data.Equipped) then
		nut.util.Notify("You must unequip the item before doing that.", client)
	end

	return !data.Equipped
end

if (SERVER) then
	hook.Add("PlayerSpawn", "nut_WeaponBase", function(client)
		timer.Simple(0.1, function()
			if (!IsValid(client) or !client.character) then
				return
			end

			for class, items in pairs(client:GetInventory()) do
				local itemTable = nut.item.Get(class)

				if (itemTable and itemTable.class) then
					for k, v in pairs(items) do
						if (v.data.Equipped) then
							client:Give(itemTable.class)
						end
					end
				end
			end
		end)
	end)
end
