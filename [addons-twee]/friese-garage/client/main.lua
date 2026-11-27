local currentGarage, garageOpen = nil, false
local function notify(msg) TriggerEvent('chat:addMessage', { color = { 40, 150, 255 }, args = { 'Friese-Garage', msg } }) end
RegisterNetEvent('friese-garage:client:notify', notify)
local function openGarage(id) currentGarage = id; TriggerServerEvent('friese-garage:server:requestVehicles', id) end
RegisterCommand(FrGarage.Config.OpenCommand, function()
    local ped, coords = PlayerPedId(), GetEntityCoords(PlayerPedId())
    local nearest, dist
    for id, g in pairs(FrGarage.Config.Garages) do local d = #(coords - g.point); if not dist or d < dist then nearest, dist = id, d end end
    if nearest and dist <= FrGarage.Config.InteractDistance then openGarage(nearest) else notify('Je bent niet bij een garage.') end
end, false)
RegisterNetEvent('friese-garage:client:open', function(id, label, vehicles)
    currentGarage, garageOpen = id, true; SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', garage = label, garageId = id, vehicles = vehicles })
end)
RegisterNUICallback('close', function(_, cb) garageOpen = false; SetNuiFocus(false, false); cb({ ok = true }) end)
RegisterNUICallback('spawn', function(data, cb) if currentGarage then TriggerServerEvent('friese-garage:server:spawn', tonumber(data.id), currentGarage) end; cb({ ok = true }) end)
RegisterNUICallback('store', function(_, cb)
    local ped, veh = PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false)
    if veh == 0 or GetPedInVehicleSeat(veh, -1) ~= ped then notify('Je moet als bestuurder in je voertuig zitten.'); cb({ ok = false }); return end
    local g = FrGarage.Config.Garages[currentGarage]
    if not g or #(GetEntityCoords(veh) - g.point) > FrGarage.Config.StoreDistance then notify('Je voertuig staat te ver van het inleverpunt.'); cb({ ok = false }); return end
    local props = { model = GetEntityModel(veh), plate = GetVehicleNumberPlateText(veh), engine = GetVehicleEngineHealth(veh), body = GetVehicleBodyHealth(veh), fuel = GetVehicleFuelLevel(veh), dirt = GetVehicleDirtLevel(veh), color1 = GetVehicleColours(veh) }
    TriggerServerEvent('friese-garage:server:store', props.plate, props, currentGarage)
    cb({ ok = true })
end)
RegisterNetEvent('friese-garage:client:stored', function()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false); if veh ~= 0 then SetEntityAsMissionEntity(veh, true, true); DeleteVehicle(veh) end
    notify('Voertuig veilig opgeslagen.'); if currentGarage then openGarage(currentGarage) end
end)
RegisterNetEvent('friese-garage:client:spawn', function(data)
    local model = type(data.model) == 'number' and data.model or joaat(data.model)
    if not IsModelInCdimage(model) or not IsModelAVehicle(model) then notify('Dit voertuigmodel bestaat niet.'); TriggerServerEvent('friese-garage:server:spawnFailed', data.plate); return end
    local s = data.spawn; local coords = vector3(s.x, s.y, s.z)
    if IsAnyVehicleNearPoint(coords.x, coords.y, coords.z, FrGarage.Config.SpawnClearRadius) then notify('De uitrijplek is geblokkeerd.'); TriggerServerEvent('friese-garage:server:spawnFailed', data.plate); return end
    RequestModel(model); local timeout = GetGameTimer() + 10000
    while not HasModelLoaded(model) and GetGameTimer() < timeout do Wait(50) end
    if not HasModelLoaded(model) then notify('Voertuigmodel kon niet worden geladen.'); TriggerServerEvent('friese-garage:server:spawnFailed', data.plate); return end
    local veh = CreateVehicle(model, s.x, s.y, s.z, s.w, true, false)
    if veh == 0 then notify('Voertuig kon niet worden aangemaakt.'); TriggerServerEvent('friese-garage:server:spawnFailed', data.plate); return end
    SetVehicleNumberPlateText(veh, data.plate); SetVehicleOnGroundProperly(veh)
    local p = data.props or {}; if p.engine then SetVehicleEngineHealth(veh, p.engine) end; if p.body then SetVehicleBodyHealth(veh, p.body) end; if p.fuel then SetVehicleFuelLevel(veh, p.fuel) end; if p.dirt then SetVehicleDirtLevel(veh, p.dirt) end
    TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1); SetModelAsNoLongerNeeded(model)
end)
CreateThread(function()
    for _, g in pairs(FrGarage.Config.Garages) do if g.blip then local b = AddBlipForCoord(g.point.x, g.point.y, g.point.z); SetBlipSprite(b, 357); SetBlipScale(b, 0.7); SetBlipColour(b, 3); SetBlipAsShortRange(b, true); BeginTextCommandSetBlipName('STRING'); AddTextComponentString(g.label); EndTextCommandSetBlipName(b) end end
    while true do
        local wait = 1000; local coords = GetEntityCoords(PlayerPedId())
        for id, g in pairs(FrGarage.Config.Garages) do local d = #(coords - g.point); if d < FrGarage.Config.DrawDistance then wait = 0; DrawMarker(2, g.point.x, g.point.y, g.point.z + 0.15, 0,0,0,0,0,0,0.28,0.28,0.18,35,145,255,180,false,true,2,false,nil,nil,false); if d <= FrGarage.Config.InteractDistance then BeginTextCommandDisplayHelp('STRING'); AddTextComponentSubstringPlayerName('Druk op ~INPUT_CONTEXT~ om de garage te openen'); EndTextCommandDisplayHelp(0,false,true,-1); if IsControlJustReleased(0,38) and not garageOpen then openGarage(id) end end end end
        Wait(wait)
    end
end)
