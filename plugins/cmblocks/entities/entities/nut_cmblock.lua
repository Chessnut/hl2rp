AddCSLuaFile()

local PLUGIN = PLUGIN

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
	self:NetworkVar("Bool", 2, "Detonating")
end

function ENT:SpawnFunction(client, trace)
	local door = trace.Entity

	if (!IsValid(door) or !door:isDoor() or IsValid(door.lock)) then
		return client:notifyLocalized("dNotValid")
	end

	local position, angles = self:getLockPos(client, door)

	local entity = ents.Create("nut_cmblock")
	entity:SetPos(trace.HitPos)
	entity:Spawn()
	entity:Activate()
	entity:setDoor(door, position, angles)

	PLUGIN:SaveData()

	return entity
end

if (SERVER) then
	function ENT:Initialize()
		self:SetModel("models/props_combine/combine_lock01.mdl")
		self:SetSolid(SOLID_VPHYSICS)
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		self:SetUseType(SIMPLE_USE)
		self.onDoorRestored = function(self, door)
			self:toggle(false)
		end
	end

	function ENT:OnRemove()
		if (IsValid(self.door)) then
			self.door:Fire("unlock")
		end

		if (!nut.shuttingDown) then
			PLUGIN:SaveData()
		end
	end

	function ENT:Use(activator)
		if (self:GetErroring()) then
			return
		end

		if ((activator.nutNextLockUse or 0) < CurTime()) then
			activator.nutNextLockUse = CurTime() + 1
		else
			return
		end

		if (!activator:isCombine() and activator:Team() != FACTION_ADMIN) then
			self:error()

			return
		end

		if (activator:KeyDown(IN_WALK)) then
			self:detonate(activator)
		elseif (hook.Run("PlayerCanUseLock", activator) != false) then
			self:toggle()
		end
	end

	function ENT:error()
		self:EmitSound("buttons/combine_button_locked.wav")
		self:SetErroring(true)

		timer.Create("nut_CombineLockErroring"..self:EntIndex(), 1, 2, function()
			if (IsValid(self)) then
				self:SetErroring(false)
			end
		end)
	end

	function ENT:toggle(override)
		if (override != nil) then
			self:SetLocked(override)
		elseif ((self.nextToggle or 0) < CurTime()) then
			self.nextToggle = CurTime() + 1
			self:SetLocked(!self:GetLocked())
		else
			return
		end

		local partner = self.door:getDoorPartner()

		if (!self:GetLocked()) then
			self:EmitSound("buttons/combine_button7.wav")
			self.door:Fire("unlock")

			if (IsValid(partner)) then
				partner:Fire("unlock")
			end
		else
			self:EmitSound("buttons/combine_button2.wav")

			self.door:Fire("close")
			self.door:Fire("lock")

			if (IsValid(partner)) then
				partner:Fire("close")
				partner:Fire("lock")
			end
		end
	end

	function ENT:getLockPos(client, door)
		local index, index2 = door:LookupBone("handle")
		local normal = client:GetEyeTrace().HitNormal:Angle()
		local position = client:GetEyeTrace().HitPos

		if (index and index >= 1) then
			position = door:GetBonePosition(index)
		end

		position = position + normal:Forward()*7 + normal:Up()*10
		
		normal:RotateAroundAxis(normal:Up(), 90)
		normal:RotateAroundAxis(normal:Forward(), 180)
		normal:RotateAroundAxis(normal:Right(), 180)
		
		return position, normal
	end

	function ENT:setDoor(door, position, angles)
		if (!IsValid(door)) then
			return
		end

		self.door = door
		door.lock = self

		self:SetPos(position)
		self:SetAngles(angles)
		self:SetParent(door)
	end

	function ENT:detonate(client)
		self:SetDetonating(true)
		self.detonateStartTime = CurTime()
		self.detonateEndTime = self.detonateStartTime + 10
		self.explodeDir = client:GetAimVector() * 500
	end

	function ENT:ping()
		self:SetErroring(true)
		self:EmitSound("npc/turret_floor/ping.wav")

		timer.Create("nutPing"..self:EntIndex(), 0.1, 1, function()
			if (IsValid(self)) then
				self:SetErroring(false)
			end
		end)
	end

	function ENT:Think()
		if (not self:GetDetonating()) then return end
		local curTime = CurTime()

		if (self.detonateEndTime <= curTime) then
			self:explode()
			return
		end

		if ((self.nextPing or 0) >= curTime) then
			return
		end

		local fraction = 1 - math.Clamp(math.TimeFraction(
			self.detonateStartTime,
			self.detonateEndTime,
			curTime
		), 0, 1)
		self.nextPing = curTime + fraction
		self:ping()
	end

	function ENT:explode()
		local effect = EffectData()
			effect:SetOrigin(self:GetPos())
		util.Effect("Explosion", effect)

		local entity = self:GetParent()
		if (not IsValid(entity)) then return end

		entity:EmitSound("physics/wood/wood_crate_break"..math.random(1, 5)..".wav", 150)
		local direction = (self.explodeDir or VectorRand()):GetNormalized()
		direction.z = 0
		entity:blastDoor(direction * 400)

		self:Remove()
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
		local size = 14

		if (self:GetErroring()) then
			color = color_red
			size = 28
		elseif (self:GetDetonating()) then
			return
		end

		render.SetMaterial(glowMaterial)
		render.DrawSprite(position, size, size, color)
	end
end
