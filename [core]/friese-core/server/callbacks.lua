Friese = Friese or {}
Friese.ServerCallbacks = {}
RegisterNetEvent('friese-core:server:triggerCallback', function(name, requestId, ...)
    local src = source
    if type(name) ~= 'string' or type(requestId) ~= 'number' then return end
    local callback = Friese.ServerCallbacks[name]
    if not callback then
        TriggerClientEvent('friese-core:client:callbackResponse', src, requestId, nil); return
    end
    local ok, result = pcall(callback, src, ...)
    if not ok then print(('^1[Friese-Core] Callback %s failed: %s^7'):format(name, tostring(result))); result = nil end
    TriggerClientEvent('friese-core:client:callbackResponse', src, requestId, result)
end)
function Friese.CreateCallback(name, callback)
    assert(type(name) == 'string' and type(callback) == 'function', 'Invalid callback registration')
    Friese.ServerCallbacks[name] = callback
end
