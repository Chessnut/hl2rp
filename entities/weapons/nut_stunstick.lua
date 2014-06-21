AddCSLuaFile()

if (CLIENT) then
	SWEP.PrintName = "Stunstick"
	SWEP.Slot = 1
	SWEP.SlotPos = 2
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = false
end

SWEP.Author = "Chessnut"
SWEP.Instructions = "Primary Fire: [RAISED] Strike\nALT + Primary Fire: [RAISED] Toggle stun\nSecondary Fire: Push/Knock"
SWEP.Purpose = "Hitting things and knocking on doors."
SWEP.Drop = false

SWEP.HoldType = "melee"

SWEP.ViewModelFOV = 47
SWEP.ViewModelFlip = false
SWEP.AnimPrefix	 = "melee"

SWEP.ViewTranslation = 4

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""
SWEP.Primary.Damage = 7.5
SWEP.Primary.Delay = 0.7

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

SWEP.ViewModel = Model("models/weapons/c_stunstick.mdl")
SWEP.WorldModel = Model("models/weapons/w_stunbaton.mdl")

SWEP.UseHands = true
SWEP.LowerAngles = Angle(15, -10, -20)

SWEP.FireWhenLowered = true

function SWEP:SetupDataTables()
	self:NetworkVar("Bool", 0, "Activated")
end

function SWEP:Precache()
	util.PrecacheSound("weapons/stunstick/stunstick_swing1.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_swing2.wav")
	util.PrecacheSound("weapons/stunstick/stunstick_impact1.wav")	
	util.PrecacheSound("weapons/stunstick/stunstick_impact2.wav")
	util.PrecacheSound("weapons/stunstick/spark1.wav")
	util.PrecacheSound("weapons/stunstick/spark2.wav")
	util.PrecacheSound("weapons/stunstick/spark3.wav")
end

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()	
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if (!self.Owner:WepRaised()) then
		return
	end

	if (self.Owner:KeyDown(IN_WALK)) then
		if (SERVER) then
			self:SetActivated(!self:GetActivated())

			local sequence = "deactivatebaton"

			if (self:GetActivated()) then
				self.Owner:EmitSound("weapons/stunstick/spark3.wav", 100, math.random(90, 110))
				sequence = "activatebaton"
			else
				self.Owner:EmitSound("weapons/stunstick/spark"..math.random(1, 2)..".wav", 100, math.random(90, 110))
			end

			local model = string.lower(self.Owner:GetModel())
			
			if (nut.anim.GetClass(model) == "metrocop") then
				self.Owner:SetOverrideSeq(sequence)
			end
		end

		return
	end

	self:EmitSound("weapons/stunstick/stunstick_swing"..math.random(1, 2)..".wav")
	self:SendWeaponAnim(ACT_VM_HITCENTER)

	local damage = self.Primary.Damage

	if (self:GetActivated()) then
		damage = damage + 15
	end

	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(1, 0, 0.125))

	self.Owner:LagCompensation(true)
		local data = {}
			data.start = self.Owner:GetShootPos()
			data.endpos = data.start + self.Owner:GetAimVector()*72
			data.filter = self.Owner
		local trace = util.TraceLine(data)
	self.Owner:LagCompensation(false)

	if (SERVER and trace.Hit) then
		if (self:GetActivated()) then
			local effect = EffectData()
				effect:SetStart(trace.HitPos)
				effect:SetNormal(trace.HitNormal)
				effect:SetOrigin(trace.HitPos)
			util.Effect("StunstickImpact", effect, true, true)
		end

		self.Owner:EmitSound("weapons/stunstick/stunstick_impact"..math.random(1, 2)..".wav")

		local entity = trace.Entity

		if (IsValid(entity)) then
			if (entity:IsPlayer()) then
				if (self:GetActivated()) then
					entity:ScreenFadeOut(15, color_white)
				else
					entity:ScreenFadeOut(1, Color(128, 0, 0, 200))
				end

				entity:ViewPunch(Angle(-20, math.random(-15, 15), math.random(-10, 10)))

				if (self:GetActivated() and entity:Health() - damage <= 0) then
					entity:SetTimedRagdoll(60, true)
					entity:SetHealth(50)

					return
				end
			elseif (entity:IsRagdoll()) then
				if (self:GetActivated()) then
					damage = 2
				else
					damage = 20
				end
			end

			local damageInfo = DamageInfo()
				damageInfo:SetAttacker(self.Owner)
				damageInfo:SetInflictor(self)
				damageInfo:SetDamage(damage)
				damageInfo:SetDamageType(DMG_CLUB)
				damageInfo:SetDamagePosition(trace.HitPos)
				damageInfo:SetDamageForce(self.Owner:GetAimVector()*10000)
			entity:DispatchTraceAttack(damageInfo, data.start, data.endpos)
		end
	end
