PLUGIN.name = "Advanced Citizen Outfit"
PLUGIN.author = "Black Tea"
PLUGIN.desc = "This plugin allows the server having good amount of customizable citizens."

nut.util.include("sh_sheets.lua")
nut.util.include("sh_citizenmodels.lua")
nut.util.include("cl_vgui.lua")
nut.util.include("sh_generateitem.lua")

-- requires material preload to acquire submaterial change.
if (CLIENT) then
	local time = os.time()
	-- preventing vast loading
	for mdl, mdld in pairs(RESKINDATA) do
		for k, v in ipairs(mdld.facemaps) do
			surface.SetMaterial(Material(v))
		end
	end

	for mdl, mdld in pairs(CITIZENSHEETS) do
		for k, v in ipairs(mdld) do
			surface.SetMaterial(Material(v))
		end
	end
	print(Format("Preloaded All Textures: %s", os.time() - time))
end

local function changeFacemap(client, value)
	local mdl = string.lower(client:GetModel())
	local mdldat = RESKINDATA[mdl]

	if (value == 0) then
		client:SetSubMaterial(mdldat[2] - 1, "")
	else
		local facemap = mdldat.facemaps[value]
		client:SetSubMaterial(mdldat[2] - 1, facemap)
	end
end

function PLUGIN:PlayerSpawn(client)
	timer.Simple(0, function() -- to prevent getmodel failing.
		local mats = client:GetMaterials()

		-- You have to reset entity texture replacement if you don't want texture fuckups.
		for k, v in ipairs(mats) do
			client:SetSubMaterial(k - 1, "")
		end

		if (client:getChar()) then
			timer.Simple(0, function()
					local value = client:getChar():getData("charFacemap")

					if (value) then
						changeFacemap(client, value)
					end
			end)
		end
	end)
end

function PLUGIN:PlayerLoadedChar(client)
	timer.Simple(0, function()
		local inv = client:getChar():getInv()

		if (inv) then
			for k, v in pairs(inv.slots) do
				for k2, v2 in pairs(v) do
					if (v2.isCloth and v2:getData("equip")) then
						local mdl = string.lower(client:GetModel())
						local mdldat = RESKINDATA[mdl]

						if (!mdl) then
							client:notify("This model is not supported (no mdltexcoord)")
							
							return false
						end

						if (mdldat.sheets == v2.sheet[1]) then
							local sheet = CITIZENSHEETS[v2.sheet[1]][v2.sheet[2]]

							if (!sheet) then
								client:notify("Incorrect Sheetdata")
								return false
							end

							client:SetSubMaterial(mdldat[1] - 1, sheet)
						else
							client:notify("This model is not supported (sheetdata)")
							return false
						end

						return false
					end
				end
			end
		end	
	end)
end

netstream.Hook("charFacemap", function(client, value)
	value = math.ceil(value)
	client:getChar():setData("charFacemap", value)

	changeFacemap(client, value)
end)

nut.command.add("charfacemap", {
	onRun = function(client, arguments)
		netstream.Start(client, "charFacemapMenu")
	end
})