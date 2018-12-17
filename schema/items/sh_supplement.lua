ITEM.name = "Food Supplement"
ITEM.desc = "A jar of gray substance, packed with a third of a day's nutrients."
ITEM.model = "models/props_lab/jar01b.mdl"
ITEM.healthRestore = 25
ITEM.restore = 75
ITEM.category = "consumables"
ITEM.price = 30
ITEM.functions.Use = {
	sound = "items/battery_pickup.wav",
	onRun = function(item)
		item.player:SetHealth(math.min(item.player:Health() + item.restore, 100))
		item.player:setLocalVar("stm", math.min(item.player:getLocalVar("stm", 100) + item.restore, 100))
	end
}
ITEM.permit = "food"