CLASS.name = "Prison Guard Soldier"
CLASS.faction = FACTION_OW
CLASS.model = Model("models/combine_soldier_prisonguard.mdl")
CLASS.skin = 0

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank("PGS")
end

CLASS_OW_PGS = CLASS.index