RegisterNetEvent('friese-business:client:message',function(msg) TriggerEvent('friese-notify:client:notify',{title='Bedrijf',description=msg,type='info'}) end)
