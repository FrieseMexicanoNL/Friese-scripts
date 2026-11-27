local isOpen = false
local function nearestVehicle()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)
    if vehicle == 0 then
        local coords = GetEntityCoords(ped)
        vehicle = GetClosestVehicle(coords.x, coords.y, coords.z, FrStorage.Config.MaxDistance, 0, 70)
    end
    if vehicle == 0 or not DoesEntityExist(vehicle) then return nil end
    return vehicle
end
local function openStorage(kind)
    if isOpen then return end
    local vehicle = nearestVehicle()
    if not vehicle then TriggerEvent('friese-storage:client:notify', 'Geen voertuig in de buurt.'); return end
    TriggerServerEvent('friese-storage:server:open', NetworkGetNetworkIdFromEntity(vehicle), kind)
end
RegisterCommand(FrStorage.Config.Command, function(_, args)
    local kind = args[1] == 'handschoenenkastje' and 'glovebox' or 'trunk'
    openStorage(kind)
end, false)
RegisterCommand('kofferbak', function() openStorage('trunk') end, false)
RegisterCommand('handschoenenkastje', function() openStorage('glovebox') end, false)
RegisterNetEvent('friese-storage:client:open', function(data)
    isOpen = true; SetNuiFocus(true, true); SendNUIMessage({ action = 'open', data = data })
end)
RegisterNetEvent('friese-storage:client:refresh', function(data) if isOpen then SendNUIMessage({ action = 'refresh', data = data }) end end)
RegisterNetEvent('friese-storage:client:notify', function(message) TriggerEvent('friese-notify:client:notify', message, 'error') end)
RegisterNUICallback('close', function(_, cb) isOpen = false; SetNuiFocus(false, false); TriggerServerEvent('friese-storage:server:close'); cb({ ok = true }) end)
RegisterNUICallback('transfer', function(data, cb) TriggerServerEvent('friese-storage:server:transfer', data.direction, tonumber(data.index), tonumber(data.amount) or 1); cb({ ok = true }) end)
