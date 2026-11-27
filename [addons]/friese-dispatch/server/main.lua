local activeCalls, cooldowns, nextId = {}, {}, 0

local function notify(src, msg, kind)
    TriggerClientEvent('friese-notify:client:notify', src, msg, kind or 'info')
end

local function getPlayerData(src)
    local player = exports['friese-core']:GetPlayer(src)
    return player and player.PlayerData or nil
end

local function isDispatcher(src)
    local data = getPlayerData(src)
    return data and data.job and Config.DispatchJobs[data.job.name] == true
end

local function dispatchRecipients()
    local recipients = {}
    for _, id in ipairs(GetPlayers()) do
        local src = tonumber(id)
        if isDispatcher(src) then recipients[#recipients + 1] = src end
    end
    return recipients
end

RegisterNetEvent('friese-dispatch:server:createCall', function(message, category)
    local src = source
    local now = os.time()
    if type(message) ~= 'string' then return end
    message = message:gsub('[\r\n]', ' '):gsub('%s+', ' '):sub(1, Config.MaxMessageLength)
    if message == '' then notify(src, Config.Text.noMessage, 'error'); return end
    local remaining = (cooldowns[src] or 0) - now
    if remaining > 0 then notify(src, Config.Text.cooldown:format(remaining), 'error'); return end

    local ped = GetPlayerPed(src)
    if ped == 0 then return end
    local coords = GetEntityCoords(ped)
    local data = getPlayerData(src) or {}
    local charinfo = data.charinfo or {}
    local caller = ((charinfo.firstname or '') .. ' ' .. (charinfo.lastname or '')):gsub('^%s*(.-)%s*$', '%1')
    if caller == '' then caller = GetPlayerName(src) or ('Speler ' .. src) end

    local dbId = MySQL.insert.await('INSERT INTO friese_dispatch_calls (caller_citizenid, caller_name, message, category, x, y, z, created_at, status) VALUES (?, ?, ?, ?, ?, ?, ?, NOW(), \'open\')', {
        data.citizenid or 'unknown', caller, message, (category == 'ambulance' and 'ambulance' or 'police'), coords.x, coords.y, coords.z
    })
    if not dbId then notify(src, 'Melding kon niet worden opgeslagen. Probeer opnieuw.', 'error'); return end
    nextId = tonumber(dbId)
    local call = {
        id = nextId, caller = caller, source = src, message = message,
        category = (category == 'ambulance' and 'ambulance' or 'police'),
        coords = { x = coords.x, y = coords.y, z = coords.z },
        created = now, status = 'open', acceptedBy = nil
    }
    activeCalls[call.id] = call
    cooldowns[src] = now + Config.CooldownSeconds
    for _, recipient in ipairs(dispatchRecipients()) do
        TriggerClientEvent('friese-dispatch:client:newCall', recipient, call)
    end
    notify(src, Config.Text.sent, 'success')
    TriggerEvent('friese-dispatch:server:callCreated', call)
end)

RegisterNetEvent('friese-dispatch:server:requestCalls', function()
    local src = source
    if not isDispatcher(src) then notify(src, Config.Text.noPermission, 'error'); return end
    local list = {}
    for _, call in pairs(activeCalls) do list[#list + 1] = call end
    TriggerClientEvent('friese-dispatch:client:syncCalls', src, list)
end)

RegisterNetEvent('friese-dispatch:server:acceptCall', function(id)
    local src = source
    if not isDispatcher(src) then return end
    id = tonumber(id)
    local call = id and activeCalls[id]
    if not call then return end
    if call.acceptedBy and call.acceptedBy ~= src then notify(src, Config.Text.taken, 'error'); return end
    call.acceptedBy = src
    call.status = 'accepted'
    call.assignee = GetPlayerName(src) or ('ID ' .. src)
    MySQL.update('UPDATE friese_dispatch_calls SET status = ?, accepted_by = ? WHERE id = ?', {'accepted', tostring(src), call.id})
    for _, recipient in ipairs(dispatchRecipients()) do
        TriggerClientEvent('friese-dispatch:client:updateCall', recipient, call)
    end
    notify(src, Config.Text.accepted, 'success')
    TriggerEvent('friese-dispatch:server:callAccepted', call, src)
end)

RegisterNetEvent('friese-dispatch:server:closeCall', function(id)
    local src = source
    if not isDispatcher(src) then return end
    id = tonumber(id)
    local call = id and activeCalls[id]
    if not call or (call.acceptedBy and call.acceptedBy ~= src) then return end
    activeCalls[id] = nil
    MySQL.update('UPDATE friese_dispatch_calls SET status = ?, closed_at = NOW() WHERE id = ?', {'closed', id})
    for _, recipient in ipairs(dispatchRecipients()) do
        TriggerClientEvent('friese-dispatch:client:removeCall', recipient, id)
    end
    TriggerEvent('friese-dispatch:server:callClosed', call, src)
end)

AddEventHandler('playerDropped', function()
    local src = source
    cooldowns[src] = nil
    for id, call in pairs(activeCalls) do
        if call.source == src then
            activeCalls[id] = nil
            MySQL.update('UPDATE friese_dispatch_calls SET status = ?, closed_at = NOW() WHERE id = ?', {'cancelled', id})
        elseif call.acceptedBy == src then
            call.acceptedBy, call.status, call.assignee = nil, 'open', nil
            MySQL.update('UPDATE friese_dispatch_calls SET status = ?, accepted_by = NULL WHERE id = ?', {'open', id})
        end
    end
end)
