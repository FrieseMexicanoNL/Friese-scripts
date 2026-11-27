local function player(src) local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end); return ok and p or nil end
local function notify(src,msg,kind) TriggerClientEvent('friese-notify:client:notify',src,{title='Friese-Core',description=msg,type=kind or 'info'}) end

RegisterNetEvent('friese-shops:server:buy',function(shopId,itemId,amount)
 local src=source; local p=player(src); amount=math.floor(tonumber(amount) or 0); local shop=Config.Shops[shopId]; local item=shop and shop.items[itemId]
 if not p or not item or amount<1 or amount>item.max then return end
 local total=item.price*amount; if total<1 or total>Config.MaxPurchase then return end
 local ok=exports['friese-integrations']:ChargePlayer(src,total,'Aankoop '..item.label,'bank'); if not ok then notify(src,'Onvoldoende saldo.','error'); return end
 if not exports['friese-inventory']:AddItem(src,item.name,amount,nil,'shop-purchase') then exports['friese-core']:AddMoney(src,'bank',total,'Terugbetaling winkel'); notify(src,'Geen ruimte in inventory.','error'); return end
 TriggerEvent('friese-integrations:server:shopPurchase',src,shopId,item.name,amount,total); notify(src,'Aankoop geslaagd.','success')
end)

