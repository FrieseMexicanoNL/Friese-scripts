local function player(src) local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end); return ok and p or nil end
local function notify(src,msg,kind) TriggerClientEvent('friese-notify:client:notify',src,{title='Friese-Core',description=msg,type=kind or 'info'}) end

RegisterNetEvent('friese-crafting:server:craft', function(recipeId)
 local src=source; local p=player(src); if not p then return end
 local r=Config.Recipes[recipeId]; if not r then return end
 for item,count in pairs(r.ingredients) do if not exports['friese-inventory']:GetItemCount(src,item) >= count then notify(src,'Onvoldoende materialen.','error'); return end end
 for item,count in pairs(r.ingredients) do if not exports['friese-inventory']:RemoveItem(src,item,count,'crafting') then notify(src,'Craften geannuleerd.','error'); return end end
 if exports['friese-inventory']:AddItem(src,r.output,r.amount or 1,nil,'crafting') then notify(src,'Product gemaakt: '..r.label,'success'); TriggerEvent('friese-integrations:server:crafted',src,recipeId,r) else for item,count in pairs(r.ingredients) do exports['friese-inventory']:AddItem(src,item,count,nil,'craft-refund') end; notify(src,'Geen ruimte in inventory.','error') end
end)

