RegisterNetEvent('friese-clothing:server:saveOutfit',function(name,components,props)
 local src=source; local p=exports['friese-core']:GetPlayer(src); if not p then return end
 name=tostring(name or ''):gsub('[^%w _%-]',''):sub(1,40); if name=='' or type(components)~='table' or type(props)~='table' then return end
 if #json.encode(components)>12000 or #json.encode(props)>6000 then return end
 MySQL.insert('INSERT INTO friese_outfits (citizenid,name,components,props) VALUES (?,?,?,?) ON DUPLICATE KEY UPDATE components=VALUES(components),props=VALUES(props)',{p.PlayerData.citizenid,name,json.encode(components),json.encode(props)})
 TriggerClientEvent('friese-notify:client:notify',src,'Outfit opgeslagen.','success')
end)
RegisterNetEvent('friese-clothing:server:getOutfits',function()
 local src=source; local p=exports['friese-core']:GetPlayer(src); if not p then return end
 local rows=MySQL.query.await('SELECT name,components,props FROM friese_outfits WHERE citizenid=?',{p.PlayerData.citizenid}) or {}
 for _,r in ipairs(rows) do r.components=json.decode(r.components or '{}'); r.props=json.decode(r.props or '{}') end
 TriggerClientEvent('friese-clothing:client:outfits',src,rows)
end)
