ITEM.name = "Overwatch RPG"
ITEM.uniqueID = "weapon_rpg"
ITEM.category = "Weapons"
ITEM.model = Model("models/weapons/w_rocket_launcher.mdl")
ITEM.class = "weapon_rpg"
ITEM.type = "primary"
ITEM.price = 850
ITEM.flag = "V"
ITEM.desc = "A large black tube containing a lot of firepower.\nThere are %ClipOne|0% rockets left in the tube.\n<:: triggerQuery: REQUIRE SIGNAL = %CombineLocked|0% ::> "
ITEM.data = {
	Equipped = false,
	CombineLocked = 1,
	ClipOne = 1
}