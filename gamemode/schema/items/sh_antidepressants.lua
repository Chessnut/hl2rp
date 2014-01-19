ITEM.name = "Anti-Depressants"
ITEM.desc = "A pill that makes the world a better place."
ITEM.model = Model("models/props_junk/garbage_metalcan001a.mdl")
ITEM.functions = {}
ITEM.price = 15
ITEM.functions.Use = {
	text = "Swallow",
	run = function(item)
		if (CLIENT) then
			item.player:EmitSound("music/stingers/industrial_suspense1.wav", 60)
		else
			local client = item.player

			client:SetNetVar("noDepress", client:GetNetVar("noDepress", 0) - 0.5)
			client:SetNetVar("blur", 0.95)

			timer.Simple(8, function()
				if (IsValid(client)) then
					client:SetNetVar("blur", 0)
					client:SetNetVar("noDepress", client:GetNetVar("noDepress", 0) + 1)
				end
			end)

			timer.Simple(128, function()
				if (IsValid(client)) then
					client:SetNetVar("noDepress", client:GetNetVar("noDepress", 0.5) - 0.5)
				end
			end)
		end
	end
}