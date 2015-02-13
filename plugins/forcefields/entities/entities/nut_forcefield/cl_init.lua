ENT.Type = "anim"
ENT.PrintName = "Forcefield"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true

local material = Material("effects/combineshield/comshieldwall3")

function ENT:Initialize()
	local data = {}
		data.start = self:GetPos() + self:GetRight()*-16
		data.endpos = self:GetPos() + self:GetRight()*-480
		data.filter = self
	local trace = util.TraceLine(data)

	self:EnableCustomCollisions(true)
	self:PhysicsInitConvex({
		vector_origin,
		Vector(0, 0, 150),
		trace.HitPos + Vector(0, 0, 150),
		trace.HitPos
	})
end

function ENT:Draw()
	self:DrawModel()

	local angles = self:GetAngles()
	local matrix = Matrix()
	matrix:Translate(self:GetPos() + self:GetUp()*-40)
	matrix:Rotate(angles)

	render.SetMaterial(material)

	local dummy = Entity(self:getNetVar("dummy", 0))

	if (IsValid(dummy)) then
		local vertex = self:WorldToLocal(dummy:GetPos())
		self:SetRenderBounds(vector_origin, vertex + self:GetUp()*150)

		cam.PushModelMatrix(matrix)
			self:DrawShield(vertex)
		cam.PopModelMatrix()

		matrix:Translate(vertex)
		matrix:Rotate(Angle(0, 180, 0))

		cam.PushModelMatrix(matrix)
			self:DrawShield(vertex)
		cam.PopModelMatrix()
	end
end

function ENT:DrawShield(vertex)
	mesh.Begin(MATERIAL_QUADS, 1)
		mesh.Position(vector_origin)
		mesh.TexCoord(0, 0, 0)
		mesh.AdvanceVertex()

		mesh.Position(self:GetUp()*190)
		mesh.TexCoord(0, 0, 3)
		mesh.AdvanceVertex()

		mesh.Position(vertex + self:GetUp()*190)
		mesh.TexCoord(0, 3, 3)
		mesh.AdvanceVertex()

		mesh.Position(vertex)
		mesh.TexCoord(0, 3, 0)
		mesh.AdvanceVertex()
	mesh.End()
end