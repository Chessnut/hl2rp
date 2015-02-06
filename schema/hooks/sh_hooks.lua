function SCHEMA:CanPlayerEditData(client, target)
	if (client:isCombine()) then
		return true
	end

	return false
end