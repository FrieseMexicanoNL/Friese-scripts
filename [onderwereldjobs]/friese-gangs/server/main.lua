local function player(src) local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end); return ok and p or nil end
local function notify(src,msg,kind) TriggerClientEvent('friese-notify:client:notify',src,{title='Friese-Core',description=msg,type=kind or 'info'}) end

RegisterNetEvent('friese-gangs:server:invite',function(target,gang)
 local src=source; target=tonumber(target); local p=player(src); local t=player(target); if not p or not t or not Config.Gangs[gang] then return end
 local member=MySQL.single.await('SELECT grade FROM friese_gang_members WHERE citizenid=? AND gang=? LIMIT 1',{p.PlayerData.citizenid,gang}); local grade=member and tonumber(member.grade) or -1; if grade>=Config.LeaderGrade then TriggerClientEvent('friese-gangs:client:invited',target,gang,src); notify(src,'Uitnodiging verstuurd.','success') end
end)
RegisterNetEvent('friese-gangs:server:accept',function(gang)
 local src=source; local p=player(src); if not p or not Config.Gangs[gang] then return end
 MySQL.insert.await('INSERT INTO friese_gang_members (citizenid,gang,grade) VALUES (?,?,0) ON DUPLICATE KEY UPDATE gang=VALUES(gang), grade=0',{p.PlayerData.citizenid,gang}); TriggerEvent('friese-core:server:gangUpdated',src,{name=gang,grade=0}); notify(src,'Je bent lid geworden van '..Config.Gangs[gang].label,'success')
end)

