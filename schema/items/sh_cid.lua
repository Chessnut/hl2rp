ITEM.name = "Citizen ID"
ITEM.desc = "A flat piece of plastic for identification."
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.factions = {FACTION_CP, FACTION_ADMIN}
ITEM.functions.Assign = {
	onRun = function(item)
		local data = {}
			data.start = item.player:EyePos()
			data.endpos = data.start + item.player:GetAimVector()*96
			data.filter = item.player
		local entity = util.TraceLine(data).Entity

		if (IsValid(entity) and entity:IsPlayer() and entity:Team() == FACTION_CITIZEN) then
			local status, result = item:transfer(entity:getChar():getInv():getID())

			if (status) then
				item:setData("name", entity:Name())
				item:setData("id", math.random(10000, 99999))
				
				return true
			else
				item.player:notify(result)
			end
		end

		return false
	end,
	onCanRun = function(item)
		return item.player:isCombine()
	end
}

function ITEM:getDesc()
	local description = self.desc.."\nThis has been assigned to "..self:getData("name", "no one")..", #"..self:getData("id", "00000").."."

	if (self:getData("cwu")) then
		description = description.."\nThis card has a priority status stamp."
	end

	return description
end