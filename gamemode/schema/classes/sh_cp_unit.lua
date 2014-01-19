CLASS.name = "Civil Protection Unit"
CLASS.faction = FACTION_CP

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank(nut.config.cpUnitRanks)
end

function CLASS:PlayerGetModel(client)
	if (client:IsCombineRank("OfC.")) then
		return nut.config.cpRankModels["OfC"]
	elseif (client:IsCombineRank(nut.config.cpUnitRanks)) then
		return nut.config.cpRankModels[nut.config.cpUnitRanks]
	end
end

CLASS_CP_UNIT = CLASS.index