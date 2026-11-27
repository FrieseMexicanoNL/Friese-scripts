local function isManager(p) return p and p.PlayerData and (p.PlayerData.job.grade or 0) >= 3 end
RegisterNetEvent('friese-business:server:hire', function(targetId, job, grade)
 local src=source; targetId=tonumber(targetId); grade=tonumber(grade) or 0; if not targetId or targetId==src or grade<0 or grade>20 then return end
 local boss=exports['friese-core']:GetPlayer(src); local employee=exports['friese-core']:GetPlayer(targetId)
 if not isManager(boss) or not employee or not job or #job>40 then return end
 local ok=exports['friese-core']:SetJob(targetId, job, grade); if ok then exports['friese-core']:SavePlayer(targetId); TriggerClientEvent('friese-business:client:message',src,'Medewerker succesvol aangenomen.'); TriggerClientEvent('friese-business:client:message',targetId,'Je hebt een nieuwe functie gekregen.') end
end)
RegisterNetEvent('friese-business:server:fire', function(targetId)
 local src=source; targetId=tonumber(targetId); local boss=exports['friese-core']:GetPlayer(src); local employee=targetId and exports['friese-core']:GetPlayer(targetId)
 if not isManager(boss) or not employee or employee.PlayerData.job.name~=boss.PlayerData.job.name then return end
 exports['friese-core']:SetJob(targetId,'unemployed',0); exports['friese-core']:SavePlayer(targetId); TriggerClientEvent('friese-business:client:message',targetId,'Je bent uit dienst gezet.')
end)
