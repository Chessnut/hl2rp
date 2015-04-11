PLUGIN.name = "Flashlight"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Provides a flashlight item to regular flashlight usage."

function PLUGIN:PlayerSwitchFlashlight(client, state)
	local character = client:getChar()

	if (!character or !character:getInv()) then
		return false
	end

	if (character:getInv():hasItem("flashlight")) then
		return true
	end
end