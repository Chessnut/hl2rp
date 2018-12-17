ITEM.name = "Ration"
ITEM.desc = "A small package with food, water and a small amount of money."
ITEM.model = "models/weapons/w_package.mdl"
ITEM.width = 2
ITEM.height = 2
ITEM.exRender = true
ITEM.iconCam = {
	pos = Vector(4, -6, 200),
	ang = Angle(90, 0, 0),
	fov = 6,
}
ITEM.price = 25
ITEM.width = 1
ITEM.height = 1
ITEM.functions.Open = {
	icon = "icon16/briefcase.png",
	sound = "physics/body/body_medium_impact_soft1.wav",
	onRun = function(item)
		local position = item.player:getItemDropPos()
		local client = item.player

		timer.Simple(0, function()
			for k, v in pairs(item.items) do
				if (
					IsValid(client) and
					client:getChar() and
					not client:getChar():getInv():add(v)
				) then
					nut.item.spawn(v, position)
				end
			end
		end)

		client:getChar():giveMoney(math.random(item.money[1], item.money[2]))
	end
}
ITEM.items = {"water", "supplement"}
ITEM.money = {10, 15}
ITEM.factions = FACTION_CP