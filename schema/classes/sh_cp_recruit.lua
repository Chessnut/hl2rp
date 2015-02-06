CLASS.name = "Civil Protection Recruit"
CLASS.desc = "The bottom of the Civil Protection."
CLASS.faction = FACTION_CP

function CLASS:onCanBe(client)
	return client:isCombineRank(SCHEMA.rctRanks)
end

CLASS_CP_RCT = CLASS.index