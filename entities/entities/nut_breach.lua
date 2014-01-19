AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "C4"
ENT.Author = "Johnny Guitar"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.Category = "NutScript"

function ENT:SetupDataTables()

	self:DTVar( "Float", 0, "detTime" );

end

if (SERVER) then

	function ENT:Initialize()
	
		self:SetModel("models/props_wasteland/prison_padlock001a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetMoveType(MOVETYPE_VPHYSICS)
		self:SetUseType(SIMPLE_USE)
		
		local physicsObject = self:GetPhysicsObject()

		if (IsValid(physicsObject)) then
			physicsObject:Wake()
		end

		self:SetDTFloat(0, 10)
		self:blowDoor()

	end

	function ENT:Use(activator)
	
		if (activator:IsPlayer()) then
		
			self:drillIntoVault()

		end
		
	end

	function ENT:Explode()

		local effectData = EffectData()
		effectData:SetStart(self:GetPos())
		effectData:SetOrigin(self:GetPos())
		effectData:SetScale(6)
			
		util.Effect("HelicopterMegaBomb", effectData, true, true)

		self:EmitSound("physics/wood/wood_furniture_break"..math.random(1,2)..".wav")

	end

	function ENT:blowDoor()

		for i = 1, self:GetDTFloat(0) do

			
			timer.Simple(i, function()

				self:SetDTFloat(0, self:GetDTFloat(0) - 1)

				self:EmitSound( "buttons/button6.wav", 110, 70 + (i * 20) ) 

			end)

		end

		timer.Simple(self:GetDTFloat(0), function()

			self:Explode()
			self:Remove()

		end)

	end

elseif (CLIENT) then

function ENT:Draw()

	self:DrawModel();
	
	local r, g, b, a = self:GetColor();
	local angles = self:GetAngles();
	local position = self:GetPos();

	local fix_angles = self.Entity:GetAngles()
	local fix_rotation = Vector(0, 90, 90)

	fix_angles:RotateAroundAxis(fix_angles:Right(), fix_rotation.x)
	fix_angles:RotateAroundAxis(fix_angles:Up(), fix_rotation.y)
	fix_angles:RotateAroundAxis(fix_angles:Forward(), fix_rotation.z)
	
	end
	
end