CLASS.name = "Elite Overwatch Soldier"
CLASS.faction = FACTION_OW
CLASS.model = Model("models/combine_super_soldier.mdl")

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank("EOW")
end

CLASS_OW_ELITE = CLASS.index