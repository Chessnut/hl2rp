ITEM.name = "Sparkling Water"
ITEM.desc = "A blue can of plain water."
ITEM.model = "models/props_junk/popcan01a.mdl"
ITEM.healthRestore = 15
ITEM.restore = 67
ITEM.category = "consumables"
ITEM.skin = 2
ITEM.functions.Drink = {
	icon = "icon16/cup.png",
	sound = "items/battery_pickup.wav",
	onRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + item.restore, 100))
		item.player:setLocalVar("stm", math.min(item.player:getLocalVar("stm", 100) + item.restore, 100))
	end
}
ITEM.permit = "food"