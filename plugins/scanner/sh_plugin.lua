PLUGIN.name = "Player Scanners Util"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds functions that allow players to control scanners."

nut.config.add(
	"pictureDelay",
	15,
	"How often scanners can take pictures.",
	nil,
	{
		category = PLUGIN.name,
		data = {min = 0, max = 60}
	}
)

if (CLIENT) then
	PLUGIN.PICTURE_WIDTH = 580
	PLUGIN.PICTURE_HEIGHT = 420
end

nut.util.include("sv_photos.lua")
nut.util.include("cl_photos.lua")
nut.util.include("sv_hooks.lua")
nut.util.include("cl_hooks.lua")
