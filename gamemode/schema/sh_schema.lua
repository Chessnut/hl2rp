SCHEMA.name = "HL2 RP"
SCHEMA.author = "Chessnut"
SCHEMA.desc = "Life under the rule of the Universal Union."

nut.currency.SetUp("token", "tokens")

nut.util.Include("sh_config.lua")
nut.util.Include("sv_schema.lua")
nut.util.Include("cl_hooks.lua")
nut.util.Include("sh_commands.lua")
nut.util.Include("sh_voices.lua")

function SCHEMA:IsCombineFaction(faction)
 	return faction == FACTION_CP or faction == FACTION_OW
end

function SCHEMA:CanPlayerDispatch(client)
	if (CLIENT and !client) then client = LocalPlayer() end
	
	return client:IsCombineRank(nut.config.scannerRanks) or client:IsCombineRank(nut.config.cpEliteRanks) or client:Team() == FACTION_OW
end

-- Player extensions here.
do
	local playerMeta = FindMetaTable("Player")

	function playerMeta:IsCombine()
		return SCHEMA:IsCombineFaction(self:Team())
	end

	if (SERVER) then
		function SCHEMA:SendOverlayText(text, color)
			for k, v in pairs(player.GetAll()) do
				if (v:IsCombine()) then
					v:SendOverlayText(text, color)
				end
			end
		end

		function playerMeta:SendOverlayText(text, color)
			if (self:IsCombine()) then
				netstream.Start(self, "nut_OverlayText", {text, color})
			end
		end
	end

	function playerMeta:GetDigits()
		if (self:IsCombine()) then
			return string.match(string.sub(self:Name(), -(self:Team() == FACTION_CP and nut.config.cpNumDigits or nut.config.owNumDigits) - 1), "[%.?](%d+)") or string.match(self:Name(), "(%d+)")
		elseif (SERVER) then
			local item = self:GetItem("cid")

			if (item and item.data) then
				return item.data.Digits or "UNKNOWN"
			end
		end
	
		return "UNKNOWN"
	end

	function playerMeta:IsCombineRank(rank)
		if (!self:IsCombine()) then
			return false
		end

		local name = self:Name()

		if (type(rank) == "table") then
			for k, v in pairs(rank) do
				if (string.find(name, v, nil, true)) then
					return true
				end
			end
		elseif (string.find(name, rank, nil, true)) then
			return true
		end

		return false
	end
end

-- Business stuff.
do
	function SCHEMA:ShouldItemDisplay(itemTable)
		local isPermit = itemTable.uniqueID == "permit"
		
		if (LocalPlayer():Team() == FACTION_CITIZEN) then
			if (LocalPlayer():HasItem("permit")) then
				if (isPermit) then
					return false
				end

				return true
			elseif (isPermit) then
				return true
			end

			return false
		elseif (isPermit) then
			return false
		end
	end
end

nut.chat.Register("dispatch", {
	onChat = function(speaker, text)
		chat.AddText(Color(179, 89, 71), text)
	end,
	canSay = function(speaker)
		if (!SCHEMA:CanPlayerDispatch(speaker)) then
			nut.util.Notify(nut.lang.Get("no_perm", speaker:Name()), speaker)

			return
		end

		return true
	end,
	prefix = "/dispatch"
})

nut.chat.Register("request", {
	canSay = function(speaker)
		if (!speaker:HasItem("request")) then
			nut.util.Notify(nut.lang.Get("no_perm", speaker:Name()), speaker)

			return
		end

		if (speaker:GetNutVar("nextReq", 0) < CurTime()) then
			speaker:SetNutVar("nextReq", CurTime() + 5)
		else
			nut.util.Notify("Please wait before sending another request.", speaker)
		end

		speaker:EmitSound("buttons/blip1.wav", 60)

		return true
	end,
	onSaid = function(speaker, text)
		timer.Simple(0.5, function()
			if (!IsValid(speaker)) then return end
			speaker:EmitSound("buttons/blip1.wav", 70, 140)

			local digits = speaker:GetDigits() or "ERROR"
			SCHEMA:SendOverlayText(speaker:Name().." [#"..digits..", "..speaker:GetNetVar("area", "UNKNOWN").."] HAS SUBMITTED A CIVIL REQUEST:", Color(0, 0, 255))

			if (#text > 60) then
				suffix = "..."
				text = string.sub(text, 1, 57).."..."
			end

			SCHEMA:SendOverlayText(text, Color(0, 0, 255))
		end)
	end,
	prefix = {"/req", "/request"}
})

for k, v in pairs(nut.config.cpRankModels) do
	nut.anim.SetModelClass("metrocop", v[2])
	util.PrecacheModel(v[2])
end

function SCHEMA:PlayerCanEditObjectives(client)
	if (!client:IsCombine()) then
		return false
	end

	if (client:Team() == FACTION_OW) then
		return true
	else
		for k, v in pairs(nut.config.objRanks) do
			if (client:IsCombineRank(v)) then
				return true
			end
		end
	end

	return false
end

-- The main color scheme for buttons and such.
nut.config.mainColor = Color(79, 129, 200)
