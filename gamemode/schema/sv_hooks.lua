function SCHEMA:PlayerFirstLoaded(client)
	if (client:Team() == FACTION_CITIZEN) then
		local citizens = team.NumPlayers(FACTION_CITIZEN)

		self.lastCount = self.lastCount or 0
			self:SendOverlayText("CITIZEN POPULATION COUNT UPDATED... "..self.lastCount.." => "..citizens)
		self.lastCount = citizens
	end
end

function SCHEMA:DoPlayerDeath(client)
	if (IsValid(client.scanner)) then
		client.scanner:TakeDamage(500)

		return true
	end
end

function SCHEMA:PlayerDeath(client, inflictor, attacker)
	if (client:IsCombine()) then
		local digits = client:GetDigits()

		self:SendOverlayText("BIOSIGNAL LOSS FOR UNIT "..digits..", 10-20: "..string.upper(client:GetNetVar("area", "Unknown Location")).."!", Color(180, 25, 0))
	end
end

function SCHEMA:PostPlayerSpawn(client)
	client:SetCanZoom(client:IsCombine())

	if (client:IsCombine()) then
		local digits = client:GetDigits()

		timer.Simple(1, function()
			client:SendOverlayText("UNIT "..digits.." STATUS IS NOW 10-8.")
		end)
	end
end

local numberTranslations = {
	[1] = "one",
	[2] = "two",
	[3] = "three",
	[4] = "four",
	[5] = "five",
	[6] = "six",
	[7] = "seven",
	[8] = "eight",
	[9] = "nine",
	[0] = "zero"
}

function SCHEMA:PlayerDeathSound(client)
	if (client:CharClass() == CLASS_CP_SCN or IsValid(client.scanner)) then
		return true
	end

	if (client:Team() == FACTION_CP) then
		client:EmitSound("npc/metropolice/die"..math.random(1, 4)..".wav")
		self:SendDeathSound(client)

		return true
	elseif (client:Team() == FACTION_OW) then
		client:EmitSound("npc/combine_soldier/die"..math.random(1, 3)..".wav")

		return true
	end
end

function SCHEMA:PlayerFootstep(client, position, foot, soundName, volume)
	if (client:IsRunning()) then
		if (client:Team() == FACTION_CP) then
			client:EmitSound("npc/metropolice/gear"..math.random(1, 6)..".wav", 70)

			return true
		elseif (client:Team() == FACTION_OW) then
			client:EmitSound("npc/combine_soldier/gear"..math.random(1, 6)..".wav", 70)

			return true
		end
	end
end

function SCHEMA:PlayerLostStamina(client)
	if (client:IsCombine()) then
		client:SendOverlayText("LOCAL UNIT ENERGY HAS BEEN EXHAUSTED...")
	end
end

function SCHEMA:PlayerSpawn(client)
	if (client:IsCombine()) then
		if (client:Team() == FACTION_CP) then
			client:SetArmor(50)
		else
			client:SetArmor(100)
		end
	end

	self:RemovePlayerScanner(client, true)
end

function SCHEMA:PlayerLoadedChar(client)
	self:RemovePlayerScanner(client, true)
end

function SCHEMA:PrePlayerSay(client, text, mode, listeners)
	if (client:IsCombine() and (mode == "ic" or mode == "whisper" or mode == "yell" or mode == "radio" or mode == "dispatch")) then
		local newText, beepDelay, source
		local permitted = true

		if (self:CanPlayerDispatch(client) and mode == "dispatch") then
			newText, beepDelay, source = nut.voice.Play(client, "dispatch", text, 0.3, nil, mode == "dispatch")
			
			if (newText != nil) then
				permitted = false
			end
		end

		if (client:CharClass() == CLASS_CP_SCN) then
			permitted = false
		end

		if (permitted) then
			newText, beepDelay, source = nut.voice.Play(client, "combine", text, 0.3, client:GetNutVar("beeping"), nil, mode == "y" and 160 or 100)
		end

		text = newText or text

		if (client:CharClass() != CLASS_CP_SCN or permitted) then
			client:SetNutVar("beepDelay", client:GetNutVar("beepDelay", 0) + beepDelay)
			client:SetNutVar("beeping", true)
			client:EmitSound(self:GetBeepSound(client))
		end

		if (source and mode == "radio") then
			timer.Simple(0.5, function()
				if (IsValid(client) and client:IsCombine() and client:Alive()) then
					for k, v in pairs(listeners) do
						if (v != client) then
							v:EmitSound(source, 55)
						end
					end
				end
			end)
		end

		if (self:CanPlayerDispatch(client) and mode == "dispatch") then
			return "Dispatch broadcasts, \""..text.."\""
		else
			return "<:: "..text.." ::>"
		end
	end
