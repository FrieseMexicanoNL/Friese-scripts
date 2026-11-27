local lastCheckIn = {}
local function getPlayer(src) return exports['friese-core']:GetPlayer(src) end
local function isMedic(src)
 local p=getPlayer(src); return p and p.PlayerData.job and HospitalConfig.Jobs[p.PlayerData.job.name]==true
end
local function clean(v,max) if type(v)~='string' then return '' end return v:gsub('[%c]',' '):sub(1,max) end
RegisterNetEvent('friese-hospital:server:checkIn',function()
 local src=source; local p=getPlayer(src); if not p then return end
 local now=os.time(); if lastCheckIn[src] and now-lastCheckIn[src]<HospitalConfig.CheckInCooldown then TriggerClientEvent('friese-notify:client:notify',src,'Je moet nog even wachten voordat je opnieuw kunt inchecken.','error'); return end
 local ped=GetPlayerPed(src); if ped==0 then return end
 local pos=GetEntityCoords(ped); local valid=false
 for _,loc in ipairs(HospitalConfig.Locations) do if #(pos-loc.coords)<=loc.radius then valid=true break end end
 if not valid then TriggerClientEvent('friese-notify:client:notify',src,'Je moet bij een ziekenhuisbalie staan.','error'); return end
 if not exports['friese-core']:RemoveMoney(src,'bank',HospitalConfig.CheckInPrice,'Ziekenhuis inschrijving') then TriggerClientEvent('friese-notify:client:notify',src,'Onvoldoende saldo op je bankrekening.','error'); return end
 lastCheckIn[src]=now
 TriggerClientEvent('friese-hospital:client:checkIn',src,HospitalConfig.CheckInDuration)
end)
RegisterNetEvent('friese-hospital:server:addRecord',function(target,summary)
 local src=source; target=tonumber(target); if not isMedic(src) or not target then return end
 local officer,patient=getPlayer(src),getPlayer(target); if not patient then return end
 local a,b=GetPlayerPed(src),GetPlayerPed(target); if a==0 or b==0 or #(GetEntityCoords(a)-GetEntityCoords(b))>4.0 then return end
 summary=clean(summary,HospitalConfig.MaxRecordLength); if #summary<4 then return end
 MySQL.insert.await('INSERT INTO friese_medical_records (medic_citizenid,patient_citizenid,treatment) VALUES (?,?,?)',{officer.PlayerData.citizenid,patient.PlayerData.citizenid,summary})
 TriggerClientEvent('friese-notify:client:notify',src,'Medisch dossier bijgewerkt.','success')
end)
RegisterNetEvent('friese-hospital:server:getRecords',function(target)
 local src=source; target=tonumber(target); if not isMedic(src) or not target then return end
 local patient=getPlayer(target); if not patient then return end
 local rows=MySQL.query.await('SELECT medic_citizenid,treatment,created_at FROM friese_medical_records WHERE patient_citizenid=? ORDER BY id DESC LIMIT 30',{patient.PlayerData.citizenid}) or {}
 TriggerClientEvent('friese-hospital:client:records',src,target,rows)
end)
AddEventHandler('playerDropped',function() lastCheckIn[source]=nil end)
