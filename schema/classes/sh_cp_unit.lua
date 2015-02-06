CLASS.name = "Civil Protection Unit"
CLASS.desc = "A regular Civil Protection ground unit."
CLASS.faction = FACTION_CP

function CLASS:onCanBe(client)
	return client:isCombineRank(SCHEMA.unitRanks)
end

CLASS_CP_UNIT = CLASS.index