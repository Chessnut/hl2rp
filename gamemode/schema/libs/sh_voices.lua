nut.voice = nut.voice or {}
nut.voice.buffer = nut.voice.buffer or {}
nut.voice.lengthCache = {}

function nut.voice.Register(class, key, replacement, source, isFemale)
	nut.voice.buffer[class] = nut.voice.buffer[class] or {}
	nut.voice.buffer[class][string.lower(key)] = {replacement = replacement, source = source, isFemale = isFemale}
end

function nut.voice.Play(client, class, text, delay, noSound, global, volume)
	local soundList = nut.voice.buffer[class]
	delay = delay or 0
	volume = volume or 100
	
	if (soundList) then
		local info = soundList[string.lower(text)]

		if (info) then
			local source = info.source

			if (type(source) == "table") then
				source = table.Random(source)
			end

			nut.voice.lengthCache[source] = nut.voice.lengthCache[source] or SoundDuration(source)

			local shouldPlaySound = !noSound and client:GetNutVar("nextVoice", 0) < CurTime()

			if (shouldPlaySound) then
				if (delay > 0) then
					timer.Simple(delay, function()
						if (!IsValid(client)) then return end
						
						if (global) then
							nut.util.PlaySound(source)
						else
							client:EmitSound(source, volume)
						end
					end)
				else
					if (global) then
						nut.util.PlaySound(source)
					else
						client:EmitSound(source, volume)
					end
				end

				client:SetNutVar("nextVoice", CurTime() + nut.config.voiceCmdDelay)
			end

			return info.replacement, shouldPlaySound and nut.voice.lengthCache[source] or 0.1, source
		end
	end

	return nil, 0.1
end

if (CLIENT) then
	hook.Add("BuildHelpOptions", "nut_VoiceHelp", function(data, tree)
		local categories = {}
		local contents = {}

		data:AddHelp("Voices", function(tree)
			return "Click on a sub-category to see specific voices."
		end, "icon16/sound.png")

		data:AddCallback("Voices", function(node, body)
			for k, v in SortedPairs(nut.voice.buffer) do
				local name = k:sub(1, 1):upper()..k:sub(2)
				local category = node:AddNode(name)
				local html = ""

				for k, v in SortedPairs(v) do
					html = html.."<p><b>"..k:upper().."</b><br />"..v.replacement.."</p>"
				end

				category.DoClick = function()
					body:SetContents(html)
				end
			end
		end)
	end)
end