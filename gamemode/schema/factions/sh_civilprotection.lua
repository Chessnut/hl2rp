FACTION.name = "Civil Protection"
FACTION.desc = "Enforcers of social stability for the Universal Union"
FACTION.color = Color(85, 127, 242)
FACTION.maleModels = {"models/police.mdl"}
FACTION.femaleModels = {"models/police.mdl"}
FACTION.isDefault = false
FACTION.payTime = 300
FACTION.pay = 30

function FACTION:GetDefaultName(name)
	return (nut.config.cpPrefix or "CP-").."RCT."..nut.util.GetRandomNum(nut.config.cpNumDigits or 5)
end

FACTION_CP = FACTION.index