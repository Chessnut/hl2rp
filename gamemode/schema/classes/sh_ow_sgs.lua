CLASS.name = "Shotgunner Soldier"
CLASS.faction = FACTION_OW
CLASS.model = Model("models/combine_soldier.mdl")
CLASS.skin = 1

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank("SGS")
end

CLASS_OW_SGS = CLASS.index