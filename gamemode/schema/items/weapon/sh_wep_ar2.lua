ITEM.name = "Overwatch Standard Issue Pulse Rifle"
ITEM.uniqueID = "weapon_ar2"
ITEM.category = "Weapons"
ITEM.model = Model("models/weapons/w_irifle.mdl")
ITEM.class = "weapon_ar2"
ITEM.type = "primary"
ITEM.price = 750
ITEM.desc = "A sleek black weapon that has a large banana shaped magazine attached to the side of the rifle.\nThere are %ClipOne|0% shots left in the magazine.\n<:: triggerQuery: REQUIRE SIGNAL = %CombineLocked|0% ::> "
ITEM.data = {
	Equipped = false,
	CombineLocked = 1,
	ClipOne = 30
}