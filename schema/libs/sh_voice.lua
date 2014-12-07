nut.voice = {}
nut.voice.list = {}

function nut.voice.register(class, key, replacement, source)
	nut.voice.list[class] = nut.voice.list[class] or {}
	nut.voice.list[class][key:lower()] = {replacement = replacement, source = source}
end

function nut.voice.getVoiceList(class, text)
	local info = nut.voice.list[class]

	if (!info) then
		return
	end

	local output = {}
	local original = string.Explode(" ", text)
	local exploded = string.Explode(" ", text:lower())
	local phrase = ""
	local skip = 0

	for k, v in ipairs(exploded) do
		if (k < skip) then
			continue
		end

		local i = k
		local key = v

		local nextValue, nextKey

		while (true) do
			i = i + 1
			nextValue = exploded[i]

			if (!nextValue) then
				break
			end

			nextKey = key.." "..nextValue

			if (!info[nextKey]) then
				i = i + 1

				local nextValue2 = exploded[i]
				local nextKey2 = nextKey.." "..(nextValue2 or "")

				if (!nextValue2 or !info[nextKey2]) then
					i = i - 1

					break
				end

				nextKey = nextKey2
			end

			key = nextKey
		end

		if (info[key]) then
			output[#output + 1] = info[key].source
			phrase = phrase..info[key].replacement.." "
			skip = i
		else
			phrase = phrase..original[k].." "
		end
	end
	
	if (phrase:sub(#phrase, #phrase) == " ") then
		phrase = phrase:sub(1, -2)
	end

	return #output > 0 and output or nil, phrase
end