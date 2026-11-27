local function makePlate()
 for _=1,30 do local p=(DealershipConfig.PlatePrefix..string.format('%05d',math.random(0,99999))):sub(1,8)
  if not MySQL.scalar.await('SELECT plate FROM friese_vehicles WHERE plate = ?',{p}) then return p end
 end
 return nil
end
RegisterNetEvent('friese-dealership:server:buy',function(model)
 local src=source; model=tostring(model or ''):lower(); local item=DealershipConfig.Vehicles[model]; local p=exports['friese-core']:GetPlayer(src)
 if not p or not item then return end
 local count=MySQL.scalar.await('SELECT COUNT(*) FROM friese_vehicles WHERE citizenid = ?',{p.PlayerData.citizenid}) or 0
 if count>=DealershipConfig.MaxOwned then TriggerClientEvent('friese-notify:client:notify',src,'Je hebt het maximale aantal voertuigen.','error'); return end
 local plate=makePlate(); if not plate then return end
 if not exports['friese-core']:RemoveMoney(src,'bank',item.price,'Voertuig gekocht: '..model) then TriggerClientEvent('friese-notify:client:notify',src,'Onvoldoende banksaldo.','error'); return end
 local props={model=joaat(item.model),plate=plate}
 MySQL.insert.await('INSERT INTO friese_vehicles (citizenid,plate,vehicle,props,garage,state) VALUES (?,?,?,?,?,1)',{p.PlayerData.citizenid,plate,model,json.encode(props),'legion'})
 TriggerClientEvent('friese-notify:client:notify',src,('Je hebt %s gekocht. Kenteken: %s'):format(item.label,plate),'success')
 TriggerClientEvent('friese-dealership:client:purchaseComplete',src,item.model,plate)
 TriggerEvent('friese-dealership:server:vehiclePurchased',src,p.PlayerData.citizenid,model,plate,item.price)
end)
RegisterNetEvent('friese-dealership:server:catalog',function() local src=source; TriggerClientEvent('friese-dealership:client:catalog',src,DealershipConfig.Vehicles) end)
