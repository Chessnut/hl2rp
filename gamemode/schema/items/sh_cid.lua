ITEM.name = "Citizen ID Card"
ITEM.model = Model("models/gibs/metal_gib4.mdl")
ITEM.desc = "An ID card with the digits %Digits|00000% assigned to %Name|no one%."
ITEM.faction = {FACTION_CP, FACTION_ADMIN}
ITEM.price = 10

function ITEM:GetDesc(data)
	data = data or {Digits = "00000", Name = "no one"}

	local desc = "An ID card with the digits "..(data.Digits or "00000")..", assigned to "..(data.Name or "no one").."."
	local unixTime = nut.util.GetUTCTime()
	local nextUse = data.NextUse

	if (nextUse and nextUse > unixTime) then
		desc = desc.."\nThis card is allowed one ration in: "..math.max(math.floor((nextUse - unixTime) / 60), 1).." minute(s)."
	else
		desc = desc.."\nThis card is allowed one ration."
	end

	return desc
end