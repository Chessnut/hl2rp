FACTION.name = "fCopName"
FACTION.desc = "fCopDesc"
FACTION.color = Color(25, 30, 180)
FACTION.isDefault = false
FACTION.models = {
	"models/police.mdl"
}
FACTION.weapons = {"nut_stunstick"}
FACTION.pay = 25

function FACTION:onGetDefaultName(client)
	return SCHEMA.cpPrefix..table.GetFirstValue(SCHEMA.rctRanks).."."..math.random(10000, 99999), true
end

FACTION_CP = FACTION.index