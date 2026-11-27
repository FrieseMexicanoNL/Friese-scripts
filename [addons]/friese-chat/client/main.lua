local isOpen = false
RegisterNetEvent('friese-chat:client:message', function(data) SendNUIMessage({ action='message', data=data }) end)
RegisterNetEvent('friese-chat:client:clear', function() SendNUIMessage({action='clear'}) end)
RegisterNetEvent('friese-chat:client:teleport', function(coords) SetEntityCoords(PlayerPedId(), coords.x, coords.y, coords.z, false, false, false, false) end)
RegisterCommand('chat', function() isOpen=true; SetNuiFocus(true,true); SendNUIMessage({action='open'}) end)
RegisterKeyMapping('chat','Open Friese chat','keyboard','T')
RegisterNUICallback('close',function(_,cb) isOpen=false;SetNuiFocus(false,false);cb({ok=true}) end)
RegisterNUICallback('send',function(data,cb) TriggerServerEvent('friese-chat:server:send',tostring(data.message or '')); cb({ok=true}) end)
RegisterNetEvent('friese-chat:client:notify',function(msg) TriggerEvent('friese-notify:client:notify',{type='info',description=msg}) end)
