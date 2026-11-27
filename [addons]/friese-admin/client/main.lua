local isOpen, frozen = false, false

local function setOpen(state)
    isOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'open' or 'close' })
    if state then TriggerServerEvent('friese-admin:server:requestPlayers') end
end

RegisterNetEvent('friese-admin:client:open', function() setOpen(true) end)
RegisterNetEvent('friese-admin:client:players', function(players)
    SendNUIMessage({ action = 'players', players = players })
end)
RegisterNetEvent('friese-admin:client:heal', function()
    local ped = PlayerPedId()
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
end)
RegisterNetEvent('friese-admin:client:freeze', function()
    frozen = not frozen
    FreezeEntityPosition(PlayerPedId(), frozen)
end)
RegisterNetEvent('friese-admin:client:teleport', function(coords)
    if type(coords) ~= 'table' then return end
    local ped = PlayerPedId()
    SetEntityCoords(ped, coords.x + 0.0, coords.y + 0.0, coords.z + 0.5, false, false, false, false)
end)

RegisterNUICallback('close', function(_, cb) setOpen(false); cb({ ok = true }) end)
RegisterNUICallback('refresh', function(_, cb) TriggerServerEvent('friese-admin:server:requestPlayers'); cb({ ok = true }) end)
RegisterNUICallback('action', function(data, cb)
    if type(data) == 'table' then TriggerServerEvent('friese-admin:server:action', data.action, data.target, data.value) end
    cb({ ok = true })
end)
RegisterCommand('admin', function() TriggerServerEvent('friese-admin:server:requestOpen') end, false)
RegisterNetEvent('friese-admin:client:forceClose', function() setOpen(false) end)
CreateThread(function()
    while true do
        if isOpen and IsControlJustReleased(0, 200) then setOpen(false) end
        Wait(isOpen and 0 or 500)
    end
end)