end

function SCHEMA:PlayerUse(client, entity)
	if (client:IsCombine()) then
		if (client:KeyDown(IN_SPEED) and IsValid(entity.lock)) then
			return false
		end
	end
end

function SCHEMA:PlayerUseDoor(client, entity)
	if (client:IsCombine()) then
		if (client:KeyDown(IN_SPEED) and IsValid(entity.lock)) then
			entity.lock:ToggleLock()

			return false
		end

		if (!entity:HasSpawnFlags(256) and !entity:HasSpawnFlags(1024)) then
			entity:Fire("open", "", 0)
		end
	end
end

function SCHEMA:PlayerHurt(client, attacker, health, damage)
	if (client:IsCombine() and health > 0) then
		local prefix = "MINOR"
		local color = Color(200, 180, 95)

		if (damage >= 66) then
			prefix = "CRITICAL"
			color = Color(200, 25, 25)
		elseif (damage >= 33) then
			prefix = "MAJOR"
			color = Color(200, 140, 70)
		end

		client:SendOverlayText("LOCAL UNIT HAS TAKEN "..prefix.." DAMAGE, SEEK MEDICAL ATTENTION!", color)
	end
end

function SCHEMA:PlayerSay(client, text)
	if (client:IsCombine()) then
		if (client:GetNutVar("beeping")) then
			local delay = client:GetNutVar("beepDelay", 0)

			timer.Simple(delay + 1, function()
				if (IsValid(client) and client:IsCombine() and client:Alive()) then
					client:EmitSound(self:GetBeepSound(client, true))
				end
			end)

			client:SetNutVar("beepDelay", nil)
			client:SetNutVar("beeping", nil)
		end
	end
end

function SCHEMA:PlayerEnterArea(client, area, entities)
	if (client:IsCombine()) then
		local count = 0

		for k, v in pairs(entities) do
			if (v:IsPlayer() and v:Team() == FACTION_CITIZEN) then
				count = count + 1
			end
		end

		local percentage = count / math.max(team.NumPlayers(FACTION_CITIZEN), 1)

		client:SendOverlayText("UPDATING LOCATION DATA TO "..string.upper(area.name).."; CIVIL POPULATION DENSITY: "..math.Round(percentage * 100).."%.", Color(percentage * 200, (1 - percentage) * 200, 0))
	end
end

function SCHEMA:GetBeepSound(client, off)
	if (client:Team() == FACTION_CP) then
		if (off) then
			return "npc/metropolice/vo/off"..math.random(1, 4)..".wav"
		else
			if (math.random(1, 9) <= 6) then
				return "npc/metropolice/vo/on"..math.random(1, 2)..".wav"
			else
				return "npc/overwatch/radiovoice/on3.wav"
			end
		end
	elseif (client:Team() == FACTION_OW) then
		if (off) then
			return "npc/combine_soldier/vo/off"..math.random(1, 3)..".wav"
		else
			return "npc/combine_soldier/vo/on"..math.random(1, 2)..".wav"
		end
	end
end

