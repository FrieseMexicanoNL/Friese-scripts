local cuffed=false
RegisterNetEvent('friese-police:client:setCuffed',function(state)
 cuffed=state; local ped=PlayerPedId(); SetEnableHandcuffs(ped,state); DisablePlayerFiring(PlayerId(),state)
 if state then ClearPedTasks(ped) end
end)
CreateThread(function() while true do if cuffed then DisableControlAction(0,24,true); DisableControlAction(0,25,true); DisableControlAction(0,23,true); DisableControlAction(0,75,true); Wait(0) else Wait(500) end end end)
RegisterNetEvent('friese-police:client:jail',function(minutes,reason)
 TriggerEvent('friese-notify:client:notify',('Je bent aangehouden voor %s minuten. %s'):format(minutes,reason),'error')
 -- Detentiecoördinaten/interieur zijn server-configuratieafhankelijk; hier wordt geen fictieve teleport uitgevoerd.
end)
RegisterNetEvent('friese-police:client:requestFine',function(target,amount,reason)
 if target and amount and amount>0 then TriggerServerEvent('friese-police:server:fine',target,amount,reason) end
end)
RegisterCommand('politieactie',function() TriggerEvent('friese-notify:client:notify','Gebruik /boete [id] [bedrag] [reden] of /boeien [id].','info') end)
