RegisterNetEvent('friese-mechanic:client:requestRepair',function()
 local ped=PlayerPedId(); local veh=GetVehiclePedIsIn(ped,false); if veh==0 then veh=GetClosestVehicle(GetEntityCoords(ped),4.0,0,70) end
 if veh==0 then TriggerEvent('friese-notify:client:notify','Geen voertuig dichtbij.','error'); return end
 TriggerServerEvent('friese-mechanic:server:repair',NetworkGetNetworkIdFromEntity(veh),GetVehicleNumberPlateText(veh))
end)
RegisterNetEvent('friese-mechanic:client:repair',function(netId)
 local veh=NetToVeh(netId); if veh==0 or not DoesEntityExist(veh) then return end
 SetVehicleFixed(veh); SetVehicleDeformationFixed(veh); SetVehicleEngineHealth(veh,1000.0); SetVehicleBodyHealth(veh,1000.0); SetVehicleDirtLevel(veh,0.0)
 TriggerEvent('friese-notify:client:notify','Voertuig gerepareerd.','success')
end)