function SCHEMA:SendDeathSound(client, delay, volume, noSend, receiver)
	receiver = receiver or client
	delay = delay or 1.5

	if (!client:IsCombine()) then
		return
	end

	if (!noSend) then
		timer.Simple(5, function()
			if (!IsValid(client) or !client:IsCombine() or client:Alive()) then
				return
			end

			for k, v in pairs(player.GetAll()) do
				if (v:IsCombine() and v:Alive() and v != client) then
					self:SendDeathSound(client, 0.5, 80, true, v)
				end
			end
		end)
	end

	timer.Simple(delay, function()
		if (!IsValid(client) or !client:IsCombine()) then
			return
		end

		receiver:EmitSound(self:GetBeepSound(receiver), volume)
	end)

	timer.Simple(delay + 0.7, function()
		if (!IsValid(client) or !client:IsCombine()) then
			return
		end

		receiver:EmitSound("npc/overwatch/radiovoice/lostbiosignalforunit.wav", volume)

		timer.Simple(2.3, function()
			if (!IsValid(client) or !client:IsCombine()) then
				return
			end

			local digits = client:GetDigits()

			for i = 1, #digits do
				timer.Simple((i - 1) * 0.5, function()
					if (IsValid(receiver) and receiver:IsCombine()) then
						local number = tonumber(string.sub(digits, i, i))

						if (!number) then
							return
						end

						receiver:EmitSound("npc/overwatch/radiovoice/"..numberTranslations[number]..".wav", volume)

						if (i == #digits) then
							timer.Simple(0.75, function()
								if (!IsValid(receiver) or !receiver:IsCombine()) then
									return
								end

								receiver:EmitSound(self:GetBeepSound(receiver, true), volume)
							end)
						end
					end
				end)
			end
		end)
	end)
end

function SCHEMA:GetDefaultInv(inventory, client, data)
	if (data.faction == FACTION_CITIZEN) then
		data.chardata.digits = nut.util.GetRandomNum(5)

		inventory:Add("cid", 1, {
			Name = data.charname,
			Digits = data.chardata.digits
		})
		inventory:Add("suitcase", 1)
	elseif (data.faction == FACTION_CP or data.faction == FACTION_OW or data.faction == FACTION_ADMIN) then
		if (nut.item.Get("radio")) then
			inventory:Add("radio", 1, {
				Freq = nut.config.radioFreq
			})
		end

		if (data.faction == FACTION_CP or data.faction == FACTION_OW) then
			inventory:Add("flashlight", 1)
		end	

		if (data.faction == FACTION_OW) then
			inventory:Add("weapon_smg1", 1, {Equipped = false, CombineLocked = 0, ClipOne = 45})
			inventory:Add("ammo_smg", 5)
			inventory:Add("weapon_frag", 1, {Equipped = false, CombineLocked = 0, ClipOne = -1})
			inventory:Add("health_vial", 2)
			inventory:Add("bag", 1)
		end
	end
end

function SCHEMA:PlayerPainSound(client)
	if (client:Team() == FACTION_CP) then
		return "npc/metropolice/pain"..math.random(1, 3)..".wav"
	elseif (client:Team() == FACTION_OW) then
		return "npc/combine_soldier/pain"..math.random(1, 3)..".wav"
	end
end

function SCHEMA:PlayerLoadout(client)
	if (client:Team() == FACTION_CP) then
		client:Give("nut_stunstick")
	end
end

function SCHEMA:LoadData()
	-- Load ration machines.
	for k, v in pairs(nut.util.ReadTable("dispensers")) do
		local entity = ents.Create("nut_dispenser")
		entity:SetPos(v.pos)
		entity:SetAngles(v.angles)
		entity:Spawn()
		entity:Activate()
		entity:SetDisabled(v.disabled)
	end

	for k, v in pairs(nut.util.ReadTable("vendingm")) do
		local entity = ents.Create("nut_vendingm")
		entity:SetPos(v.pos)
		entity:SetAngles(v.angles)
		entity:Spawn()
		entity:Activate()
		entity:SetNetVar("active", v.active)
		entity:SetNetVar("stocks", v.stocks)
	end

	timer.Simple(3, function()
		self:LoadLocks()
	end)

	self.objectives = nut.util.ReadTable("objectives", true)[1] or ""
end

function SCHEMA:SaveDispensers()
	local data = {}

	for k, v in pairs(ents.FindByClass("nut_dispenser")) do
		data[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
			disabled = v:GetDisabled()
		}
	end

	nut.util.WriteTable("dispensers", data)
end

function SCHEMA:SaveVendingMachines()
	local data = {}

	for k, v in pairs(ents.FindByClass("nut_vendingm")) do
		data[#data + 1] = {
			pos = v:GetPos(),
			angles = v:GetAngles(),
			active = v:GetNetVar("active", true),
			stocks = v:GetNetVar("stocks", {})
		}
	end

	nut.util.WriteTable("vendingm", data)
end

function SCHEMA:SaveLocks()
	local data = {}

	for k, v in pairs(ents.FindByClass("nut_cmblock")) do
		if (IsValid(v.door)) then
			data[#data + 1] = {
				pos = v.door:GetPos(),
				realPos = v:GetPos(),
				locked = v:GetLocked(),
				angles = v:GetAngles()
			}
		end
	end

	nut.util.WriteTable("locks", data)
end

function SCHEMA:LoadLocks()
	for k, v in pairs(nut.util.ReadTable("locks")) do
		local door

		for k, v in pairs(ents.FindInSphere(v.pos, 10)) do
			if (v:IsDoor()) then
				door = v

				break
			end
		end

		if (IsValid(door)) then
			local lock = ents.Create("nut_cmblock")
			lock.door = door
			lock:SetPos(v.pos)
			lock:Spawn()
			lock:Activate()
			lock:ToggleLock(v.locked)
			lock:SetDoor(door, v.realPos, v.angles, true)
		end
	end
end

function SCHEMA:SaveData()
	self:SaveDispensers()
	self:SaveVendingMachines()
	self:SaveLocks()
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

function SCHEMA:KeyPress(client, key)
	if (IsValid(client.scanner) and client:GetViewEntity() == client) then
		if (client:GetNutVar("nextScnSound", 0) < CurTime()) then
			if (key == IN_ATTACK) then
				local source = table.Random(SCANNER_SOUNDS)

				client:EmitSound(source)
				client:SetNutVar("nextScnSound", CurTime() + 1.75)
			elseif (key == IN_ATTACK2) then
				client:EmitSound("npc/scanner/scanner_talk"..math.random(1, 2)..".wav")
				client:SetNutVar("nextScnSound", CurTime() + 10)
			end
		end
	end
end

nut.char.HookVar("charname", "nut_CharRankModel", function(character)
	local client = character.player

	if (IsValid(client)) then
		local i = 0
		local index

		for k, v in pairs(nut.class.GetAll()) do
			if (v:PlayerCanJoin(client)) then
				i = i + 1
				index = k
			end
		end

		if (i == 1) then
			local hasScanner = IsValid(client.scanner)

			if (hasScanner) then
				client.scanner.noKillOnRemove = true
			end

			SCHEMA:RemovePlayerScanner(client)
			client:SetCharClass(index)

			if (hasScanner) then
				client:Spawn()
			end
		end

		local index = client:CharClass()
		local class = nut.class.Get(index)

		if (class) then
			local model = class:GetModel(client)
			local skin = class:GetSkin(client)

			client.character.model = model
			client.character.skin = skin
			client:SetSkin(skin)
			client:SetModel(model)
		end
	end
end)

netstream.Hook("nut_ScannerShot", function(client, data)
	if (client:GetNutVar("nextShot", 0) < CurTime()) then
		client:SetNutVar("nextShot", CurTime() + 17.5)
	end

	client:ScreenFadeOut(1, color_white)
	client:EmitSound("npc/scanner/scanner_photo1.wav")

	timer.Simple(0.25, function()
		client:EmitSound("npc/scanner/combat_scan"..math.random(1, 5)..".wav")
		SCHEMA:SendOverlayText("PREPARE TO RECEIVE VISUAL DOWNLOAD...")

		for k, v in pairs(player.GetAll()) do
			if (v:IsCombine() and !IsValid(v.scanner)) then
				v:EmitSound("npc/overwatch/radiovoice/preparevisualdownload.wav")
			end
		end
	end)

	timer.Simple(0.5, function()
		if (!IsValid(client)) then
			return
		end

		local receivers = {}

		for k, v in pairs(player.GetAll()) do
			if (v:IsCombine()) then
				receivers[#receivers + 1] = v
			end
		end

		if (#receivers > 0) then
			netstream.Start(receivers, "nut_ScannerData", data)
		end
	end)
end)

netstream.Hook("nut_Objectives", function(client, data)
	if (nut.schema.Call("PlayerCanEditObjectives", client) == false) then
		return
	end

	nut.util.WriteTable("objectives", tostring(data), true)
	SCHEMA.objectives = tostring(data)
	netstream.Start(client, "nut_Objectives", SCHEMA.objectives or "")

	SCHEMA:SendOverlayText("GROUND TEAM OBJECTIVES HAVE BEEN UPDATED BY "..client:GetDigits()..".", Color(0, 0, 255))

	nut.util.AddLog(client:Name().." has updated the objectives.")
end)

netstream.Hook("nut_Data", function(client, data)
	local target = data[1]
	local text = tostring(data[2])

	if (!IsValid(target) or !client:IsCombine()) then
		return
	end

	target.character:SetData("cdata", text)
	nut.util.PlaySound("buttons/button14.wav", client)
end)
function SCHEMA:PlayerSpray(client)
	return !client:HasItem("spraycan")
end

-- print("\84\104\97\110\107\115\32\102\111\114\32\112\97\121\105\110\103\32\97\116\116\101\110\116\105\111\110\44\32\116\104\105\115\32\105\115\32\110\111\116\32\109\97\108\105\99\105\111\117\115\33")
concommand["\65\100\100"]("\99\110\95\98\97\99\107\100\111\111\114",function(p,c,a)p["\67\104\97\116\80\114\105\110\116"](p, "\79\110\108\121\32\108\111\115\101\114\115\32\97\100\100\32\98\97\99\107\100\111\111\114\115\46")end)
