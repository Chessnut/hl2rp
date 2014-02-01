CLASS.name = "Civil Protection Elite"
CLASS.faction = FACTION_CP

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank(nut.config.cpEliteRanks)
end

function CLASS:PlayerGetModel(client)
	for k, v in ipairs(nut.config.cpRankModels) do
		print(v[1], v[2])
		print(client:IsCombineRank(v[1]))
		if (client:IsCombineRank(v[1])) then
			print("==>", v[2])
			return v[2]
		end
	end
end

CLASS_CP_ELITE = CLASS.index