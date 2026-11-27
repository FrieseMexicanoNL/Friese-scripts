local opened, spawning, hasSpawned = false, false, false
local function closeUi()
    opened = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNetEvent('friese-spawn:client:open', function()
    if opened or spawning or hasSpawned or not Friese or not Friese.IsLoaded then return end
    opened = true
    DoScreenFadeOut(250); Wait(350)
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true); SetEntityVisible(ped, false, false)
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', locations = FrieseSpawn.Locations })
    DoScreenFadeIn(400)
end)

RegisterNetEvent('friese-spawn:client:complete', function(loc)
    if spawning or hasSpawned or type(loc) ~= 'table' or not loc.x or not loc.y or not loc.z then return end
    spawning = true; closeUi(); DoScreenFadeOut(400); Wait(500)
    local ped = PlayerPedId()
    RequestCollisionAtCoord(loc.x, loc.y, loc.z)
    SetEntityCoordsNoOffset(ped, loc.x, loc.y, loc.z, false, false, false)
    SetEntityHeading(ped, loc.w or 0.0)
    local deadline = GetGameTimer() + 12000
    while not HasCollisionLoadedAroundEntity(ped) and GetGameTimer() < deadline do
        RequestCollisionAtCoord(loc.x, loc.y, loc.z); Wait(50)
    end
    SetEntityVisible(ped, true, false); FreezeEntityPosition(ped, false)
    SetEntityInvincible(ped, false); ClearPedTasksImmediately(ped)
    ShutdownLoadingScreen(); ShutdownLoadingScreenNui()
    DoScreenFadeIn(800)
    hasSpawned = true; spawning = false
    TriggerEvent('friese-spawn:client:spawned', loc.id)
end)

RegisterNUICallback('selectSpawn', function(data, cb)
    if not opened or spawning or type(data) ~= 'table' or type(data.id) ~= 'string' then cb({ ok = false }); return end
    TriggerServerEvent('friese-spawn:server:select', data.id)
    cb({ ok = true })
end)
RegisterNUICallback('close', function(_, cb) cb({ ok = false }) end)

AddEventHandler('friese-core:client:playerUnloaded', function()
    hasSpawned = false; spawning = false; closeUi()
end)
