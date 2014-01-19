CLASS.name = "Overwatch Soldier"
CLASS.faction = FACTION_OW
CLASS.model = Model("models/combine_soldier.mdl")

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank("OWS")
end

CLASS_OW_UNIT = CLASS.index