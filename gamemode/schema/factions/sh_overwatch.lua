FACTION.name = "Combine Overwatch"
FACTION.desc = "The transhuman soldiers of the Universal Union."
FACTION.color = Color(181, 110, 60)
FACTION.maleModels = {"models/combine_soldier.mdl"}
FACTION.femaleModels = {"models/combine_soldier.mdl"}
FACTION.isDefault = false

function FACTION:GetDefaultName(name)
	return (nut.config.owPrefix or "CP-").."OWS."..nut.util.GetRandomNum(nut.config.owNumDigits or 5)
end

FACTION_OW = FACTION.index