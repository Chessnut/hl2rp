AddCSLuaFile()

ENT.Type = "anim"
ENT.PrintName = "Vending Machine"
ENT.Author = "Chessnut"
ENT.Category = "HL2 RP"
ENT.Spawnable = true
ENT.AdminOnly = true
ENT.PhysgunDisable = true
ENT.PhysgunAllowAdmin = true

function ENT:SpawnFunction(client, trace)
	local entity = ents.Create("nut_vendingm")
	entity:SetPos(trace.HitPos + Vector(0, 0, 48))

	local angles = (entity:GetPos() - client:GetPos()):Angle()
	angles.p = 0
	angles.y = math.Round(angles.y / 45) * 45 + 180
	angles.r = 0

	entity:SetAngles(angles)
	entity:Spawn()
	entity:Activate()

	for k, v in pairs(ents.FindInBox(entity:LocalToWorld(entity:OBBMins()), entity:LocalToWorld(entity:OBBMaxs()))) do
		if (v:GetClass() != "nut_vendingm" and v:GetModel() == "models/props_interiors/vendingmachinesoda01a.mdl") then
			entity:SetPos(v:GetPos())
			entity:SetAngles(v:GetAngles())
			SafeRemoveEntity(v)

			break
		end
	end

	SCHEMA:saveVendingMachines()

	return entity
end

function ENT:getNearestButton(client)
	client = client or (CLIENT and LocalPlayer())

	if (self.buttons) then
		if (SERVER) then
			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

			self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
			self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
			self.buttons[3] = position + f*18 + r*-24.4 + u*1.35
		end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)
		local hitPos = trace.HitPos

		if (hitPos) then
			for k, v in pairs(self.buttons) do
				if (v:Distance(hitPos) <= 2) then
					return k
				end
			end
		end
	end
end

if (SERVER) then
	function ENT:Initialize()
		self.buttons = {}

		local position = self:GetPos()
		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
		self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
		self.buttons[3] = position + f*18 + r*-24.4 + u*1.35

		self:SetModel("models/props_interiors/vendingmachinesoda01a.mdl")
		self:PhysicsInit(SOLID_VPHYSICS)
		self:SetSolid(SOLID_VPHYSICS)
		self:SetUseType(SIMPLE_USE)

		self:setNetVar("stocks", {10, 5, 5})
		self:setNetVar("active", true)

		local physObj = self:GetPhysicsObject()

		if (IsValid(physObj)) then
			physObj:EnableMotion(false)
			physObj:Sleep()
		end

		for k, v in pairs(ents.FindInBox(self:LocalToWorld(self:OBBMins()), self:LocalToWorld(self:OBBMaxs()))) do
			if (v:GetClass() != "nut_vendingm" and v:GetModel() == "models/props_interiors/vendingmachinesoda01a.mdl") then
				self:SetPos(v:GetPos())
				self:SetAngles(v:GetAngles())
				SafeRemoveEntity(v)

				return
			end
		end
	end

	function ENT:Use(activator)
		activator:EmitSound("buttons/lightswitch2.wav", 55, 125)

		if ((self.nextUse or 0) < CurTime()) then
			self.nextUse = CurTime() + 2
		else
			return
		end

		local button = self:getNearestButton(activator)
		local stocks = self:getNetVar("stocks")

		if (activator:isCombine()) then
			if (activator:KeyDown(IN_SPEED) and button and stocks[button]) then
				if (stocks[button] > 0) then
					return activator:addDisplay("NO REFILL IS REQUIRED FOR THIS MACHINE.")
				end

				self:EmitSound("buttons/button5.wav")

				if (!activator:getChar():hasMoney(25)) then
					return activator:addDisplay("INSUFFICIENT FUNDS (25 TOKENS) TO REFILL MACHINE.")
				else
					activator:addDisplay("25 TOKENS HAVE BEEN TAKEN TO REFILL MACHINE.")
					activator:getChar():takeMoney(25)
				end

				timer.Simple(1, function()
					if (!IsValid(self)) then return end

					stocks[button] = button == 1 and 10 or 5
					self:setNetVar("stocks", stocks)
				end)

				return
			else
				self:setNetVar("active", !self:getNetVar("active"))
				self:EmitSound(self:getNetVar("active") and "buttons/combine_button1.wav" or "buttons/combine_button2.wav")

				return
			end
		end

		if (self:getNetVar("active") == false) then
			return
		end

		if (button and stocks and stocks[button] and stocks[button] > 0) then
			local item = "water"
			local price = 5

			if (button == 2) then
				item = "water_sparkling"
				price = price + 10
			elseif (button == 3) then
				item = "water_special"
				price = price + 15
			end

			if (!activator:getChar():hasMoney(price)) then
				self:EmitSound("buttons/button2.wav")

				return activator:notify("You need "..nut.currency.get(price).." to purchase this selection.")
			end

			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

			nut.item.spawn(item, position + f*19 + r*4 + u*-26, function(item, entity)
				stocks[button] = stocks[button] - 1

				if (stocks[button] < 1) then
					self:EmitSound("buttons/button6.wav")
				end

				self:setNetVar("stocks", stocks)
				self:EmitSound("buttons/button4.wav", Angle(0, 0, 90))

				activator:getChar():takeMoney(price)
				activator:getChar():takeMoney(price)
				activator:notify("You have spent "..nut.currency.get(price).." on this vending machine.")
			end)
		end
	end

	function ENT:OnRemove()
		if (!nut.shuttingDown) then
			SCHEMA:saveVendingMachines()
		end
	end
