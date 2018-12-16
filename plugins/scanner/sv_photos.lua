util.AddNetworkString("nutScannerData")
util.AddNetworkString("nutScannerPicture")
util.AddNetworkString("nutScannerClearPicture")

net.Receive("nutScannerData", function(length, client)
    if (IsValid(client.nutScn) and client:GetViewEntity() == client.nutScn and (client.nutNextPic or 0) < CurTime()) then
        local delay = nut.config.get("pictureDelay", 15)
        client.nutNextPic = CurTime() + delay - 1

        local length = net.ReadUInt(16)
        local data = net.ReadData(length)

        if (length != #data) then
            return
        end

        local receivers = {}

        for k, v in ipairs(player.GetAll()) do
            if (hook.Run("CanPlayerReceiveScan", v, client)) then
                receivers[#receivers + 1] = v
                v:EmitSound("npc/overwatch/radiovoice/preparevisualdownload.wav")
            end
        end

        if (#receivers > 0) then
            net.Start("nutScannerData")
                net.WriteUInt(#data, 16)
                net.WriteData(data, #data)
            net.Send(receivers)

            if (SCHEMA.addDisplay) then
                SCHEMA:addDisplay("Prepare to receive visual download...")
            end
        end
    end
end)

net.Receive("nutScannerPicture", function(length, client)
    if (not IsValid(client.nutScn)) then return end
    if (client:GetViewEntity() ~= client.nutScn) then return end
    if ((client.nutNextFlash or 0) >= CurTime()) then return end

    client.nutNextFlash = CurTime() + 1
    client.nutScn:flash()
end)