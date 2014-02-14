-- Add the metropolice model pack.
resource.AddWorkshop("104491619")
resource.AddWorkshop("105042805")

function SCHEMA:CreatePlayerScanner(client, class)
	if (IsValid(client.scanner) or client:CharClass() != CLASS_CP_SCN) then
		return
	end
	
	class = class or "npc_cscanner"

	local scanner = ents.Create(class)
	scanner:SetPos(client:GetPos())
	-- Efficient (ignore players) and don't drop anything on death.
	scanner:SetKeyValue("spawnflags", 8192 + 16)
	-- Don't go around inspecting players.
	scanner:Fire("InputShouldInspect", "false")
	-- Prevents scanner from straying away too much.
	scanner:Fire("SetDistanceOverride", "48")
	scanner:Fire("SetHealth", "125")
	scanner:Spawn()
	scanner:Activate()
	scanner:SetNetVar("player", client)
	scanner.character = client.character
	scanner:CallOnRemove("PlayerImpulse", function()
		if (IsValid(client) and client:Alive() and client.character == scanner.character and !scanner.noKillOnRemove) then
			client:Kill()
			SCHEMA:RemovePlayerScanner(client)
		end
	end)

	hook.Add("EntityTakeDamage", scanner, function(entity, inflictor, attacker, damage, damageInfo)
		if (IsValid(client) and target == scanner) then
			client:TakeDamageInfo(damageInfo)
		end
	end)

	client.scanner = scanner

	if (IsValid(client.scnTarget)) then
		client.scnTarget:Remove()
	end

	local targetID	= "nut_Scn"..client:UniqueID()
	local target = ents.Create("path_corner")
	target:SetPos(client:GetPos())
	target:SetKeyValue("targetname", targetID)
	target:Spawn()
	target:Activate()

	client.scnTarget = target

	client:Spectate(OBS_MODE_CHASE)
	client:SpectateEntity(scanner)
		
	-- What to delete when things get removed.
	client:DeleteOnRemove(scanner)
	scanner:DeleteOnRemove(target)

	local uniqueID = "nut_Scanner"..client:UniqueID()

	timer.Create(uniqueID, 0.33, 0, function()
		if (!IsValid(client) or !IsValid(scanner)) then
			return timer.Remove(uniqueID)
		end

		local factor = 128

		if (client:KeyDown(IN_SPEED)) then
			factor = 64
		end

		if (client:KeyDown(IN_FORWARD)) then
			target:SetPos((scanner:GetPos() + client:GetAimVector()*factor) - Vector(0, 0, 64))
			scanner:Fire("SetFollowTarget", targetID)
		elseif (client:KeyDown(IN_BACK)) then
			target:SetPos((scanner:GetPos() + client:GetAimVector()*-factor) - Vector(0, 0, 64))
			scanner:Fire("SetFollowTarget", targetID)
		elseif (client:KeyDown(IN_JUMP)) then
			target:SetPos(scanner:GetPos() + Vector(0, 0, factor))
			scanner:Fire("SetFollowTarget", targetID)	
		end

		client:SetPos(scanner:GetPos())

		if (client:KeyDown(IN_WALK) and client:GetNutVar("nextCamSwitch", 0) < CurTime()) then
			local viewEntity = client:GetViewEntity()

			if (IsValid(viewEntity) and viewEntity != client) then
				client:SetViewEntity(client)
			else
				client:SetViewEntity(scanner)
			end

			client:SetNutVar("nextCamSwitch", CurTime() + 0.66)
		end
	end)
	
	timer.Simple(0.1, function()
		client:StripWeapons()
		client:Flashlight(false)
		client:AllowFlashlight(false)
	end)
end

function SCHEMA:RemovePlayerScanner(client, noSetPos)
	if (IsValid(client.scanner)) then
		if (!noSetPos) then
			client:SetPos(client.scanner:GetPos())
		end
		
		client.scanner:Remove()
	end

	if (IsValid(client.scnTarget)) then
		client.scnTarget:Remove()
	end

	timer.Remove("nut_Scanner"..client:UniqueID())

	client:SetMoveType(MOVETYPE_NONE)
	client:UnSpectate()
	client:SetViewEntity(client)
	client:AllowFlashlight(true)
end

nut.util.Include("sv_hooks.lua")