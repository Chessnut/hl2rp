ITEM.name = "Citizen ID"
ITEM.desc = "A flat piece of plastic for identification."
ITEM.model = "models/gibs/metal_gib4.mdl"

function ITEM:getDesc()
	local description = self.desc.."\nThis has been assigned to "..self:getData("name", "no one")..", #"..self:getData("id", "00000").."."

	if (self:getData("cwu")) then
		description = description.."\nThis card has a priority status stamp."
	end

	return description
end