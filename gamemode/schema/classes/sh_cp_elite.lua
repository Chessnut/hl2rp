CLASS.name = "Civil Protection Elite"
CLASS.faction = FACTION_CP

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank(nut.config.cpEliteRanks)
end

function CLASS:PlayerGetModel(client)
	if (client:IsCombineRank("EpU.")) then
		return nut.config.cpRankModels["EpU"]
	elseif (client:IsCombineRank("DvL.")) then
		return nut.config.cpRankModels["DvL"]
	elseif (client:IsCombineRank("SeC.")) then
		return nut.config.cpRankModels["SeC"]
	end
end

CLASS_CP_ELITE = CLASS.index