CLASS.name = "Civil Protection Elite"
CLASS.desc = "The top officers of the Civil Protection."
CLASS.faction = FACTION_CP

function CLASS:onCanBe(client)
	return client:isCombineRank(SCHEMA.eliteRanks)
end

CLASS_CP_ELITE = CLASS.index