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

			if (!noSound) then
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
			end

			return info.replacement, nut.voice.lengthCache[source] or 0.1, source
		end
	end

	return nil, 0.1
end