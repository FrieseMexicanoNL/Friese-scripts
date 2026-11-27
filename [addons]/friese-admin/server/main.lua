local function allowed(src)
    return src == 0 or IsPlayerAceAllowed(src, 'friese.admin')
end

local function notify(src, message, kind)
    TriggerClientEvent('friese-notify:client:notify', src, message, kind or 'info')
end

RegisterNetEvent('friese-admin:server:requestOpen', function()
    local src = source
    if not allowed(src) then return notify(src, 'Je hebt geen toegang tot Friese-Admin.', 'error') end
    TriggerClientEvent('friese-admin:client:open', src)
end)

RegisterNetEvent('friese-admin:server:requestPlayers', function()
    local src = source
    if not allowed(src) then return notify(src, 'Geen toegang tot het beheerpaneel.', 'error') end
    local players = {}
    for _, id in ipairs(GetPlayers()) do
        local target = tonumber(id)
        local player = exports['friese-core']:GetPlayer(target)
        local data = player and player.PlayerData or {}
        players[#players + 1] = {
            id = target,
            name = GetPlayerName(target) or 'Onbekend',
            citizenid = data.citizenid or '-',
            job = data.job and data.job.label or 'Niet geladen',
            ping = GetPlayerPing(target)
        }
    end
    TriggerClientEvent('friese-admin:client:players', src, players)
end)

RegisterNetEvent('friese-admin:server:action', function(action, target, value)
    local src = source
    if not allowed(src) then return notify(src, 'Geen toestemming.', 'error') end
    target = tonumber(target)
    if not target or not GetPlayerName(target) then return notify(src, 'Speler niet gevonden.', 'error') end
    local actor = GetPlayerName(src) or 'Console'
    local targetName = GetPlayerName(target)
    if action == 'kick' then
        local reason = type(value) == 'string' and value:sub(1, 120) or 'Verwijderd door een beheerder'
        DropPlayer(target, reason)
    elseif action == 'heal' then
        TriggerClientEvent('friese-admin:client:heal', target)
    elseif action == 'freeze' then
        TriggerClientEvent('friese-admin:client:freeze', target)
    elseif action == 'bring' then
        if src == 0 or src == target then return end
        local ped = GetPlayerPed(src)
        local coords = GetEntityCoords(ped)
        TriggerClientEvent('friese-admin:client:teleport', target, { x = coords.x, y = coords.y, z = coords.z })
    elseif action == 'goto' then
        if src == 0 or src == target then return end
        local ped = GetPlayerPed(target)
        local coords = GetEntityCoords(ped)
        TriggerClientEvent('friese-admin:client:teleport', src, { x = coords.x, y = coords.y, z = coords.z })
    else
        return notify(src, 'Onbekende beheeractie.', 'error')
    end
    print(('[Friese-Admin] %s (%s) gebruikte %s op %s (%s)'):format(actor, src, action, targetName, target))
    notify(src, ('Actie %s uitgevoerd op %s.'):format(action, targetName), 'success')
end)

RegisterCommand('frieseadmin', function(src)
    if src == 0 then return print('Open het beheerpaneel in-game met /admin.') end
    if not allowed(src) then return notify(src, 'Je hebt geen toegang tot Friese-Admin.', 'error') end
    TriggerClientEvent('friese-admin:client:open', src)
end, false)
