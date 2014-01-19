CLASS.name = "Civil Protection Scanner"
CLASS.faction = FACTION_CP
CLASS.model = Model("models/combine_scanner.mdl")

function CLASS:PlayerCanJoin(client)
	return client:IsCombineRank(nut.config.scannerRanks)
end

function CLASS:OnSet(client)
	timer.Simple(0.2, function()
		SCHEMA:CreatePlayerScanner(client, string.find(client:Name(), "CLAW.") and "npc_clawscanner")
	end)
end

function CLASS:OnSpawn(client)
	timer.Simple(0.2, function()
		SCHEMA:CreatePlayerScanner(client, string.find(client:Name(), "CLAW.") and "npc_clawscanner")
	end)
end

CLASS_CP_SCN = CLASS.index