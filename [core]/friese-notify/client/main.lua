local function notify(message, kind, duration)
    SendNUIMessage({ action = 'notify', message = tostring(message or ''), kind = kind or 'info', duration = math.max(1500, math.min(tonumber(duration) or 4000, 10000)) })
end
RegisterNetEvent('friese-notify:client:notify', function(message, kind, duration) notify(message, kind, duration) end)
RegisterNetEvent('friese-notify:client:success', function(message) notify(message, 'success') end)
RegisterNetEvent('friese-notify:client:error', function(message) notify(message, 'error') end)
RegisterNetEvent('friese-notify:client:info', function(message) notify(message, 'info') end)
exports('Notify', notify)
