local function player(src) local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end); return ok and p or nil end
local function notify(src,msg,kind) TriggerClientEvent('friese-notify:client:notify',src,{title='Friese-Core',description=msg,type=kind or 'info'}) end

RegisterNetEvent('friese-keys:server:grant',function(kind,key,target)
 local src=source; target=tonumber(target); local p=player(src); local t=player(target); if not p or not t or (kind~='vehicle' and kind~='house') then return end
 key=tostring(key or ''):upper():sub(1,16); if #key<2 then return end
 local allowed=false
 if kind=='vehicle' then allowed=MySQL.scalar.await('SELECT 1 FROM friese_vehicles WHERE plate=? AND citizenid=? LIMIT 1',{key,p.PlayerData.citizenid})~=nil
 else allowed=MySQL.scalar.await('SELECT 1 FROM friese_houses WHERE house_id=? AND owner_citizenid=? LIMIT 1',{key,p.PlayerData.citizenid})~=nil end
 if not allowed then notify(src,'Je bent geen eigenaar.','error'); return end
 MySQL.insert.await('INSERT IGNORE INTO friese_keys (kind,access_key,citizenid,granted_by) VALUES (?,?,?,?)',{kind,key,t.PlayerData.citizenid,p.PlayerData.citizenid}); notify(target,'Je hebt een sleutel ontvangen: '..key,'success'); TriggerEvent('friese-integrations:server:keyGranted',src,target,kind,key)
end)

