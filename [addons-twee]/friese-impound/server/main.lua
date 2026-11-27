local function getPlayer(src) return exports['friese-core']:GetPlayer(src) end
local function isPolice(src)
 local p=getPlayer(src); return p and p.PlayerData.job and ImpoundConfig.PoliceJobs[p.PlayerData.job.name]==true
end
local function cleanPlate(v) return type(v)=='string' and v:upper():gsub('%s+',''):sub(1,12) or '' end
RegisterNetEvent('friese-impound:server:impound',function(netId,reason,fee)
 local src=source; if not isPolice(src) then return end
 netId=tonumber(netId); fee=math.floor(tonumber(fee) or ImpoundConfig.DefaultFee); reason=type(reason)=='string' and reason:gsub('[%c]',' '):sub(1,160) or 'Inbeslagname'
 if not netId or fee<0 or fee>ImpoundConfig.MaxFee then return end
 local veh=NetworkGetEntityFromNetworkId(netId); if veh==0 or not DoesEntityExist(veh) or GetEntityType(veh)~=2 then return end
 local ped=GetPlayerPed(src); if ped==0 or #(GetEntityCoords(ped)-GetEntityCoords(veh))>ImpoundConfig.MaxDistance then return end
 local plate=cleanPlate(GetVehicleNumberPlateText(veh)); if plate=='' then return end
 local row=MySQL.single.await('SELECT citizenid FROM friese_vehicles WHERE REPLACE(UPPER(plate),\' \',\'\')=? LIMIT 1',{plate})
 if not row then TriggerClientEvent('friese-notify:client:notify',src,'Dit voertuig staat niet geregistreerd in Friese-Garage.','error'); return end
 local officer=getPlayer(src)
 MySQL.update.await('UPDATE friese_vehicles SET state=2, garage=? WHERE REPLACE(UPPER(plate),\' \',\'\')=?',{ImpoundConfig.ImpoundGarage,plate})
 MySQL.insert.await('INSERT INTO friese_impound_records (plate,owner_citizenid,officer_citizenid,reason,fee) VALUES (?,?,?,?,?)',{plate,row.citizenid,officer.PlayerData.citizenid,reason,fee})
 DeleteEntity(veh)
 MySQL.insert.await('INSERT INTO friese_police_actions (officer_citizenid,target_citizenid,action,details) VALUES (?,?,?,?)', {officer.PlayerData.citizenid,row.citizenid,'voertuig_inbeslaggenomen',json.encode({plate=plate,reason=reason,fee=fee})})
 TriggerEvent('friese-impound:server:vehicleImpounded',src,plate,row.citizenid,reason,fee)
 TriggerClientEvent('friese-notify:client:notify',src,('Voertuig %s in beslag genomen.'):format(plate),'success')
end)
RegisterNetEvent('friese-impound:server:release',function(rawPlate)
 local src=source; local p=getPlayer(src); if not p then return end
 local plate=cleanPlate(rawPlate); if plate=='' then return end
 local row=MySQL.single.await([[SELECT v.citizenid, i.fee FROM friese_vehicles v
 LEFT JOIN friese_impound_records i ON i.plate=v.plate AND i.released_at IS NULL
 WHERE REPLACE(UPPER(v.plate),' ','')=? AND v.state=2 ORDER BY i.id DESC LIMIT 1]],{plate})
 if not row or row.citizenid~=p.PlayerData.citizenid then TriggerClientEvent('friese-notify:client:notify',src,'Dit voertuig staat niet op jouw naam of is niet in beslag genomen.','error'); return end
 local fee=tonumber(row.fee) or ImpoundConfig.DefaultFee
 if fee>0 and not exports['friese-core']:RemoveMoney(src,'bank',fee,'Vrijgave inbeslaggenomen voertuig') then TriggerClientEvent('friese-notify:client:notify',src,'Onvoldoende saldo om het voertuig vrij te geven.','error'); return end
 MySQL.update.await('UPDATE friese_vehicles SET state=1, garage=? WHERE REPLACE(UPPER(plate),\' \',\'\')=?',{ImpoundConfig.ImpoundGarage,plate})
 MySQL.update.await('UPDATE friese_impound_records SET released_at=CURRENT_TIMESTAMP WHERE plate=? AND released_at IS NULL',{plate})
 TriggerClientEvent('friese-notify:client:notify',src,('Voertuig %s is vrijgegeven. Haal het op bij de inbeslagnamegarage.'):format(plate),'success')
end)
exports('IsPolice',isPolice)
