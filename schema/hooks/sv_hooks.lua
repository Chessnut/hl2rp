function SCHEMA:PlayerFootstep(client, position, foot, soundName, volume)
	if (client:isRunning()) then
		if (client:Team() == FACTION_CP) then
			client:EmitSound("npc/metropolice/gear"..math.random(1, 6)..".wav", volume * 130)

			return true
		elseif (client:Team() == FACTION_OW) then
			client:EmitSound("npc/combine_soldier/gear"..math.random(1, 6)..".wav", volume * 100)

			return true
		end
	end
end

function SCHEMA:OnCharCreated(client, character)
	local inventory = character:getInv()

	if (inventory) then		
		if (character:getFaction() == FACTION_CITIZEN) then
			inventory:add("cid", 1, {
				name = character:getName(),
				id = math.random(10000, 99999)
			})
		elseif (self:isCombineFaction(character:getFaction())) then
			inventory:add("radio", 1)
		end
	end
end

function SCHEMA:LoadData()
	self:loadVendingMachines()
	self:loadDispensers()
	self:loadObjectives()
end

function SCHEMA:PostPlayerLoadout(client)
	if (client:isCombine()) then
		if (client:Team() == FACTION_CP) then
			for k, v in ipairs(nut.class.list) do
				if (client:getChar():joinClass(k)) then
					break
				end
			end

			hook.Run("PlayerRankChanged", client)

			client:SetArmor(50)
		else
			client:SetArmor(100)
		end

		client:addDisplay("Local unit protection measures active at "..client:Armor().."%")

		if (nut.plugin.list.scanner and client:isCombineRank(self.scnRanks)) then
			nut.plugin.list.scanner:createScanner(client, client:getCombineRank() == "CLAW.SCN" and "npc_clawscanner" or nil)
		end
	end
end

function SCHEMA:CanPlayerViewData(client, target)
	if (client:isCombine()) then
		return true
	end
end

function SCHEMA:PlayerUseDoor(client, entity)
	if (client:isCombine()) then
		local lock = entity.lock or (IsValid(entity:getDoorPartner()) and entity:getDoorPartner().lock)

		if (client:KeyDown(IN_SPEED) and IsValid(lock)) then
			lock:toggle()

			return false
		elseif (!entity:HasSpawnFlags(256) and !entity:HasSpawnFlags(1024)) then
			entity:Fire("open", "", 0)
		end
	end
end

function SCHEMA:PlayerSwitchFlashlight(client, enabled)
	if (client:isCombine()) then
		return true
	end
end

function SCHEMA:PlayerRankChanged(client)
	for k, v in pairs(self.rankModels) do
		if (client:isCombineRank(k)) then
			client:SetModel(v)
		end
	end
end

function SCHEMA:OnCharVarChanged(character, key, oldValue, value)
	if (key == "name" and IsValid(character:getPlayer()) and character:getPlayer():isCombine()) then
		for k, v in ipairs(nut.class.list) do
			if (character:joinClass(k)) then
				break
			end
		end

		hook.Run("PlayerRankChanged", character:getPlayer())
	end
end

local digitsToWords = {
	[0] = "zero",
	[1] = "one",
	[2] = "two",
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven",
	[8] = "eight",
	[9] = "nine"
}

