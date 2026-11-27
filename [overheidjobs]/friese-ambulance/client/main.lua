RegisterNetEvent('friese-ambulance:client:treat',function(kind)
 local ped=PlayerPedId()
 if kind=='revive' then local c=GetEntityCoords(ped); NetworkResurrectLocalPlayer(c.x,c.y,c.z,GetEntityHeading(ped),true,false); ClearPedBloodDamage(ped); SetEntityHealth(ped, math.max(150,GetEntityMaxHealth(ped)))
 else SetEntityHealth(ped,GetEntityMaxHealth(ped)); ClearPedBloodDamage(ped) end
end)
RegisterNetEvent('friese-ambulance:client:chooseTreatment',function(target,kind) if target then TriggerServerEvent('friese-ambulance:server:treat',target,kind) end end)
RegisterCommand('medicactie',function() TriggerEvent('friese-notify:client:notify','Gebruik /behandel [server-id] [heal|revive].','info') end)
