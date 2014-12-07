ITEM.name = "Casual Cloth"
ITEM.desc = "A Casual Cloth for the male."
ITEM.model = "models/props_c17/BriefCase001a.mdl"
ITEM.sheet = {1, 15} -- sheetdata [1]<male> index [2]<fancy>
ITEM.width = 1
ITEM.height = 2
ITEM.isCloth = true

ITEM.functions.EquipUn = { -- sorry, for name order.
	name = "Unequip",
	tip = "equipTip",
	icon = "icon16/world.png",
	onRun = function(item)
		local mdl = string.lower(item.player:GetModel())
		local mdldat = RESKINDATA[mdl]

		if (!mdl) then
			item.player:notify"This model is not supported (no mdltexcoord)"
			return false
		end

		item.player:SetSubMaterial(mdldat[1] - 1, "")
		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", false)
		
		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") == true)
	end
}

ITEM.functions.Equip = {
	name = "Equip",
	tip = "equipTip",
	icon = "icon16/world.png",
	onRun = function(item)
	print(1)
		local inv = item.player:getChar():getInv()

		for k, v in pairs(inv.slots) do
			for k2, v2 in pairs(v) do
				if (v2.id != item.id) then
					local itemTable = nut.item.instances[v2.id]

					if (itemTable.isCloth and itemTable:getData("equip")) then
						item.player:notify("You're already wearing cloth")

						return false
					end
				end
			end
		end

		local mdl = string.lower(item.player:GetModel())
		local mdldat = RESKINDATA[mdl]

		if (!mdl) then
			item.player:notify("This model is not supported (no mdltexcoord)")
			
			return false
		end

		if (mdldat.sheets == item.sheet[1]) then
			local sheet = CITIZENSHEETS[item.sheet[1]][item.sheet[2]]

			if (!sheet) then
				item.player:notify("Incorrect Sheetdata")
				return false
			end

			item.player:SetSubMaterial(mdldat[1] - 1, sheet)
		else
			item.player:notify("This model is not supported (sheetdata)")

			return false
		end

		item.player:EmitSound("items/ammo_pickup.wav", 80)
		item:setData("equip", true)

		return false
	end,
	onCanRun = function(item)
		return (!IsValid(item.entity) and item:getData("equip") != true)
	end
}

ITEM.functions.Preview = {
	tip = "previewTip",
	icon = "icon16/world.png",
	onRun = function(item)
		netstream.Start(item.player, "nutCitizenPreview", item.sheet)
		return false
	end,
}