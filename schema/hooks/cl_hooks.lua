SCHEMA.displays = {}

function SCHEMA:HUDPaint()
	if (LocalPlayer():isCombine() and !IsValid(nut.gui.char)) then
		if (!self.overlay) then
			self.overlay = Material("effects/combine_binocoverlay")
			self.overlay:SetFloat("$alpha", "0.3")
			self.overlay:Recompute()
		end

		surface.SetDrawColor(255, 255, 255)
		surface.SetMaterial(self.overlay)
		surface.DrawTexturedRect(0, 0, ScrW(), ScrH())

		local panel = nut.gui.combine

		if (IsValid(panel)) then
			local x, y = panel:GetPos()
			local w, h = panel:GetSize()
			local color = Color(255, 255, 255, panel:GetAlpha())

			for i = 1, #SCHEMA.displays do
				local data = SCHEMA.displays[i]

				if (data) then
					local y2 = y + (i * 22)

					if ((i * 22 + 24) > h) then
						table.remove(self.displays, 1)
					end

					surface.SetDrawColor(data.color.r, data.color.g, data.color.b, panel:GetAlpha() * (panel.mult or 0.2))
					surface.DrawRect(x, y2, w, 22)

					if (#data.realText != #data.text) then
						data.i = (data.i or 0) + 1
						data.realText = data.text:sub(1, data.i)
					end

					draw.SimpleText(data.realText, "BudgetLabel", x + 8, y2 + 12, color, 0, 1)
				end
			end
		end
	end
end

function SCHEMA:addDisplay(text, color)
	if (LocalPlayer():isCombine()) then
		color = color or Color(0, 0, 0)

		SCHEMA.displays[#SCHEMA.displays + 1] = {text = tostring(text):upper(), color = color, realText = ""}
		LocalPlayer():EmitSound("buttons/button16.wav", 30, 120)
	end
end

function SCHEMA:OnChatReceived(client, chatType, text, anonymous)
	local class = nut.chat.classes[chatType]

	if (client:isCombine() and class and class.filter == "ic") then
		return "<:: "..text.." ::>"
	end
end

function SCHEMA:CharacterLoaded(character)
	if (character == LocalPlayer():getChar()) then
		if (self:isCombineFaction(character:getFaction())) then
			vgui.Create("nutCombineDisplay")
		elseif (IsValid(nut.gui.combine)) then
			nut.gui.combine:Remove()
		end
	end
end

function SCHEMA:OnContextMenuOpen()
	if (IsValid(nut.gui.combine)) then
		nut.gui.combine:SetVisible(true)
	end
end

function SCHEMA:OnContextMenuClose()
	if (IsValid(nut.gui.combine)) then
		nut.gui.combine:SetVisible(false)
	end
end

local color = {}
color["$pp_colour_addr"] = 0
color["$pp_colour_addg"] = 0
color["$pp_colour_addb"] = 0
color["$pp_colour_brightness"] = -0.01
color["$pp_colour_contrast"] = 1.35
color["$pp_colour_colour"] = 0.65
color["$pp_colour_mulr"] = 0
color["$pp_colour_mulg"] = 0
color["$pp_colour_mulb"] = 0

function SCHEMA:RenderScreenspaceEffects()
	DrawColorModify(color)
end

netstream.Hook("cDisp", function(text, color)
	SCHEMA:addDisplay(text, color)
end)

netstream.Hook("plyData", function(...)
	vgui.Create("nutData"):setData(...)
end)

netstream.Hook("obj", function(...)
	vgui.Create("nutObjective"):setData(...)
end)

netstream.Hook("voicePlay", function(sounds, volume, index)
	if (index) then
		local client = Entity(index)

		if (IsValid(client)) then
			nut.util.emitQueuedSounds(client, sounds, nil, nil, volume)
		end
	else
		nut.util.emitQueuedSounds(LocalPlayer(), sounds, nil, nil, volume)
	end
end)