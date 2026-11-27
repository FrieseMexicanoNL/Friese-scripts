local function player(src)
    local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end)
    if ok and p and p.PlayerData then return p.PlayerData end
end
local function notify(src,msg) TriggerClientEvent('chat:addMessage',src,{color={40,145,255},args={'Friese Housing',msg}}) end
RegisterNetEvent('friese-housing:server:propertyInfo',function(id)
    local src=source; local house=Housing.Config.Properties[tostring(id)]; if not house then return end
    local owner=MySQL.scalar.await('SELECT citizenid FROM friese_houses WHERE property_id=?',{id})
    TriggerClientEvent('friese-housing:client:info',src,{id=id,label=house.label,price=house.price,owner=owner})
end)
RegisterNetEvent('friese-housing:server:buy',function(id)
    local src=source; id=tostring(id); local house=Housing.Config.Properties[id]; local pd=player(src)
    if not house or not pd then return end
    local exists=MySQL.scalar.await('SELECT citizenid FROM friese_houses WHERE property_id=?',{id})
    if exists then notify(src,'Deze woning is al verkocht.'); return end
    local bank=tonumber(pd.money and pd.money.bank) or 0
    if bank<house.price then notify(src,'Je hebt onvoldoende saldo op de bank.'); return end
    local changed=exports['friese-core']:RemoveMoney(src,'bank',house.price,'Woning gekocht: '..id)
    if not changed then notify(src,'Betaling is niet gelukt.'); return end
    local ok=pcall(function() MySQL.insert.await('INSERT INTO friese_houses (property_id,citizenid,label,purchase_price) VALUES (?,?,?,?)',{id,pd.citizenid,house.label,house.price}) end)
    if not ok then exports['friese-core']:AddMoney(src,'bank',house.price,'Terugbetaling woning'); notify(src,'Aankoop mislukt; het bedrag is teruggestort.'); return end
    notify(src,'Gefeliciteerd! Je hebt '..house.label..' gekocht.')
end)
RegisterNetEvent('friese-housing:server:giveKey',function(id,target)
    local src=source; id=tostring(id); target=tonumber(target); local pd=player(src); local tp=target and player(target)
    if not pd or not tp or not Housing.Config.Properties[id] then return end
    local owner=MySQL.scalar.await('SELECT citizenid FROM friese_houses WHERE property_id=?',{id})
    if owner~=pd.citizenid then notify(src,'Alleen de eigenaar kan sleutels uitdelen.'); return end
    MySQL.insert.await('INSERT IGNORE INTO friese_house_keys (property_id,citizenid,granted_by) VALUES (?,?,?)',{id,tp.citizenid,pd.citizenid})
    notify(src,'Sleutel verleend aan '..GetPlayerName(target)..'.'); notify(target,'Je hebt een woningsleutel ontvangen: '..id)
end)
RegisterNetEvent('friese-housing:server:myHomes',function()
    local src=source; local pd=player(src); if not pd then return end
    local rows=MySQL.query.await('SELECT property_id,label FROM friese_houses WHERE citizenid=? UNION SELECT h.property_id,h.label FROM friese_houses h INNER JOIN friese_house_keys k ON k.property_id=h.property_id WHERE k.citizenid=?',{pd.citizenid,pd.citizenid}) or {}
    TriggerClientEvent('friese-housing:client:homes',src,rows)
end)
exports('HasKey',function(citizenid,propertyId)
    local owner=MySQL.scalar.await('SELECT citizenid FROM friese_houses WHERE property_id=?',{propertyId}); if owner==citizenid then return true end
    return MySQL.scalar.await('SELECT 1 FROM friese_house_keys WHERE property_id=? AND citizenid=?',{propertyId,citizenid})~=nil
end)
