ENT.Type = "anim"
ENT.PrintName = "Note"
ENT.Author = "Black Tea"
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.Category = "NutScript"
ENT.RenderGroup 		= RENDERGROUP_BOTH
if (SERVER) then
	function ENT:Initialize()
	end

	function ENT:OnRemove()
	end

	function ENT:Use(activator)
		if (self.id and WRITINGDATA[self.id]) then
			netstream.Start(activator, "receiveNote", self.id, WRITINGDATA[self.id], self:canWrite(activator))
		end
	end
else
	ENT.DrawEntityInfo = true
	
	function ENT:onShouldDrawEntityInfo()
		return true
	end

	function ENT:onDrawEntityInfo(alpha)
		local position = self:LocalToWorld(self:OBBCenter()):ToScreen()
		local x, y = position.x, position.y - 10
		
		nut.util.drawText("Note", x, y, ColorAlpha(nut.config.get("color"), alpha), 1, 1, nil, alpha * 0.65)
		nut.util.drawText("It seems something is written on.", x, y + 16, ColorAlpha(color_white, alpha), 1, 1, "nutSmallFont", alpha * 0.65)
	end

	function ENT:Draw()
		self:DrawModel()
	end
end

function ENT:getOwner()
	return self:getNetVar("ownerChar")
end

function ENT:canWrite(client)
	if (client) then
		return (client:IsAdmin() or client:getChar().id == self:getOwner())
	end
end