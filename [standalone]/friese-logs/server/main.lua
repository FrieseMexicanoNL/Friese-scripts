FrieseLogs = FrieseLogs or {}
function FrieseLogs.Write(category, actor, message, metadata)
 if type(category)~='string' or type(message)~='string' then return false end
 local encoded=metadata and json.encode(metadata) or nil
 MySQL.insert('INSERT INTO friese_logs (category, actor, message, metadata) VALUES (?, ?, ?, ?)', {category:sub(1,40), tostring(actor or 'system'):sub(1,80), message:sub(1,500), encoded})
 return true
end
exports('Write',FrieseLogs.Write)
AddEventHandler('friese-core:server:moneyChanged',function(src,account,amount,action,reason)
 local p=exports['friese-core']:GetPlayer(src); local cid=p and p.PlayerData and p.PlayerData.citizenid or 'unknown'
 FrieseLogs.Write('money',cid,('%s %s %s (%s)'):format(action,amount,account,reason or 'unknown'),{source=src})
end)
