local Inventories, Ground, Usables = {}, {}, {}
local function debugLog(msg) if FrInv.Config.Debug then print(('^3[Friese-Inventory]^7 %s'):format(msg)) end end
local function getPlayer(src) return exports['friese-core']:GetPlayer(src) end
local function getCitizen(src) local p=getPlayer(src); return p and p.PlayerData and p.PlayerData.citizenid end
local function notify(src,msg) TriggerClientEvent('friese-inventory:client:notify',src,msg) end
local function getWeight(items)
 local total=0.0; for _,it in ipairs(items or {}) do local def=FrInv.Items[it.name]; if def then total=total+(def.weight or 0)*(tonumber(it.amount) or 0) end end; return total
end
local function clean(raw)
 local out={}; for _,it in ipairs(raw or {}) do if type(it)=='table' and FrInv.Items[it.name] and tonumber(it.amount) and tonumber(it.amount)>0 then out[#out+1]={name=it.name,amount=math.floor(tonumber(it.amount)),metadata=type(it.metadata)=='table' and it.metadata or {}} end end; return out
end
local function save(src)
 local cid=getCitizen(src); if not cid or not Inventories[src] then return false end
 MySQL.update.await('INSERT INTO friese_inventories (citizenid, items) VALUES (?, ?) ON DUPLICATE KEY UPDATE items = VALUES(items)',{cid,json.encode(Inventories[src])}); return true
end
local function load(src)
 local cid=getCitizen(src); if not cid then return nil end
 local row=MySQL.single.await('SELECT items FROM friese_inventories WHERE citizenid = ?',{cid})
 local decoded={}; if row and row.items then local ok,data=pcall(json.decode,row.items); if ok and type(data)=='table' then decoded=data end end
 Inventories[src]=clean(decoded); return Inventories[src]
end
local function findItem(items,name,metadata)
 for i,it in ipairs(items or {}) do if it.name==name and (not metadata or json.encode(it.metadata or {})==json.encode(metadata)) then return i,it end end
end
local function addItem(src,name,amount,metadata)
 local def=FrInv.Items[name]; amount=math.floor(tonumber(amount) or 0); if not def or amount<1 or amount>10000 or not getCitizen(src) then return false end
 local items=Inventories[src] or load(src) or {}; if getWeight(items)+(def.weight or 0)*amount>FrInv.Config.MaxWeight then notify(src,'Je draagt te veel gewicht.'); return false end
 local _,existing=findItem(items,name,metadata)
 if existing then existing.amount=existing.amount+amount elseif #items<FrInv.Config.Slots then items[#items+1]={name=name,amount=amount,metadata=metadata or {}} else notify(src,'Je inventory zit vol.'); return false end
 save(src); return true
end
local function removeItem(src,name,amount,metadata)
 local items=Inventories[src] or {}; local index,item=findItem(items,name,metadata); amount=math.floor(tonumber(amount) or 0)
 if not item or amount<1 or item.amount<amount then return false end
 item.amount=item.amount-amount; if item.amount==0 then table.remove(items,index) end; save(src); return true
end
local function snapshot(src)
 local p=getPlayer(src); local items=Inventories[src] or load(src) or {}; local c=GetEntityCoords(GetPlayerPed(src)); local nearby={}
 for id,drop in pairs(Ground) do if #(c-vector3(drop.coords.x,drop.coords.y,drop.coords.z))<=5.0 then nearby[#nearby+1]={id=id,items=drop.items} end end
 local money=p and p.PlayerData.money or {}
 return {items=items,ground=nearby,wallet={{name='cash',label='Contant geld',amount=tonumber(money.cash) or 0},{name='bank',label='Bank',amount=tonumber(money.bank) or 0},{name='black',label='Zwart geld',amount=tonumber(money.black) or 0}},weight=getWeight(items),maxWeight=FrInv.Config.MaxWeight,slots=FrInv.Config.Slots,quickSlots=FrInv.Config.QuickSlots,charinfo=p and p.PlayerData.charinfo or {}}
end
local function refresh(src) TriggerClientEvent('friese-inventory:client:refresh',src,snapshot(src)) end
RegisterNetEvent('friese-inventory:server:requestOpen',function() local src=source; if not getCitizen(src) then notify(src,'Laad eerst je personage.'); return end; TriggerClientEvent('friese-inventory:client:open',src,snapshot(src)) end)
RegisterNetEvent('friese-inventory:server:moveToGround',function(index,amount)
 local src=source; if not getCitizen(src) then return end; index=tonumber(index); amount=math.floor(tonumber(amount) or 0); local items=Inventories[src] or load(src) or {}; local item=index and items[index]
 if not item or amount<1 or amount>item.amount then return end
 local c=GetEntityCoords(GetPlayerPed(src)); local id=('%s-%s-%s'):format(os.time(),src,math.random(1000,9999)); Ground[id]={coords={x=c.x,y=c.y,z=c.z},items={{name=item.name,amount=amount,metadata=item.metadata or {}}},expires=os.time()+FrInv.Config.GroundLifetimeMinutes*60}
 removeItem(src,item.name,amount,item.metadata); refresh(src)
end)
RegisterNetEvent('friese-inventory:server:takeGround',function(id,index,amount)
 local src=source; if not getCitizen(src) then return end; local drop=Ground[tostring(id)]; index=tonumber(index); amount=math.floor(tonumber(amount) or 0); if not drop or not index or amount<1 then return end
 local c=GetEntityCoords(GetPlayerPed(src)); if #(c-vector3(drop.coords.x,drop.coords.y,drop.coords.z))>FrInv.Config.GroundDistance+1.0 then return end
 local item=drop.items[index]; if not item or item.amount<amount then return end
 if addItem(src,item.name,amount,item.metadata) then item.amount=item.amount-amount; if item.amount<=0 then table.remove(drop.items,index) end; if #drop.items==0 then Ground[tostring(id)]=nil end end; refresh(src)
end)
RegisterNetEvent('friese-inventory:server:use',function(index)
 local src=source; if not getCitizen(src) then return end; index=tonumber(index); local item=index and (Inventories[src] or {})[index]; if not item then return end
 local def=FrInv.Items[item.name]; if not def or not def.usable then return end
 local handler=Usables[item.name]; if handler then handler(src,item) else TriggerEvent('friese-inventory:server:useItem',src,item.name,item.metadata or {}) end
end)
RegisterNetEvent('friese-inventory:server:give',function(index,target,amount)
 local src=source; target=tonumber(target); index=tonumber(index); amount=math.floor(tonumber(amount) or 0); if not target or target==src or not getCitizen(target) or amount<1 then return end
 if #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target)))>FrInv.Config.GiveDistance then notify(src,'Deze speler staat te ver weg.'); return end
 local item=index and (Inventories[src] or {})[index]; if not item or item.amount<amount then return end
 local name,metadata=item.name,item.metadata; if addItem(target,name,amount,metadata) and removeItem(src,name,amount,metadata) then notify(src,'Item overgedragen.'); notify(target,'Je hebt een item ontvangen.') end; refresh(src); refresh(target)
end)
RegisterNetEvent('friese-inventory:server:split',function(index,amount)
 local src=source; index=tonumber(index); amount=math.floor(tonumber(amount) or 0); local items=Inventories[src] or {}; local item=index and items[index]
 if not item or amount<1 or amount>=item.amount or #items>=FrInv.Config.Slots then return end
 item.amount=item.amount-amount; items[#items+1]={name=item.name,amount=amount,metadata=item.metadata or {}}; save(src); refresh(src)
end)
AddEventHandler('friese-core:server:playerLoaded',function(src) load(src) end)
AddEventHandler('friese-core:server:playerUnloaded',function(src) save(src); Inventories[src]=nil end)
AddEventHandler('playerDropped',function() local src=source; save(src); Inventories[src]=nil end)
CreateThread(function()
 while GetResourceState('oxmysql')~='started' do Wait(250) end
 MySQL.query.await([[CREATE TABLE IF NOT EXISTS friese_inventories (citizenid VARCHAR(32) NOT NULL PRIMARY KEY, items LONGTEXT NOT NULL, updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP)]])
 debugLog('Database gereed.')
 while true do Wait(60000); local now=os.time(); for id,drop in pairs(Ground) do if drop.expires<now then Ground[id]=nil end end; for src in pairs(Inventories) do save(src) end end
end)
-- Basic standalone weapon item bridge. Add more weapon definitions in shared/items.lua.
CreateThread(function()
    Wait(0)
    for name, def in pairs(FrInv.Items) do
        if def.weapon then
            Usables[name] = function(src, item)
                if removeItem(src, name, 1, item.metadata) then
                    TriggerClientEvent('friese-inventory:client:equipWeapon', src, def.weapon)
                end
            end
        elseif def.ammo then
            Usables[name] = function(src, item)
                if removeItem(src, name, 1, item.metadata) then
                    TriggerClientEvent('friese-inventory:client:addAmmo', src, tonumber(def.ammo) or 0)
                end
            end
        end
    end
end)

exports('AddItem',addItem); exports('RemoveItem',removeItem)
exports('GetInventory',function(src) return Inventories[src] or load(src) or {} end)
exports('GetItemCount',function(src,name) local _,item=findItem(Inventories[src] or {},name); return item and item.amount or 0 end)
exports('RegisterUsableItem',function(name,cb) if FrInv.Items[name] and type(cb)=='function' then Usables[name]=cb; return true end return false end)

exports('GetItemDefinition',function(name) return FrInv.Items[name] end)
