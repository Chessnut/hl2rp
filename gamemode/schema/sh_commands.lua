nut.command.Register({
	adminOnly = true,
	syntax = "[bool disabled]",
	onRun = function(client, arguments)
		local entity = scripted_ents.Get("nut_dispenser"):SpawnFunction(client, client:GetEyeTraceNoCursor())

		if (IsValid(entity)) then
			entity:SetDisabled(util.tobool(arguments[1]))
			nut.util.Notify("You have created a ration dispenser.", client)
		end
	end
}, "placedispenser")

nut.command.Register({
	adminOnly = true,
	syntax = "[bool disabled]",
	onRun = function(client, arguments)
		local entity = scripted_ents.Get("nut_vendingm"):SpawnFunction(client, client:GetEyeTraceNoCursor())

		if (IsValid(entity)) then
			entity:SetNetVar("active", !util.tobool(arguments[1]))
			nut.util.Notify("You have created a vending machine.", client)
		end
	end
}, "placevendor")

nut.command.Register({
	onRun = function(client, arguments)
		if (!client:IsCombine()) then
			nut.util.Notify("You are not the Combine!", client)

			return
		end
		netstream.Start(client, "nut_Objectives", tostring(SCHEMA.objectives or ""))
	end
}, "objectives")

nut.command.Register({
	syntax = "<string name>",
	onRun = function(client, arguments)
		if (!client:IsCombine()) then
			nut.util.Notify("You are not the Combine!", client)

			return
		end

		local target = nut.command.FindPlayer(client, table.concat(arguments))

		if (IsValid(target)) then
			netstream.Start(client, "nut_Data", {target, target.character:GetData("cdata", nut.config.defaultData or ""), target:Name().." [#"..target:GetDigits().."]"})
		end
	end
}, "data")