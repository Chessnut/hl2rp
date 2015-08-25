AddCSLuaFile("cl_init.lua")

ENT.Type = "anim"
ENT.PrintName = "Forcefield"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.RenderGroup = RENDERGROUP_BOTH
ENT.PhysgunDisabled = true

local PLUGIN = PLUGIN

function ENT:SpawnFunction(client, trace)
	local angles = (client:GetPos() - trace.HitPos):Angle()
	angles.p = 0
	angles.r = 0
	angles:RotateAroundAxis(angles:Up(), 270)

	local entity = ents.Create("nut_forcefield")
	entity:SetPos(trace.HitPos + Vector(0, 0, 40))
	entity:SetAngles(angles:SnapTo("y", 90))
	entity:Spawn()

	PLUGIN:saveForceFields()

	return entity
end

function ENT:Initialize()
	self:SetModel("models/props_combine/combine_fence01b.mdl")
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	self:PhysicsInit(SOLID_VPHYSICS)

	local data = {}
		data.start = self:GetPos() + self:GetRight()*-16
		data.endpos = self:GetPos() + self:GetRight()*-480
		data.filter = self
	local trace = util.TraceLine(data)

	local angles = self:GetAngles()
	angles:RotateAroundAxis(angles:Up(), 180)

	self.dummy = ents.Create("prop_physics")
	self.dummy:SetModel(self:GetModel())
	self.dummy:SetPos(trace.HitPos)
	self.dummy:SetAngles(angles)
	self.dummy:Spawn()
	self.dummy.PhysgunDisabled = true
	self:DeleteOnRemove(self.dummy)

	local verts = {
		{pos = Vector(0, 0, -25)},
		{pos = Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.dummy:GetPos()) + Vector(0, 0, 150)},
		{pos = self:WorldToLocal(self.dummy:GetPos()) - Vector(0, 0, 25)},
		{pos = Vector(0, 0, -25)},
	}

	self:PhysicsFromMesh(verts)
	self:SetCustomCollisionCheck(true)
	self:EnableCustomCollisions(true)
	self:setNetVar("dummy", self.dummy:EntIndex())

	local physObj = self:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false)
		physObj:Sleep()
	end

	physObj = self.dummy:GetPhysicsObject()

	if (IsValid(physObj)) then
		physObj:EnableMotion(false)
		physObj:Sleep()
	end

	self:SetMoveType(MOVETYPE_NOCLIP)
	self:SetMoveType(MOVETYPE_PUSH)
	self:MakePhysicsObjectAShadow()
	self.mode = 1
end

function ENT:StartTouch(entity)
	if (!self.buzzer) then
		self.buzzer = CreateSound(entity, "ambient/machines/combine_shield_touch_loop1.wav")
		self.buzzer:Play()
		self.buzzer:ChangeVolume(0.8, 0)
	else
		self.buzzer:ChangeVolume(0.8, 0.5)
		self.buzzer:Play()
	end

	self.entities = (self.entities or 0) + 1
end

function ENT:EndTouch(entity)
	self.entities = math.max((self.entities or 0) - 1, 0)

	if (self.buzzer and self.entities == 0) then
		self.buzzer:FadeOut(0.5)
	end
end

function ENT:OnRemove()
	if (self.buzzer) then
		self.buzzer:Stop()
		self.buzzer = nil
	end

	if (!nut.shuttingDown and !self.nutIsSafe) then
		PLUGIN:saveForceFields()
	end
end

local modes = {}
modes[1] = {function(client)
	local character = client:getChar()

	if (character and character:getInv() and !character:getInv():hasItem("cid")) then
		return true
	else
		return false
	end
end, "Only allow with valid CID."}
modes[2] = {function(client)
	return true
end, "Never allow citizens."}
modes[3] = {function(client)
	return false
end, "Allow everything."}

function ENT:Use(activator)
	if ((self.nextUse or 0) < CurTime()) then
		self.nextUse = CurTime() + 1.5
	else
		return
	end

	if (activator:isCombine()) then
		self.mode = (self.mode or 1) + 1

		if (self.mode > #modes) then
			self.mode = 1
		end

		self:EmitSound("buttons/combine_button5.wav", 140, 100 + (self.mode - 1)*15)
		activator:ChatPrint("Changed barrier mode to: "..modes[self.mode][2])

		PLUGIN:saveForceFields()
	else
		self:EmitSound("buttons/combine_button3.wav")
	end
end

hook.Add("ShouldCollide", "nut_Forcefields", function(a, b)
	local client
	local entity

	if (a:IsPlayer()) then
		client = a
		entity = b
	elseif (b:IsPlayer()) then
		client = b
		entity = a
	end

	if (IsValid(entity) and entity:GetClass() == "nut_forcefield") then
		if (IsValid(client)) then
			if (client:isCombine() or client:Team() == FACTION_ADMIN) then
				return false
			end

			return modes[entity.mode or 1][1](client)
		else
			return entity.mode != 4
		end
	end
end)

hook.Add("KeyPress", "nut_ForceUse", function(client, key)
	local data = {}
		data.start = client:GetShootPos()
		data.endpos = data.start + client:GetAimVector()*84
		data.filter = client
	local trace = util.TraceLine(data)
	local entity = trace.Entity

	if (key == IN_USE and IsValid(entity) and entity:GetClass() == "nut_forcefield") then
		entity:Use(client, client, USE_ON, 1)
	end
end)