FACTION.name = "fCopName"
FACTION.desc = "fCopDesc"
FACTION.color = Color(25, 30, 180)
FACTION.isDefault = false
--FACTION.limit = 0.25
FACTION.models = {
	"models/police.mdl"
}
FACTION.weapons = {"nut_stunstick"}
FACTION.pay = 25
FACTION.isGloballyRecognized = true

function FACTION:onGetDefaultName(client, digits)
	if (SCHEMA.digitsLen >= 1) then
		digits = digits or math.random(
			tonumber("1"..string.rep("0", SCHEMA.digitsLen-1)),
			tonumber(string.rep("9", SCHEMA.digitsLen))
		)

		local name = SCHEMA.cpPrefix
			..table.GetFirstValue(SCHEMA.rctRanks)
			.."."
			..digits
		return name, true
	else
		return SCHEMA.cpPrefix..table.GetFirstValue(SCHEMA.rctRanks), true
	end
end

function FACTION:onTransfered(client, oldFaction)
	local digits

	if (oldFaction.index == FACTION_CITIZEN) then
		local inventory = client:getChar():getInv()
		if (inventory) then
			for _, item in pairs(inventory:getItems()) do
				if (item.uniqueID == "cid" and item:getData("id")) then
					digits = item:getData("id")
					break
				end
			end
		end
	elseif (oldFaction.index == FACTION_OW) then
		digits = client:getDigits()
	elseif (oldFaction.index == FACTION_CP) then
		return
	end

	client:getChar():setName(self:onGetDefaultName(client, digits))
	hook.Run("PlayerLoadout", client)
end

FACTION_CP = FACTION.index
