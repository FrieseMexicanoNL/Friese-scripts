local cooldown={}
local function near(src,points,maxDist)
 local ped=GetPlayerPed(src); if not ped or ped==0 then return false end
 local c=GetEntityCoords(ped)
 for _,pt in ipairs(points) do if #(c-pt)<=maxDist then return true end end
 return false
end
local function count(src,item) return exports['friese-inventory']:GetItemCount(src,item) end
RegisterNetEvent('friese-drugs:server:harvest',function(drug)
 local src=source; local d=Config.Drugs[drug]; if not d or not near(src,Config.ProcessPoints,Config.ProcessDistance) then return end
 if count(src,d.harvest)<1 then exports['friese-integrations']:Notify(src,'Je mist het benodigde materiaal.','error'); return end
 if exports['friese-inventory']:RemoveItem(src,d.harvest,1) and exports['friese-inventory']:AddItem(src,d.harvestOut,math.random(2,4)) then
  exports['friese-integrations']:Log('drugs',src,'Grondstof geoogst',{drug=drug})
 end
end)
RegisterNetEvent('friese-drugs:server:process',function(drug,stage)
 local src=source; local d=Config.Drugs[drug]; stage=tonumber(stage); local recipe=d and d.stages[stage]
 if not recipe or not near(src,Config.ProcessPoints,Config.ProcessDistance) then return end
 if count(src,recipe.input)<recipe.count then exports['friese-integrations']:Notify(src,'Onvoldoende grondstoffen.','error'); return end
 if exports['friese-inventory']:RemoveItem(src,recipe.input,recipe.count) then
  if not exports['friese-inventory']:AddItem(src,recipe.output,recipe.out) then exports['friese-inventory']:AddItem(src,recipe.input,recipe.count); return end
  exports['friese-integrations']:Log('drugs',src,'Productiestap uitgevoerd',{drug=drug,stage=stage})
 end
end)
RegisterNetEvent('friese-drugs:server:sell',function(drug,amount,secret)
 local src=source; local d=Config.Drugs[drug]; amount=math.floor(tonumber(amount) or 0); if not d or amount<1 or amount>20 then return end
 local now=os.time(); if cooldown[src] and now-cooldown[src]<Config.SaleCooldown then return end
 local item=drug..'_bag'; local points=secret and Config.SecretLocations or Config.Buyers
 if not near(src,(function() local t={} for _,v in ipairs(points) do t[#t+1]=v.coords end return t end)(),Config.BuyerDistance) then return end
 if count(src,item)<amount then exports['friese-integrations']:Notify(src,'Je hebt niet genoeg verpakte producten.','error'); return end
 if exports['friese-inventory']:RemoveItem(src,item,amount) then
  local multiplier=1.0
  if not secret then for _,v in ipairs(Config.Buyers) do local ped=GetPlayerPed(src); if #(GetEntityCoords(ped)-v.coords)<=v.radius then multiplier=v.priceMultiplier or 1.0 break end end else multiplier=1.35 end
  local total=math.floor(d.price*amount*multiplier)
  exports['friese-core']:AddMoney(src,'cash',total,secret and 'Geheime verkoop' or 'Straatverkoop')
  cooldown[src]=now; exports['friese-integrations']:Log('drugs_sale',src,'Producten verkocht',{drug=drug,amount=amount,total=total,secret=secret==true})
  exports['friese-integrations']:Notify(src,('Verkoop afgerond: €%s'):format(total),'success')
 end
end)
AddEventHandler('playerDropped',function() cooldown[source]=nil end)
