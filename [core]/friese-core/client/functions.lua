Friese = Friese or {}
local callbacks, callbackId = {}, 0
RegisterNetEvent('friese-core:client:callbackResponse', function(id, result)
    local cb = callbacks[id]; if not cb then return end
    callbacks[id] = nil; cb(result)
end)
function Friese.TriggerCallback(name, callback, ...)
    callbackId = callbackId + 1; callbacks[callbackId] = callback or function() end
    TriggerServerEvent('friese-core:server:triggerCallback', name, callbackId, ...)
end
exports('TriggerCallback', Friese.TriggerCallback)
