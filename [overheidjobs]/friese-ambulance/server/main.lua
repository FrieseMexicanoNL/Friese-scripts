local last={}
local function medic(src) local p=exports['friese-core']:GetPlayer(src); return p and p.PlayerData.job and AmbulanceConfig.Jobs[p.PlayerData.job.name] end
RegisterNetEvent('friese-ambulance:server:treat',function(target,kind)
 local src=source; target=tonumber(target); if not medic(src) or not target or target==src then return end
 local a,b=GetPlayerPed(src),GetPlayerPed(target); if a==0 or b==0 or #(GetEntityCoords(a)-GetEntityCoords(b))>AmbulanceConfig.MaxTreatmentDistance then return end
 local now=GetGameTimer(); if last[src] and now-last[src]<AmbulanceConfig.HealCooldown then return end; last[src]=now
 if kind~='heal' and kind~='revive' then return end
 TriggerClientEvent('friese-ambulance:client:treat',target,kind)
 local p=exports['friese-core']:GetPlayer(src); local q=exports['friese-core']:GetPlayer(target)
 MySQL.insert('INSERT INTO friese_medical_records (medic_citizenid,patient_citizenid,treatment) VALUES (?,?,?)',{p.PlayerData.citizenid,q.PlayerData.citizenid,kind})
 TriggerEvent('friese-ambulance:server:treatmentCompleted',src,target,p.PlayerData.citizenid,q.PlayerData.citizenid,kind)
 TriggerClientEvent('friese-notify:client:notify',src,'Behandeling uitgevoerd.','success')
end)
RegisterCommand('behandel',function(src,args) if src~=0 and medic(src) then TriggerClientEvent('friese-ambulance:client:chooseTreatment',src,tonumber(args[1]),args[2] or 'heal') end end)
exports('IsMedic',medic)
