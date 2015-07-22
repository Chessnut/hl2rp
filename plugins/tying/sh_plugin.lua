PLUGIN.name = "Tying"
PLUGIN.author = "Chessnut"
PLUGIN.desc = "Adds the ability to tie players."

nut.util.include("sh_charsearch.lua")

if (SERVER) then
	function PLUGIN:PlayerLoadout(client)
		client:setNetVar("restricted")
	end

	function PLUGIN:PlayerUse(client, entity)
		if (!client:getNetVar("restricted") and entity:IsPlayer() and entity:getNetVar("restricted") and !entity.nutBeingUnTied) then
			entity.nutBeingUnTied = true
			entity:setAction("@beingUntied", 5)

			client:setAction("@unTying", 5)
			client:doStaredAction(entity, function()
				entity:setRestricted(false)
				entity.nutBeingUnTied = false

				client:EmitSound("npc/roller/blade_in.wav")
			end, 5, function()
				if (IsValid(entity)) then
					entity.nutBeingUnTied = false
					entity:setAction()
				end

				if (IsValid(client)) then
					client:setAction()
				end
			end)
		end
	end
else
	local COLOR_TIED = Color(245, 215, 110)

	function PLUGIN:DrawCharInfo(client, character, info)
		if (client:getNetVar("restricted")) then
			info[#info + 1] = {L"isTied", COLOR_TIED}
		end
	end
end