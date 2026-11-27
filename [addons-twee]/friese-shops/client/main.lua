RegisterNetEvent('friese-gangs:client:invited',function(gang,from) TriggerEvent('chat:addMessage',{args={'Friese-Gangs','Je bent uitgenodigd voor '..gang..'. Gebruik /gangaccepteer '..gang}}) end)
RegisterCommand('gangaccepteer',function(_,a) if a[1] then TriggerServerEvent('friese-gangs:server:accept',a[1]) end end)
