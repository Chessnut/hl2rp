ITEM.name = "Bleach"
ITEM.desc = "Cleaning solution often used for disinfecting surfaces."
ITEM.price = 25
ITEM.model = "models/props_junk/garbage_plasticbottle001a.mdl"
ITEM.category = "Other"
ITEM.functions.Drink = {
	sound = "npc/barnacle/barnacle_gulp2.wav",
	onRun = function(item)
		local client = item.player
		timer.Create("nutBleach"..item:getID(), 5, 1, function()
			client:Kill()
		end)
	end
}
ITEM.permit = "misc"