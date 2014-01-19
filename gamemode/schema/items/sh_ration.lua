ITEM.name = "Combine Ration"
ITEM.desc = "A package containing food and water."
ITEM.model = Model("models/weapons/w_package.mdl")
ITEM.functions = {}
ITEM.functions.Open = {
	run = function(itemTable, client, data)
		if (CLIENT) then return end

		local odds = math.random(1, 100)

		if (odds >= 80) then
			client:UpdateInv("water_special", 1, nil, true)
		elseif (odds >= 60) then
			client:UpdateInv("water_sparkling", 1, nil, true)
		else
			client:UpdateInv("water", 1, nil, true)
		end

		client:UpdateInv("food_supplement_small", 1, nil, true)
		client:GiveMoney(math.random(10, 30))
		client:EmitSound("physics/flesh/flesh_impact_hard"..math.random(1, 5)..".wav")
	end,
	icon = "icon16/arrow_out.png"
}