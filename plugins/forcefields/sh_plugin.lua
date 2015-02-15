local PLUGIN = PLUGIN

PLUGIN.name = "Forcefields"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds force fields which can be placed around the map."

function PLUGIN:saveForceFields()
	local buffer = {}

	for k, v in pairs(ents.FindByClass("nut_forcefield")) do
		buffer[#buffer + 1] = {pos = v:GetPos(), ang = v:GetAngles(), mode = v.mode or 1}
	end

	self:setData(buffer)
end

function PLUGIN:LoadData()
	local buffer = self:getData() or {}

	for k, v in ipairs(buffer) do
		local entity = ents.Create("nut_forcefield")
		entity:SetPos(v.pos)
		entity:SetAngles(v.ang)
		entity:Spawn()
		entity.mode = v.mode or 1
	end
end