else
	local draw_SimpleText = draw.SimpleText
	local glowMaterial = Material("sprites/glow04_noz")

	local color_green = Color(0, 255, 0, 255)
	local color_red = Color(255, 0, 0, 255)
	local color_orange = Color(255, 125, 0, 255)

	function ENT:Initialize()
		self.buttons = {}

		local position = self:GetPos()
		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
		self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
		self.buttons[3] = position + f*18 + r*-24.4 + u*1.35
	end

	function ENT:Draw()
		self:DrawModel()

		local position = self:GetPos()
		local angles = self:GetAngles()
		angles:RotateAroundAxis(angles:Up(), 90)
		angles:RotateAroundAxis(angles:Forward(), 90)

		local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

		cam.Start3D2D(position + f*17.33 + r*-19.5 + u*5.75, angles, 0.06)
			draw_SimpleText("Regular", "ChatFont", 0, 0, color_white, 0, 0)
			draw_SimpleText("Sparkling", "ChatFont", 0, 36, color_white, 0, 0)
			draw_SimpleText("Special", "ChatFont", 0, 72, color_white, 0, 0)
		cam.End3D2D()

		render.SetMaterial(glowMaterial)

		if (self.buttons) then
			local position = self:GetPos()
			local f, r, u = self:GetForward(), self:GetRight(), self:GetUp()

			self.buttons[1] = position + f*18 + r*-24.4 + u*5.3
			self.buttons[2] = position + f*18 + r*-24.4 + u*3.35
			self.buttons[3] = position + f*18 + r*-24.4 + u*1.35

			local closest = self:getNearestButton()
			local stocks = self:getNetVar("stocks")

			for k, v in pairs(self.buttons) do
				local color = color_green

				if (self:getNetVar("active")) then
					if (stocks and stocks[k] and stocks[k] < 1) then
						color = color_red
						color.a = 200
					end

					if (closest != k) then
						color.a = color == color_red and 100 or 75
					else
						color.a = 230 + (math.sin(RealTime() * 7.5) * 25)
					end

					if (LocalPlayer():KeyDown(IN_USE) and closest == k) then
						color = table.Copy(color)
						color.r = math.min(color.r + 100, 255)
						color.g = math.min(color.g + 100, 255)
						color.b = math.min(color.b + 100, 255)
					end
				else
					color = color_orange
				end

				render.DrawSprite(v, 4, 4, color)
			end
		end
	end
end
