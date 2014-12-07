SCHEMA.name = "HL2 RP"
SCHEMA.author = "Chessnut"
SCHEMA.desc = "Under rule of the Universal Union."

function SCHEMA:isCombineFaction(faction)
	return faction == FACTION_CP or faction == FACTION_OTA
end

do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:isCombine()
		return SCHEMA:isCombineFaction(self:Team())
	end

	function playerMeta:getDigits()
		if (self:isCombine()) then
			local name = self:Name():reverse()
			local digits = name:match("(%d+)")

			if (digits) then
				return tostring(digits):reverse()
			end
		end

		return "UNKNOWN"
	end

	if (SERVER) then
		function playerMeta:addDisplay(text, color)
			if (self:isCombine()) then
				netstream.Start(self, "cDisp", text, color)
			end
		end

		function SCHEMA:addDisplay(text, color)
			local receivers = {}

			for k, v in ipairs(player.GetAll()) do
				if (v:isCombine()) then
					receivers[#receivers + 1] = v
				end
			end

			netstream.Start(receivers, "cDisp", text, color)
		end
	end
end

nut.util.include("sh_config.lua")
nut.util.include("cl_hooks.lua")
nut.util.include("sv_hooks.lua")

if (SERVER) then
	concommand.Add("nut_setupnexusdoors", function(client, command, arguments)
		if (!IsValid(client)) then
			if (!nut.plugin.list.doors) then
				return MsgN("[NutScript] Door plugin is missing!")
			end

			local name = table.concat(arguments, " ")

			for _, entity in ipairs(ents.FindByClass("func_door")) do
				if (!entity:HasSpawnFlags(256) and !entity:HasSpawnFlags(1024)) then
					entity:setNetVar("noSell", true)
					entity:setNetVar("name", !name:find("%S") and "Nexus" or name)
				end
			end

			nut.plugin.list.doors:SaveDoorData()

			MsgN("[NutScript] Nexus doors have been set up.")
		end
	end)
end

for k, v in pairs(SCHEMA.beepSounds) do
	for k2, v2 in ipairs(v.on) do
		util.PrecacheSound(v2)
	end

	for k2, v2 in ipairs(v.off) do
		util.PrecacheSound(v2)
	end
end

for k, v in pairs(SCHEMA.deathSounds) do
	for k2, v2 in ipairs(v) do
		util.PrecacheSound(v2)
	end
end

for k, v in pairs(SCHEMA.painSounds) do
	for k2, v2 in ipairs(v) do
		util.PrecacheSound(v2)
	end
end

nut.util.include("sh_voices.lua")