ITEM.name = "Breen's Water"
ITEM.desc = "Fresh from the private reserve."
ITEM.price = 10
ITEM.model = Model("models/props_junk/popcan01a.mdl")
ITEM.healthRestore = 5
ITEM.stamRestore = 25
ITEM.category = "Consumables"
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