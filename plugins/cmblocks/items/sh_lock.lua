ITEM.name = "Combine Lock"
ITEM.desc = "A metallic lock that is placed on doors."
ITEM.price = 250
ITEM.model = "models/props_combine/combine_lock01.mdl"
ITEM.category = "Combine"
ITEM.factions = {FACTION_CP, FACTION_OW}
ITEM.functions.Place = {
	onRun = function(item)
		local data = {}
		data.start = item.player:GetShootPos()
		data.endpos = data.start + item.player:GetAimVector()*128
		data.filter = item.player
		
		if (IsValid(scripted_ents.Get("nut_cmblock"):SpawnFunction(item.player, util.TraceLine(data)))) then
			item.player:EmitSound("npc/roller/mine/rmine_blades_out3.wav", 100, 90)
		else
			return false
		end
	end
}