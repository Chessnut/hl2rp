PLUGIN.name = "Player Scanners Util"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds functions that allow players to control scanners."

if (SERVER) then
	function PLUGIN:createScanner(client, class)
		class = class or "npc_cscanner"

		if (IsValid(client.nutScn)) then
			return
		end

		local entity = ents.Create(class)

		if (!IsValid(entity)) then
			return
		end
		
		entity:SetPos(client:GetPos())
		entity:SetAngles(client:GetAngles())
		entity:SetColor(client:GetColor())
		entity:Spawn()
		entity:Activate()
		entity.player = client
		entity:CallOnRemove("nutRestore", function()
			if (IsValid(client)) then
				local position = entity.spawn or client:GetPos()

				client:UnSpectate()

				if (entity:Health() > 0) then
					client:Spawn()
				else
					client:KillSilent()
				end

				timer.Simple(0, function()
					client:SetPos(position)
				end)
			end
		end)

		local name = "nutScn"..os.clock()
		entity.name = name

		local target = ents.Create("path_track")
		target:SetPos(entity:GetPos())
		target:Spawn()
		target:SetName(name)

		entity:Fire("setfollowtarget", name)
		entity:Fire("inputshouldinspect", false)
		entity:Fire("setdistanceoverride", "48")
		entity:SetKeyValue("spawnflags", 8208)

		client.nutScn = entity
		client:StripWeapons()
		client:Spectate(OBS_MODE_CHASE)
		client:SpectateEntity(entity)

		local uniqueID = "nut_Scanner"..client:UniqueID()

		timer.Create(uniqueID, 0.33, 0, function()
			if (!IsValid(client) or !IsValid(entity)) then
				return timer.Remove(uniqueID)
			end

			local factor = 128

			if (client:KeyDown(IN_SPEED)) then
				factor = 64
			end

			if (client:KeyDown(IN_FORWARD)) then
				target:SetPos((entity:GetPos() + client:GetAimVector()*factor) - Vector(0, 0, 64))
				entity:Fire("setfollowtarget", name)
			elseif (client:KeyDown(IN_BACK)) then
				target:SetPos((entity:GetPos() + client:GetAimVector()*-factor) - Vector(0, 0, 64))
				entity:Fire("setfollowtarget", name)
			elseif (client:KeyDown(IN_JUMP)) then
				target:SetPos(entity:GetPos() + Vector(0, 0, factor))
				entity:Fire("setfollowtarget", name)	
			elseif (client:KeyDown(IN_DUCK)) then
				target:SetPos(entity:GetPos() - Vector(0, 0, factor))
				entity:Fire("setfollowtarget", name)				
			end

			client:SetPos(entity:GetPos())
		end)

		return entity
	end

	function PLUGIN:PlayerSpawn(client)
		if (IsValid(client.nutScn)) then
			client.nutScn.spawn = client:GetPos()
			client.nutScn:Remove()
		end
	end

	function PLUGIN:PlayerDeath(client)
		if (IsValid(client.nutScn)) then
			client.nutScn:TakeDamage(999)
		end
	end

	local SCANNER_SOUNDS = {
		"npc/scanner/scanner_blip1.wav",
		"npc/scanner/scanner_scan1.wav",
		"npc/scanner/scanner_scan2.wav",
		"npc/scanner/scanner_scan4.wav",
		"npc/scanner/scanner_scan5.wav",
		"npc/scanner/combat_scan1.wav",
		"npc/scanner/combat_scan2.wav",
		"npc/scanner/combat_scan3.wav",
		"npc/scanner/combat_scan4.wav",
		"npc/scanner/combat_scan5.wav",
		"npc/scanner/cbot_servoscared.wav",
		"npc/scanner/cbot_servochatter.wav"
	}

	function PLUGIN:KeyPress(client, key)
		if (IsValid(client.nutScn) and (client.nutScnDelay or 0) < CurTime()) then
			local source

			if (key == IN_USE) then
				source = table.Random(SCANNER_SOUNDS)
				client.nutScnDelay = CurTime() + 1.75
			elseif (key == IN_RELOAD) then
				source = "npc/scanner/scanner_talk"..math.random(1, 2)..".wav"
				client.nutScnDelay = CurTime() + 10
			end

			if (source) then
				client.nutScn:EmitSound(source)
			end
		end
	end

	function PLUGIN:PlayerNoClip(client)
		if (IsValid(client.nutScn)) then
			return false
		end
	end
	
	function PLUGIN:PlayerUse(client, entity)
		if (IsValid(client.nutScn)) then
			return false
		end
	end
end