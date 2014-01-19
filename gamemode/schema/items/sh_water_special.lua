ITEM.name = "Special Breen's Water"
ITEM.desc = "A special edition of Breen's Water, noted by the red can."
ITEM.price = 20
ITEM.skin = 1
ITEM.model = Model("models/props_junk/popcan01a.mdl")
ITEM.healthRestore = 15
ITEM.category = "Consumables"
ITEM.stamRestore = 50
ITEM.functions = {}
ITEM.functions.Use = {
	text = "Drink",
	run = function(itemTable, client, data)
		if (CLIENT) then return end

		local stamina = client.character:GetVar("stamina", 100) 

		if (stamina >= 100) then
			nut.util.Notify("You do not need to consume this right now.", client)

			return false
		end

		client.character:SetVar("stamina", stamina + itemTable.stamRestore)
		client:SetHealth(math.min(client:Health() + itemTable.healthRestore, 100))
		client:EmitSound("items/battery_pickup.wav")
	end
}