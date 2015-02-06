ITEM.name = "Ration"
ITEM.desc = "A small package with food, water and a small amount of money."
ITEM.model = "models/weapons/w_package.mdl"
ITEM.functions.Open = {
	icon = "icon16/briefcase.png",
	sound = "physics/body/body_medium_impact_soft1.wav",
	onRun = function(item)
		local position = item.player:getItemDropPos()
		local client = item.player

		timer.Simple(0, function()
			for k, v in pairs(item.items) do
				if (IsValid(client) and client:getChar() and !client:getChar():getInv():add(v)) then
					nut.item.spawn(k, position)
				end
			end
		end)

		client:giveMoney(math.random(item.money[1], item.money[2]))
	end
}
ITEM.items = {"water"}
ITEM.money = {10, 15}