ITEM.name = "Large Food Supplement"
ITEM.desc = "A jar of gray substance, packed with a lot of nutrients."
ITEM.model = "models/props_lab/jar01a.mdl"
ITEM.healthRestore = 50
ITEM.restore = 100
ITEM.category = "consumables"
ITEM.price = 40
ITEM.functions.Use = {
	icon = "icon16/cup.png",
	sound = "items/battery_pickup.wav",
	onRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + item.restore, 100))
		item.player:setLocalVar("stm", math.min(item.player:getLocalVar("stm", 100) + item.restore, 100))
	end
}
ITEM.permit = "food"