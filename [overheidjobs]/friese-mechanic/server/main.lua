local function mechanic(src) local p=exports['friese-core']:GetPlayer(src); return p and p.PlayerData.job and MechanicConfig.Jobs[p.PlayerData.job.name] end
RegisterNetEvent('friese-mechanic:server:repair',function(netId,plate)
 local src=source; if not mechanic(src) then return end; netId=tonumber(netId); if not netId then return end
 local veh=NetworkGetEntityFromNetworkId(netId); if veh==0 or not DoesEntityExist(veh) or GetEntityType(veh)~=2 then return end
 local ped=GetPlayerPed(src); if ped==0 or #(GetEntityCoords(ped)-GetEntityCoords(veh))>MechanicConfig.RepairDistance then return end
 local p=exports['friese-core']:GetPlayer(src); if not exports['friese-core']:RemoveMoney(src,'bank',MechanicConfig.RepairCost,'Voertuigreparatie') then TriggerClientEvent('friese-notify:client:notify',src,'Onvoldoende banksaldo.','error'); return end
 TriggerClientEvent('friese-mechanic:client:repair',src,netId)
 MySQL.insert('INSERT INTO friese_vehicle_services (citizenid,plate,service_type,cost) VALUES (?,?,?,?)',{p.PlayerData.citizenid,tostring(plate or 'ONBEKEND'):sub(1,16),'repair',MechanicConfig.RepairCost})
 TriggerEvent('friese-mechanic:server:serviceCompleted',src,p.PlayerData.citizenid,tostring(plate or 'ONBEKEND'), 'repair',MechanicConfig.RepairCost)
end)
RegisterCommand('repareer',function(src) if src~=0 and mechanic(src) then TriggerClientEvent('friese-mechanic:client:requestRepair',src) end end)
exports('IsMechanic',mechanic)
