ITEM.name = "Citizen ID"
ITEM.desc = "A flat piece of plastic for identification."
ITEM.model = "models/gibs/metal_gib4.mdl"
ITEM.price = 50
ITEM.factions = {FACTION_CP, FACTION_ADMIN}
ITEM.functions.Assign = {
	onRun = function(item)
		local client = item.player

		local data = {}
			data.start = client:EyePos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local entity = util.TraceLine(data).Entity

		if (IsValid(entity) and entity:IsPlayer() and entity:Team() == FACTION_CITIZEN) then
			if (not entity:getChar() or not entity:getChar():getInv()) then
				client:notifyLocalized("plyNotValid")
				return false
			end

			local name, id = entity:Name(), math.random(10000, 99999)
			local function onSuccess(newCID)
				newCID:setData("name", name)
				newCID:setData("id", id)
			end

			local position = client:getItemDropPos()
			local function onFail(err)
				print(err)
				nut.item.spawn(item.uniqueID, position, onSuccess)
			end

			local x, y, itemID = entity:getChar():getInv():add(item.uniqueID)

			-- New add method returns a promise (x) that resolves to the item.
			if (nut.version) then
				x:next(onSuccess):catch(onFail)
				return true
			end

			-- Old call returns false if adding failed, otherwise it
			-- returns the (x, y) coordinates and item ID.
			if (x == false) then
				onFail()
			else
				onSuccess(nut.item.instances[itemID])
			end
			return true
		end

		client:notifyLocalized("plyNotValid")
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