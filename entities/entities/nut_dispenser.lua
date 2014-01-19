AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Ration Dispenser"
ENT.Author = "Chessnut"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.PhysgunAllowAdmin = true

local COLOR_RED = 1
local COLOR_ORANGE = 2
local COLOR_BLUE = 3
local COLOR_GREEN = 4

local colors = {
	[COLOR_RED] = Color(255, 50, 50),
	[COLOR_ORANGE] = Color(255, 80, 20),
	[COLOR_BLUE] = Color(50, 80, 230),
	[COLOR_GREEN] = Color(50, 240, 50)
}

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "DispColor")
	self:NetworkVar("String", 1, "Text")
	self:NetworkVar("Bool", 0, "Disabled")
end

function ENT:SpawnFunction(client, trace)
	local entity = ents.Create("nut_dispenser")
	entity:SetPos(trace.HitPos)
	entity:SetAngles(trace.HitNormal:Angle())
	entity:Spawn()
	entity:Activate()

	return entity
end

function ENT:Initialize()
	if (SERVER) then
		self:SetModel("models/props_junk/gascan001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		self:SetText("INSERT ID")
		self:DrawShadow(false)
		self:SetDispColor(COLOR_GREEN)
		self.canUse = true

		-- Use prop_dynamic so we can use entity:Fire("SetAnimation")
		self.dummy = ents.Create("prop_dynamic")
		self.dummy:SetModel("models/props_combine/combine_dispenser.mdl")
		self.dummy:SetPos(self:GetPos())
		self.dummy:SetAngles(self:GetAngles())
		self.dummy:SetParent(self)
		self.dummy:Spawn()
		self.dummy:Activate()

		self:DeleteOnRemove(self.dummy)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end
	end
end

if (CLIENT) then
	function ENT:Draw()
		local position, angles = self:GetPos(), self:GetAngles()

		angles:RotateAroundAxis(angles:Forward(), 90)
		angles:RotateAroundAxis(angles:Right(), 270)

		cam.Start3D2D(position + self:GetForward()*7.6 + self:GetRight()*8.5 + self:GetUp()*3, angles, 0.1)
			render.PushFilterMin(TEXFILTER.NONE)
			render.PushFilterMag(TEXFILTER.NONE)

			surface.SetDrawColor(40, 40, 40)
			surface.DrawRect(0, 0, 66, 60)

			draw.SimpleText((self:GetDisabled() and "OFFLINE" or (self:GetText() or "")), "Default", 33, 0, Color(255, 255, 255, math.abs(math.cos(RealTime() * 1.5) * 255)), 1, 0)

			surface.SetDrawColor(colors[self:GetDisabled() and COLOR_RED or self:GetDispColor()] or color_white)
			surface.DrawRect(4, 14, 58, 42)

			surface.SetDrawColor(60, 60, 60)
			surface.DrawOutlinedRect(4, 14, 58, 42)

			render.PopFilterMin()
			render.PopFilterMag()
		cam.End3D2D()
	end
else
	function ENT:SetUseAllowed(state)
		self.canUse = state
	end

	function ENT:Error(text)
		self:EmitSound("buttons/combine_button_locked.wav")
		self:SetText(text)
		self:SetDispColor(COLOR_RED)

		timer.Create("nut_DispenserError"..self:EntIndex(), 1.5, 1, function()
			if (IsValid(self)) then
				self:SetText("INSERT ID")
				self:SetDispColor(COLOR_GREEN)

				timer.Simple(0.5, function()
					if (!IsValid(self)) then return end

					self:SetUseAllowed(true)
				end)
			end
		end)
	end

	function ENT:CreateRation()
		local entity = ents.Create("prop_physics")
		entity:SetAngles(self:GetAngles())
		entity:SetModel("models/weapons/w_package.mdl")
		entity:SetPos(self:GetPos())
		entity:Spawn()
		entity:SetNotSolid(true)
		entity:SetParent(self.dummy)
		entity:Fire("SetParentAttachment", "package_attachment")

		timer.Simple(1.2, function()
			if (IsValid(self) and IsValid(entity)) then
				entity:Remove()
				nut.item.Spawn(entity:GetPos(), entity:GetAngles(), "ration")
			end
		end)
	end

	function ENT:Dispense()
		self:SetText("DISPENSING")
		self:EmitSound("ambient/machines/combine_terminal_idle4.wav")
		self:CreateRation()
		self.dummy:Fire("SetAnimation", "dispense_package", 0)

		timer.Simple(3.5, function()
			if (IsValid(self)) then
				self:SetText("ARMING")
				self:SetDispColor(COLOR_ORANGE)
				self:EmitSound("buttons/combine_button7.wav")

				timer.Simple(7, function()
					if (!IsValid(self)) then return end

					self:SetText("INSERT ID")
					self:SetDispColor(COLOR_GREEN)
					self:EmitSound("buttons/combine_button1.wav")

					timer.Simple(0.75, function()
						if (!IsValid(self)) then return end

						self:SetUseAllowed(true)
					end)
				end)
			end
		end)
	end

	function ENT:Use(activator)
		if ((self.nextUse or 0) >= CurTime()) then
			return
		end

		if (activator:Team() == FACTION_CITIZEN) then
			if (!self.canUse or self:GetDisabled()) then
				return
			end

			self:SetUseAllowed(false)
			self:SetText("CHECKING")
			self:SetDispColor(COLOR_BLUE)
			self:EmitSound("ambient/machines/combine_terminal_idle2.wav")

			timer.Simple(1, function()
				if (!IsValid(self) or !IsValid(activator)) then return self:SetUseAllowed(true) end

				local itemTable = activator:GetItem("cid")

				if (!itemTable) then
					return self:Error("INVALID ID")
				else
					if ((itemTable.data and itemTable.data.NextUse or 0) >= nut.util.GetUTCTime()) then
						return self:Error("TRY LATER")
					end

					self:SetText("ID OKAY")
					self:EmitSound("buttons/button14.wav", 100, 50)

					timer.Simple(1, function()
						if (!IsValid(self) or !IsValid(activator)) then return self:SetUseAllowed(true) end
						local itemTable = activator:GetItem("cid")

						if (itemTable) then
							itemTable.data = itemTable.data or {}
							itemTable.data.NextUse = nut.util.GetUTCTime() + (nut.config.rationTime or 1800)
							activator.character:Send("inv")
							
							self:Dispense()
						else
							self:Error("ERROR")
						end
					end)
				end
			end)
		elseif (activator:IsCombine()) then
			self:SetDisabled(!self:GetDisabled())
			self:EmitSound(self:GetDisabled() and "buttons/combine_button1.wav" or "buttons/combine_button2.wav")
			self.nextUse = CurTime() + 1
		end
	end
end