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

nut.command.Register({
	onRun = function(client, arguments)
		if (!client:IsCombine()) then return nut.util.Notify("You are not the Combine!") end

		local digits = nut.util.GetRandomNum(5)
		local items = client:GetItemsByClass("cid")
		local index

		for k, v in pairs(items) do
			if (!v.data or (!v.data.Name and !v.data.Digits)) then
				index = k

				break
			end
		end

		if (!index) then return nut.util.Notify("You do not have a blank identification card.", client) end

		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector()*96
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		if (IsValid(entity) and entity:IsPlayer()) then
			if (entity:Team() == FACTION_CITIZEN) then
				entity:UpdateInv("cid", 1, {
					Name = entity:Name(),
					Digits = digits
				})
				client:UpdateInv("cid", -1, {})

				nut.util.Notify("You have assigned "..entity:Name().." a new identification card.", client)
				nut.util.Notify(client:Name().." has assigned you a new identification card.", entity)
			else
				nut.util.Notify("This player is not a citizen.", client)
			end
		else
			nut.util.Notify("You are not looking at a valid player.", client)
		end
	end
}, "assign")