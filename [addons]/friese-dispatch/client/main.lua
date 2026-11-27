local isOpen, calls, blips = false, {}, {}

local function notify(msg, kind)
    TriggerEvent('friese-notify:client:notify', msg, kind or 'info')
end

local function openDispatch()
    if isOpen then return end
    isOpen = true
    SetNuiFocus(true, true)
    SendNUIMessage({ action = 'open', calls = calls })
    TriggerServerEvent('friese-dispatch:server:requestCalls')
end

RegisterCommand(Config.Command, function(_, args)
    local message = table.concat(args, ' ')
    if message == '' then
        AddTextEntry('FRIESE_112', 'Wat is er aan de hand?')
        DisplayOnscreenKeyboard(1, 'FRIESE_112', '', '', '', '', '', Config.MaxMessageLength)
        while UpdateOnscreenKeyboard() == 0 do Wait(0) end
        if UpdateOnscreenKeyboard() == 1 then message = GetOnscreenKeyboardResult() or '' end
    end
    if message ~= '' then TriggerServerEvent('friese-dispatch:server:createCall', message, 'police') end
end, false)

RegisterCommand(Config.DispatchCommand, openDispatch, false)
RegisterNetEvent('friese-dispatch:client:newCall', function(call)
    calls[call.id] = call
    if isOpen then SendNUIMessage({ action = 'upsert', call = call }) end
    notify(('Nieuwe 112-melding #%s ontvangen.'):format(call.id), 'info')
    local c = call.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)
    SetBlipSprite(blip, Config.Blip.sprite); SetBlipColour(blip, Config.Blip.colour)
    SetBlipScale(blip, Config.Blip.scale); SetBlipAsShortRange(blip, false)
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(('112-melding #%s'):format(call.id)); EndTextCommandSetBlipName(blip)
    blips[call.id] = blip
    CreateThread(function() Wait(Config.Blip.duration * 1000); if blips[call.id] then RemoveBlip(blips[call.id]); blips[call.id] = nil end end)
end)
RegisterNetEvent('friese-dispatch:client:syncCalls', function(list)
    calls = {}
    for _, call in ipairs(list or {}) do calls[call.id] = call end
    if isOpen then SendNUIMessage({ action = 'sync', calls = calls }) end
end)
RegisterNetEvent('friese-dispatch:client:updateCall', function(call)
    calls[call.id] = call
    if isOpen then SendNUIMessage({ action = 'upsert', call = call }) end
end)
RegisterNetEvent('friese-dispatch:client:removeCall', function(id)
    calls[id] = nil
    if isOpen then SendNUIMessage({ action = 'remove', id = id }) end
    if blips[id] then RemoveBlip(blips[id]); blips[id] = nil end
end)

RegisterNUICallback('close', function(_, cb)
    isOpen = false; SetNuiFocus(false, false); cb({ ok = true })
end)
RegisterNUICallback('accept', function(data, cb)
    TriggerServerEvent('friese-dispatch:server:acceptCall', data.id); cb({ ok = true })
end)
RegisterNUICallback('closeCall', function(data, cb)
    TriggerServerEvent('friese-dispatch:server:closeCall', data.id); cb({ ok = true })
end)
RegisterNUICallback('waypoint', function(data, cb)
    local call = calls[tonumber(data.id)]
    if call and call.coords then SetNewWaypoint(call.coords.x + 0.0, call.coords.y + 0.0) end
    cb({ ok = call ~= nil })
end)
RegisterKeyMapping(Config.DispatchCommand, 'Open Friese meldkamer', 'keyboard', 'F6')
