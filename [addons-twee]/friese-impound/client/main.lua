local function notify(message, kind)
    TriggerEvent('friese-notify:client:notify', message, kind or 'info')
end

RegisterCommand(ImpoundConfig.ImpoundCommand, function(_, args)
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        local coords = GetEntityCoords(ped)
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, ImpoundConfig.MaxDistance, 0, 70)
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify('Geen voertuig dichtbij gevonden.', 'error')
        return
    end
    local netId = NetworkGetNetworkIdFromEntity(vehicle)
    if netId == 0 then notify('Dit voertuig kan niet worden geregistreerd.', 'error'); return end
    local fee = tonumber(args[1]) or ImpoundConfig.DefaultFee
    local reason = table.concat(args, ' ', tonumber(args[1]) and 2 or 1)
    if reason == '' then reason = 'Inbeslagname door politie' end
    TriggerServerEvent('friese-impound:server:impound', netId, reason, fee)
end, false)

RegisterCommand(ImpoundConfig.ReleaseCommand, function(_, args)
    if not args[1] then notify('Gebruik: /voertuigvrij KENTEKEN', 'info'); return end
    TriggerServerEvent('friese-impound:server:release', args[1])
end, false)
