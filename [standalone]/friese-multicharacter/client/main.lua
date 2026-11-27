local uiOpen = false

local function setUi(state)
    uiOpen = state
    SetNuiFocus(state, state)
    SendNUIMessage({ action = state and 'show' or 'hide' })
end

RegisterNetEvent('friese-multicharacter:client:open', function(characters, maxSlots)
    if Friese and Friese.IsLoaded then return end
    DoScreenFadeOut(250)
    Wait(300)
    FreezeEntityPosition(PlayerPedId(), true)
    SetEntityVisible(PlayerPedId(), false, false)
    SendNUIMessage({ action = 'characters', characters = characters or {}, maxSlots = maxSlots or 4 })
    setUi(true)
    DoScreenFadeIn(500)
end)

RegisterNetEvent('friese-multicharacter:client:characterSelected', function(spawn)
    setUi(false)
    DoScreenFadeOut(500)
    Wait(600)
    local ped = PlayerPedId()
    local coords = spawn or { x = -1037.72, y = -2737.85, z = 20.17, heading = 329.0 }
    SetEntityCoordsNoOffset(ped, coords.x, coords.y, coords.z, false, false, false)
    SetEntityHeading(ped, coords.heading or 0.0)
    SetEntityVisible(ped, true, false)
    FreezeEntityPosition(ped, false)
    SetEntityHealth(ped, GetEntityMaxHealth(ped))
    ClearPedBloodDamage(ped)
    ShutdownLoadingScreen()
    ShutdownLoadingScreenNui()
    DoScreenFadeIn(1000)
end)

RegisterNetEvent('friese-multicharacter:client:notify', function(message)
    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, false)
end)

RegisterNUICallback('close', function(_, cb) cb({ ok = false }) end)
RegisterNUICallback('createCharacter', function(data, cb)
    TriggerServerEvent('friese-multicharacter:server:createCharacter', data)
    cb({ ok = true })
end)
RegisterNUICallback('selectCharacter', function(data, cb)
    if type(data.citizenid) == 'string' then TriggerServerEvent('friese-multicharacter:server:selectCharacter', data.citizenid) end
    cb({ ok = true })
end)

CreateThread(function()
    while true do
        if uiOpen then
            DisableAllControlActions(0)
            EnableControlAction(0, 1, true)
            EnableControlAction(0, 2, true)
            Wait(0)
        else Wait(500) end
    end
end)
