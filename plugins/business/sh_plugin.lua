PLUGIN.name = "Business Permits"
PLUGIN.desc = "Adds business permits which are needed to purchase certain goods."
PLUGIN.author = "Chessnut"

function PLUGIN:CanPlayerUseBusiness(client, uniqueID)
	local itemTable = nut.item.list[uniqueID]

	if (itemTable and itemTable.permit) then
		if (!client:getChar():getInv():hasItem("permit_"..itemTable.permit)) then
			return false
		end
	end
end