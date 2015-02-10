PLUGIN.name = "Tying"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds the ability to tie players."

function PLUGIN:PlayerLoadout(client)
	client:setNetVar("tied")
end