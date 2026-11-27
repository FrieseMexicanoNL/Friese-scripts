local open=false
local function setOpen(state)
    open=state; SetNuiFocus(state,state)
    if state then SendNUIMessage({action='open'}); TriggerServerEvent('friese-phone:server:bootstrap') else SendNUIMessage({action='close'}) end
end
RegisterCommand(Config.Command,function() setOpen(not open) end,false)
RegisterKeyMapping(Config.Command,'Open Friese-Phone','keyboard',Config.Key)
RegisterNetEvent('friese-phone:client:bootstrap',function(data) if open then SendNUIMessage({action='bootstrap',data=data}) end end)
RegisterNetEvent('friese-phone:client:refresh',function() if open then TriggerServerEvent('friese-phone:server:bootstrap') end end)
RegisterNetEvent('friese-phone:client:incomingMessage',function(data) TriggerEvent('friese-notify:client:notify','Nieuw bericht van '..data.sender,'info'); SendNUIMessage({action='incomingMessage',data=data}) end)
RegisterNetEvent('friese-phone:client:incomingCall',function(data) TriggerEvent('friese-notify:client:notify','Inkomende oproep: '..data.number,'info'); SendNUIMessage({action='incomingCall',data=data}) end)
RegisterNUICallback('close',function(_,cb) setOpen(false); cb({ok=true}) end)
RegisterNUICallback('addContact',function(d,cb) TriggerServerEvent('friese-phone:server:addContact',d.name,d.phone); cb({ok=true}) end)
RegisterNUICallback('deleteContact',function(d,cb) TriggerServerEvent('friese-phone:server:deleteContact',d.id); cb({ok=true}) end)
RegisterNUICallback('sendMessage',function(d,cb) TriggerServerEvent('friese-phone:server:sendMessage',d.phone,d.message); cb({ok=true}) end)
RegisterNUICallback('call',function(d,cb) TriggerServerEvent('friese-phone:server:call',d.phone); cb({ok=true}) end)
RegisterNUICallback('service',function(d,cb) if d.service=='dispatch' then ExecuteCommand('meldkamer') elseif d.service=='emergency' then ExecuteCommand('112') end; cb({ok=true}) end)
CreateThread(function() while true do Wait(0); if open and IsControlJustReleased(0,200) then setOpen(false) end end end)
