-- The prefix that goes before names of civil protection units.
nut.config.cpPrefix = "CP-"
-- The number of digits that follow the name.
nut.config.cpNumDigits = 5
-- The prefix that goes before names of combine soldiers.
nut.config.owPrefix = "OW-"
-- The number of digits that follows the name.
nut.config.owNumDigits = 5
-- The amount of time in SECONDS someone must wait to get their next ration. (Default 30 mins.)
nut.config.rationTime = 1800
-- The ranks that belong to the recruit CP class.
nut.config.cpRctRanks = {"RCT."}
-- The ranks that belong to the unit CP class.
nut.config.cpUnitRanks = {"05.", "04.", "03.", "02.", "01.", "OfC."}
-- The ranks that belong to the elite CP class.
nut.config.cpEliteRanks = {"EpU.", "DvL.", "SeC."}
-- The ranks that scanners belong to.
nut.config.scannerRanks = {"SCN.", "CLAW.SCN."}
-- The default radio frequency for Combine.
nut.config.radioFreq = "123.4"
-- The starting weight for inventories.
nut.config.defaultInvWeight = 7.5
-- The rank(s) that are allowed to edit the objectives.
nut.config.objRanks = {"EpU.", "DvL.", "SeC."}
-- The default player data when the Combine sees it.
nut.config.defaultData = [[
Name:
Points:
]]
-- The delay in second(s) between voice commands.
nut.config.voiceCmdDelay = 1

-- The models for Civil Protection ranks. The models are checked in order, so
-- place your ranks in order!
nut.config.cpRankModels = {
	{"SeC", "models/dpfilms/metropolice/phoenix_police.mdl"},
	{"DvL", "models/dpfilms/metropolice/blacop.mdl"},
	{"EpU", "models/dpfilms/metropolice/elite_police.mdl"},
	{"OfC", "models/dpfilms/metropolice/policetrench.mdl"},
	{nut.config.cpUnitRanks, "models/dpfilms/metropolice/hl2concept.mdl"}
}

-- Overwrite the default NutScript configs here for our schema.
nut.config.menuMusic = "music/hl2_song27_trainstation2.mp3"