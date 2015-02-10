ITEM.name = "Zip Tie"
ITEM.desc = "An orange zip-tie used to restrict players."
ITEM.price = 50
ITEM.model = "models/items/crossbowrounds.mdl"
ITEM.functions.Use = {
	onRun = function(item)
		if (item.beingUsed) then
			return false
		end

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local target = util.TraceLine(data).Entity

		if (IsValid(target) and target:IsPlayer() and target:getChar() and !target:getNetVar("tied")) then
			item.beingUsed = true

			client:EmitSound("physics/plastic/plastic_barrel_strain"..math.random(1, 3)..".wav")
			client:setAction("@tying", 5)
			client:doStaredAction(target, function()
				item:remove()
				target:setNetVar("tied", 1)
				client:EmitSound("npc/barnacle/neck_snap1.wav", 100, 140)
			end, 5, function()
				client:setAction()
				target:setAction()
				target:setNetVar("tied")

				item.beingUsed = false
			end)

			target:setNetVar("tied", 0)
			target:setAction("@beingTied", 5)
		else
			item.player:notifyLocalized("plyNotValid")
		end

		return false
	end,
	onCanRun = function(item)
		return !IsValid(item.entity)
	end
}

function ITEM:onCanBeTransfered(inventory, newInventory)
	return !self.beingUsed
end