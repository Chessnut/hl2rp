AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Combine Lock"
ENT.Category = "HL2 RP"
ENT.Author = "Chessnut"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true

function ENT:SetupDataTables()
	self:NetworkVar("Bool", 0, "Locked")
	self:NetworkVar("Bool", 1, "Erroring")
end

function ENT:SpawnFunction(client, trace)
	if (!IsValid(trace.Entity) or !trace.Entity:IsDoor()) then
		nut.util.Notify("You need to be aiming at a valid door.", client)

		return
	end

	local entity = ents.Create("nut_cmblock")
	entity:SetPos(trace.HitPos)
	entity:Spawn()
	entity:Activate()

	local angles = trace.HitNormal:Angle()
	local entity2 = trace.Entity

	if (IsValid(entity2) and entity2:IsDoor()) then
		entity:SetDoor(entity2, trace.HitPos, angles)
	end

	return entity
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_lock01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
	end

	function ENT:OnRemove()
		if (IsValid(self.door)) then
			self.door:Fire("unlock")
		end
	end

	function ENT:Use(activator)
		if (self:GetErroring()) then
			return
		end

		if (!activator:IsCombine() and activator:Team() != FACTION_ADMIN) then
			self:Error()

			return
		end

		if (nut.schema.Call("PlayerCanUseLock", activator) != false) then
			self:ToggleLock()
		end
	end

	function ENT:Error()
		self:EmitSound("buttons/combine_button_locked.wav")
		self:SetErroring(true)

		timer.Create("nut_CombineLockErroring"..self:EntIndex(), 1, 2, function()
			if (IsValid(self)) then
				self:SetErroring(false)
			end
		end)
	end

	function ENT:ToggleLock(override)
		if (override != nil) then
			self:SetLocked(override)
		else
			self:SetLocked(!self:GetLocked())
		end

		if (!self:GetLocked()) then
			self:EmitSound("buttons/combine_button7.wav")
			self.door:Fire("unlock")

			for k, v in pairs(self.door:GetDoorPartner()) do
				v:Fire("unlock")
			end
		else
			self:EmitSound("buttons/combine_button2.wav")

			self.door:Fire("close")
			self.door:Fire("lock")

			for k, v in pairs(self.door:GetDoorPartner()) do
				v:Fire("close")
				v:Fire("lock")
			end
		end
	end

	function ENT:SetDoor(door, position, angles, fromSave)
		if (!IsValid(door)) then
			return
		end

		self.door = door
		door.lock = self

		for k, v in pairs(self.door:GetDoorPartner()) do
			v.lock = self
		end

		angles = angles or door:GetAngles()

		if (!fromSave) then
			angles:RotateAroundAxis(angles:Up(), 270)
		end

		local index = door:LookupBone("handle")

		if (index and index > 0) then
			position = door:GetBonePosition(index)
			position = position + angles:Right()*-5 + angles:Forward()*4 + angles:Up()*10
		else
			position = position + angles:Right()*-4.5
		end

		self:SetPos(position)
		self:SetAngles(angles)
		self:SetParent(door)
	end
else
	local glowMaterial = Material("sprites/glow04_noz")
	local color_orange = Color(255, 125, 0)
	local color_green = Color(0, 255, 0)
	local color_red = Color(255, 0, 0)

	function ENT:Draw()
		self:DrawModel()

		local position = self:GetPos() + self:GetUp()*-8.7 + self:GetForward()*-3.85 + self:GetRight()*-6
		local color = self:GetLocked() and color_orange or color_green

		if (self:GetErroring()) then
			color = color_red
		end

		render.SetMaterial(glowMaterial)
		render.DrawSprite(position, 14, 14, color)
	end
end