nut.command.add("doorkick", {
	onRun = function(client, arguments)
		if (client:Team() == FACTION_CP) then
			local aimVector = client:GetAimVector()

			local data = {}
				data.start = client:GetShootPos()
				data.endpos = data.start + aimVector*96
				data.filter = client
			local entity = util.TraceLine(data).Entity

			if (IsValid(entity) and entity:GetClass() == "prop_door_rotating") then
				if (client:forceSequence("kickdoorbaton")) then
					timer.Simple(0.75, function()
						if (IsValid(client) and IsValid(entity)) then
							entity:EmitSound("physics/wood/wood_crate_break"..math.random(1, 5)..".wav", 150)
							entity:blastDoor(aimVector * (360 + client:getChar():getAttrib("str", 0)*5))
						end
					end)
				end
			else
				return "@dNotValid"
			end
		else
			return "@mustBeCP"
		end
	end
})

nut.command.add("data", {
	syntax = "<string name>",
	onRun = function(client, arguments)
		local target = nut.command.findPlayer(client, table.concat(arguments, " "))

		if (IsValid(target) and target:getChar()) then
			if (!hook.Run("CanPlayerViewData", client, target)) then
				return "@noViewData"
			end

			client.nutDataTarget = target
			netstream.Start(client, "plyData", target:getChar():getData("txt"), target:Name().." ["..target:getDigits().."]", hook.Run("CanPlayerEditData", client, target))
		end
	end
})

nut.command.add("objectives", {
	onRun = function(client, arguments)
		if (hook.Run("CanPlayerViewObjectives", client)) then
			netstream.Start(client, "obj", SCHEMA.objectives, hook.Run("CanPlayerEditObjectives", client))
		else
			return "@noViewObj"
		end
	end
})