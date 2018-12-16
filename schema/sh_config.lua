-- Customize the beep sounds here, before and after voices.
SCHEMA.beepSounds = {}
SCHEMA.beepSounds[FACTION_CP] = {
	on = {
		"npc/overwatch/radiovoice/on1.wav",
		"npc/overwatch/radiovoice/on3.wav",
		"npc/metropolice/vo/on2.wav"
	},
	off = {
		"npc/metropolice/vo/off1.wav",
		"npc/metropolice/vo/off2.wav",
		"npc/metropolice/vo/off3.wav",
		"npc/metropolice/vo/off4.wav",
		"npc/overwatch/radiovoice/off2.wav",
		"npc/overwatch/radiovoice/off2.wav"
	}
}
SCHEMA.beepSounds[FACTION_OW] = {
	on = {
		"npc/combine_soldier/vo/on1.wav",
		"npc/combine_soldier/vo/on2.wav"
	},
	off = {
		"npc/combine_soldier/vo/off1.wav",
		"npc/combine_soldier/vo/off2.wav",
		"npc/combine_soldier/vo/off3.wav"
	}
}

-- Sounds play after the player has died.
SCHEMA.deathSounds = {}
SCHEMA.deathSounds[FACTION_CP] = {
	"npc/metropolice/die1.wav",
	"npc/metropolice/die2.wav",
	"npc/metropolice/die3.wav",
	"npc/metropolice/die4.wav"
}
SCHEMA.deathSounds[FACTION_OW] = {
	"npc/combine_soldier/die1.wav",
	"npc/combine_soldier/die2.wav",
	"npc/combine_soldier/die3.wav"
}

-- Sounds the player makes when injured.
SCHEMA.painSounds = {}
SCHEMA.painSounds[FACTION_CP] = {
	"npc/metropolice/pain1.wav",
	"npc/metropolice/pain2.wav",
	"npc/metropolice/pain3.wav",
	"npc/metropolice/pain4.wav"
}
SCHEMA.painSounds[FACTION_OW] = {
	"npc/combine_soldier/pain1.wav",
	"npc/combine_soldier/pain2.wav",
	"npc/combine_soldier/pain3.wav"
}

-- Combine name prefix.
SCHEMA.cpPrefix = "CP-"
SCHEMA.owPrefix = "OT-"

-- How long the Combine digits are.
SCHEMA.digitsLen = 5

-- Rank information.
SCHEMA.rctRanks = {"RCT"}
SCHEMA.unitRanks = {"05", "04", "03", "02", "01", "OfC"}
SCHEMA.eliteRanks = {"EpU", "DvL", "SeC"}
SCHEMA.scnRanks = {"CLAW.SCN", "SCN"}
SCHEMA.owRanks = {SCHEMA.owDefaultRank, "OWE", "OPG", "SGS", "SPG"}

SCHEMA.owDefaultRank = "OWS"

SCHEMA.rankTables = {
	[FACTION_CP] = {
		SCHEMA.rctRanks,
		SCHEMA.unitRanks,
		SCHEMA.eliteRanks,
		SCHEMA.scnRanks
	},
	[FACTION_OW] = {SCHEMA.owRanks}
}

-- What model each rank should be.
SCHEMA.rankModels = {
	["RCT"] = "models/police.mdl",
	[SCHEMA.unitRanks] = "models/dpfilms/metropolice/hl2concept.mdl",
	["OfC"] = "models/dpfilms/metropolice/policetrench.mdl",
	["EpU"] = "models/dpfilms/metropolice/elite_police.mdl",
	["DvL"] = "models/dpfilms/metropolice/blacop.mdl",
	["SeC"] = "models/dpfilms/metropolice/phoenix_police.mdl",
	["SCN"] = "models/combine_scanner.mdl",
	["CLAW.SCN"] = "models/shield_scanner.mdl"
}

SCHEMA.owRankModels = {
	[SCHEMA.owDefaultRank] = {"models/combine_soldier.mdl", 0},
	["OWE"] = {"models/combine_super_soldier.mdl", 0},
	["OPG"] = {"models/combine_soldier_prisonguard.mdl", 0},
	["SGS"] = {"models/combine_soldier.mdl", 1},
	["SPG"] = {"models/combine_soldier_prisonguard.mdl", 1},
}

-- The default player data when using /data
SCHEMA.defaultData = [[
Points:
Infractions:
]]