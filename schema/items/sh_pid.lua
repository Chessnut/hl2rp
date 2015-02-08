ITEM.name = "Citizen ID"
ITEM.desc = "A flat piece of plastic for identification."
ITEM.model = "models/gibs/metal_gib4.mdl"

function ITEM:getDesc()
	return self.desc.."\nThis has been assigned to "..self:getData("name", "no one")..", #"..self:getData("id", "00000").."."
end