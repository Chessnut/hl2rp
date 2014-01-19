CLASS.name = "Civil Protection Recruit"
CLASS.faction = FACTION_CP

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank(nut.config.cpRctRanks)
end

CLASS_CP_RCT = CLASS.index