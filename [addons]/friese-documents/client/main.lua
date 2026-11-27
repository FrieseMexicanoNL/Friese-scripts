local shown = false
local function closeDoc()
    shown = false; SetNuiFocus(false,false); SendNUIMessage({action='close'})
end
RegisterNetEvent('friese-documents:client:show', function(doc, owner)
    shown = true; SetNuiFocus(true,true); SendNUIMessage({action='show', document=doc, owner=owner})
end)
RegisterCommand(Documents.Config.Command, function() TriggerServerEvent('friese-documents:server:requestOwn','id') end)
RegisterCommand('rijbewijs', function() TriggerServerEvent('friese-documents:server:requestOwn','driver') end)
RegisterCommand('wapenvergunning', function() TriggerServerEvent('friese-documents:server:requestOwn','weapon') end)
RegisterCommand(Documents.Config.ShowCommand, function(_,args)
    local target=tonumber(args[1]); local kind=args[2] or 'id'
    if not target then TriggerEvent('chat:addMessage',{args={'Friese','Gebruik: /toondocument [server-id] [id|driver|weapon]'} }); return end
    TriggerServerEvent('friese-documents:server:showTo',target,kind)
end)
RegisterNUICallback('close', function(_,cb) closeDoc(); cb({ok=true}) end)
RegisterKeyMapping(Documents.Config.Command,'Open je identiteitskaart','keyboard','F7')