function SCHEMA:GetPlayerDeathSound(client)
	if (client:isCombine()) then
		local sounds = self.deathSounds[client:Team()] or self.deathSounds[FACTION_CP]
		local digits = client:getDigits()
		local queue = {"npc/overwatch/radiovoice/lostbiosignalforunit.wav"}

		if (tonumber(digits)) then
			for i = 1, #digits do
				local digit = tonumber(digits:sub(i, i))
				local word = digitsToWords[digit]

				queue[#queue + 1] = "npc/overwatch/radiovoice/"..word..".wav"
			end

			local chance = math.random(1, 7)

			if (chance == 2) then
				queue[#queue + 1] = "npc/overwatch/radiovoice/remainingunitscontain.wav"
			elseif (chance == 3) then
				queue[#queue + 1] = "npc/overwatch/radiovoice/reinforcementteamscode3.wav"
			end

			queue[#queue + 1] = {table.Random(self.beepSounds[client:Team()] and self.beepSounds[client:Team()].off or self.beepSounds[FACTION_CP].off), nil, 0.25}

			for k, v in ipairs(player.GetAll()) do
				if (v:isCombine()) then
					nut.util.emitQueuedSounds(v, queue, 2, nil, v == client and 100 or 65)
				end
			end
		end

		self:addDisplay("lost bio-signal for protection team unit "..digits.." at unknown location", Color(255, 0, 0))

		return table.Random(sounds)
	end
end

function SCHEMA:PlayerHurt(client, attacker, health, damage)
	if (client:isCombine() and damage > 5) then
		local word = "minor"

		if (damage >= 75) then
			word = "immense"
		elseif (damage >= 50) then
			word = "huge"
		elseif (damage >= 25) then
			word = "large"
		end

		client:addDisplay("local unit has sustained "..word.." bodily damage"..(damage >= 25 and ", seek medical attention" or ""), Color(255, 175, 0))

		local delay

		if (client:Health() <= 10) then
			delay = 5
		elseif (client:Health() <= 25) then
			delay = 10
		elseif (client:Health() <= 50) then
			delay = 30
		end

		if (delay) then
			client.nutHealthCheck = CurTime() + delay
		end
	end
end

function SCHEMA:GetPlayerPainSound(client)
	if (client:isCombine()) then
		local sounds = self.painSounds[client:Team()] or self.painSounds[FACTION_CP]

		return table.Random(sounds)
	end
end

function SCHEMA:PlayerTick(client)
	if (client:isCombine() and client:Alive() and (client.nutHealthCheck or 0) < CurTime()) then
		local delay = 60

		if (client:Health() <= 10) then
			delay = 10
			client:addDisplay("Local unit vital signs are failing, seek medical attention immediately", Color(255, 0, 0))
		elseif (client:Health() <= 25) then
			delay = 20
			client:addDisplay("Local unit must seek medical attention immediately", Color(255, 100, 0))
		elseif (client:Health() <= 50) then
			delay = 45
			client:addDisplay("Local unit is advised to seek medical attention when possible", Color(255, 175, 0))
		end

		client.nutHealthCheck = CurTime() + delay
	end
end

function SCHEMA:PlayerMessageSend(client, chatType, message, anonymous, receivers)
	if (!nut.voice.chatTypes[chatType]) then
		return
	end

	for _, definition in ipairs(nut.voice.getClass(client)) do
		local sounds, message = nut.voice.getVoiceList(definition.class, message)

		if (sounds) then
			local volume = 80

			if (chatType == "w") then
				volume = 60
			elseif (chatType == "y") then
				volume = 150
			end
			
			if (definition.onModify) then
				if (definition.onModify(client, sounds, chatType, message) == false) then
					continue
				end
			end

			if (definition.isGlobal) then
				netstream.Start(nil, "voicePlay", sounds, volume)
			else
				netstream.Start(nil, "voicePlay", sounds, volume, client:EntIndex())

				if (chatType == "radio" and receivers) then
					for k, v in pairs(receivers) do
						if (receivers == client) then
							continue
						end

						netstream.Start(nil, "voicePlay", sounds, volume * 0.5, v:EntIndex())
					end
				end
			end

			return message
		end
	end
end

function SCHEMA:PlayerStaminaLost(client)
	if (client:isCombine()) then
		client:addDisplay("Local unit energy has been exhausted")
	end
end

function SCHEMA:CanPlayerViewObjectives(client)
	return client:isCombine()
end

function SCHEMA:CanPlayerEditObjectives(client)
	return client:isCombine()
end

netstream.Hook("dataCls", function(client, text)
	local target = client.nutDataTarget

	if (text and IsValid(target) and target:getChar() and hook.Run("CanPlayerEditData", client, target)) then
		target:getChar():setData("txt", text:sub(1, 750))
		client:EmitSound("buttons/combine_button7.wav", 60, 150)
	end

	client.nutDataTarget = nil
end)

netstream.Hook("obj", function(client, text)
	if (hook.Run("CanPlayerEditObjectives", client)) then
		SCHEMA.objectives = text
		SCHEMA:addDisplay(client:Name().." has updated the objectives", Color(0, 0, 255))
		SCHEMA:saveObjectives()
	end
end)