end

function SWEP:OnLowered()
	self:SetActivated(false)
end

function SWEP:SecondaryAttack()
	self.Owner:LagCompensation(true)
		local data = {}
			data.start = self.Owner:GetShootPos()
			data.endpos = data.start + self.Owner:GetAimVector()*72
			data.filter = self.Owner
			data.mins = Vector(-8, -8, -30)
			data.maxs = Vector(8, 8, 10)
		local trace = util.TraceHull(data)
		local entity = trace.Entity
	self.Owner:LagCompensation(false)

	if (SERVER and IsValid(entity)) then
		local pushed

		if (entity:IsDoor()) then
			if (nut.schema.Call("PlayerCanKnock", self.Owner, entity) == false) then
				return
			end

			self.Owner:ViewPunch( Angle(-1.3, 1.8, 0) )
			self.Owner:EmitSound("physics/plastic/plastic_box_impact_hard"..math.random(1, 4)..".wav")	
			self.Owner:SetAnimation(PLAYER_ATTACK1)

			self:SetNextSecondaryFire(CurTime() + 0.4)
			self:SetNextPrimaryFire(CurTime() + 1)
		elseif (entity:IsPlayer()) then
			local direction = self.Owner:GetAimVector() * (300 + (self.Owner:GetAttrib(ATTRIB_STR, 0) * 3))
			direction.z = 0

			entity:SetVelocity(direction)

			pushed = true
		else
			local physObj = entity:GetPhysicsObject()

			if (IsValid(physObj)) then
				physObj:SetVelocity(self.Owner:GetAimVector() * 180)
			end

			pushed = true
		end

		if (pushed) then
			self:SetNextSecondaryFire(CurTime() + 1.5)
			self:SetNextPrimaryFire(CurTime() + 1.5)
			self.Owner:EmitSound("weapons/crossbow/hitbod"..math.random(1, 2)..".wav")

			local model = string.lower(self.Owner:GetModel())

			if (nut.anim.GetClass(model) == "metrocop") then
				self.Owner:SetOverrideSeq("pushplayer", nil, function()
					self.Owner:Freeze(true)
				end, function()
					if (IsValid(self)) then
						self.Owner:Freeze(false)
					end
				end)
			end
		end
	end
end

local STUNSTICK_GLOW_MATERIAL = Material("effects/stunstick")
local STUNSTICK_GLOW_MATERIAL2 = Material("effects/blueflare1")
local STUNSTICK_GLOW_MATERIAL_NOZ = Material("sprites/light_glow02_add_noz")

local color_glow = Color(128, 128, 128)

function SWEP:DrawWorldModel()
	self:DrawModel()

	if (self:GetActivated()) then
		local size = math.Rand(4.0, 6.0)
		local glow = math.Rand(0.6, 0.8) * 255
		local color = Color(glow, glow, glow)
		local attachment = self:GetAttachment(1)

		if (attachment) then
			local position = attachment.Pos

			render.SetMaterial(STUNSTICK_GLOW_MATERIAL2)
			render.DrawSprite(position, size * 2, size * 2, color)

			render.SetMaterial(STUNSTICK_GLOW_MATERIAL)
			render.DrawSprite(position, size, size + 3, color_glow)
		end
	end
end

local NUM_BEAM_ATTACHEMENTS = 9
local BEAM_ATTACH_CORE_NAME	= "sparkrear"

function SWEP:ViewModelDrawn()
	if (!self:GetActivated()) then
		return
	end

	local viewModel = LocalPlayer():GetViewModel()

	if (!IsValid(viewModel)) then
		return
	end

	cam.Start3D(EyePos(), EyeAngles())
		local size = math.Rand(3.0, 4.0)
		local color = Color(255, 255, 255, 100 + math.sin(RealTime() * 2)*20)

		STUNSTICK_GLOW_MATERIAL_NOZ:SetFloat("$alpha", color.a / 255)

		render.SetMaterial(STUNSTICK_GLOW_MATERIAL_NOZ)

		local attachment = viewModel:GetAttachment(viewModel:LookupAttachment(BEAM_ATTACH_CORE_NAME))

		if (attachment) then
			render.DrawSprite(attachment.Pos, size * 10, size * 15, color)
		end

		for i = 1, NUM_BEAM_ATTACHEMENTS do
			local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark"..i.."a"))

			size = math.Rand(2.5, 5.0)

			if (attachment and attachment.Pos) then
				render.DrawSprite(attachment.Pos, size, size, color)
			end

			local attachment = viewModel:GetAttachment(viewModel:LookupAttachment("spark"..i.."b"))

			size = math.Rand(2.5, 5.0)

			if (attachment and attachment.Pos) then
				render.DrawSprite(attachment.Pos, size, size, color)
			end
		end
	cam.End3D()
end
