local function player(src)
    local p = exports['friese-core']:GetPlayer(src)
    return p and p.PlayerData or nil
end
local function cid(src) local d=player(src); return d and d.citizenid end
local function numberFor(src)
    local id=cid(src); if not id then return nil end
    local row=MySQL.single.await('SELECT phone_number FROM friese_phone_numbers WHERE citizenid=?',{id})
    if row then return row.phone_number end
    -- Stable, unique number derived from citizen ID; DB unique key handles collisions.
    local hash=0; for i=1,#id do hash=(hash*31+id:byte(i))%100000000 end
    local num=Config.NumberPrefix..string.format('%08d',hash)
    local suffix=0
    while true do
        local ok=MySQL.insert.await('INSERT IGNORE INTO friese_phone_numbers (citizenid,phone_number) VALUES (?,?)',{id,num})
        local check=MySQL.single.await('SELECT phone_number FROM friese_phone_numbers WHERE citizenid=?',{id})
        if check then return check.phone_number end
        suffix=suffix+1; num=Config.NumberPrefix..string.format('%08d',(hash+suffix)%100000000)
        if suffix>1000 then return nil end
    end
end
local function notify(src,msg,kind) TriggerClientEvent('friese-notify:client:notify',src,msg,kind or 'info') end
RegisterNetEvent('friese-phone:server:bootstrap',function()
    local src=source; local number=numberFor(src); if not number then return end
    local contacts=MySQL.query.await('SELECT id,name,phone_number FROM friese_phone_contacts WHERE owner_citizenid=? ORDER BY name',{cid(src)}) or {}
    local messages=MySQL.query.await('SELECT id,sender_number,receiver_number,message,UNIX_TIMESTAMP(created_at) AS created FROM friese_phone_messages WHERE sender_number=? OR receiver_number=? ORDER BY id DESC LIMIT 60',{number,number}) or {}
    local calls=MySQL.query.await('SELECT id,caller_number,receiver_number,status,UNIX_TIMESTAMP(created_at) AS created FROM friese_phone_calls WHERE caller_number=? OR receiver_number=? ORDER BY id DESC LIMIT 25',{number,number}) or {}
    TriggerClientEvent('friese-phone:client:bootstrap',src,{number=number,contacts=contacts,messages=messages,calls=calls})
end)
RegisterNetEvent('friese-phone:server:addContact',function(name,phone)
    local src=source; local id=cid(src); if not id then return end
    name=type(name)=='string' and name:gsub('[<>]',''):sub(1,64) or ''; phone=type(phone)=='string' and phone:gsub('%D',''):sub(1,16) or ''
    if #name<2 or #phone<8 then notify(src,'Vul een geldige naam en een telefoonnummer in.','error'); return end
    local count=MySQL.scalar.await('SELECT COUNT(*) FROM friese_phone_contacts WHERE owner_citizenid=?',{id}) or 0
    if count>=Config.MaxContacts then notify(src,'Je contactenlijst is vol.','error'); return end
    local ok=MySQL.insert.await('INSERT IGNORE INTO friese_phone_contacts (owner_citizenid,name,phone_number) VALUES (?,?,?)',{id,name,phone})
    notify(src,ok and 'Contact opgeslagen.' or 'Dit nummer staat al in je contacten. ',ok and 'success' or 'error')
    TriggerClientEvent('friese-phone:client:refresh',src)
end)
RegisterNetEvent('friese-phone:server:deleteContact',function(contactId)
    local src=source; local id=cid(src); contactId=tonumber(contactId); if not id or not contactId then return end
    MySQL.update.await('DELETE FROM friese_phone_contacts WHERE id=? AND owner_citizenid=?',{contactId,id}); TriggerClientEvent('friese-phone:client:refresh',src)
end)
RegisterNetEvent('friese-phone:server:sendMessage',function(receiver,message)
    local src=source; local sender=numberFor(src); if not sender then return end
    receiver=type(receiver)=='string' and receiver:gsub('%D',''):sub(1,16) or ''; message=type(message)=='string' and message:gsub('[\r\n]',' '):sub(1,Config.MaxMessageLength) or ''
    if #receiver<8 or receiver==sender or message=='' then notify(src,'Controleer het nummer en bericht.','error'); return end
    local target=MySQL.single.await('SELECT citizenid FROM friese_phone_numbers WHERE phone_number=?',{receiver})
    if not target then notify(src,'Dit telefoonnummer is niet in gebruik.','error'); return end
    MySQL.insert.await('INSERT INTO friese_phone_messages (sender_number,receiver_number,message) VALUES (?,?,?)',{sender,receiver,message})
    local targetSrc
    for _,v in ipairs(GetPlayers()) do if cid(tonumber(v))==target.citizenid then targetSrc=tonumber(v); break end end
    if targetSrc then TriggerClientEvent('friese-phone:client:incomingMessage',targetSrc,{sender=sender,message=message}) end
    TriggerClientEvent('friese-phone:client:refresh',src); notify(src,'Bericht verzonden.','success')
end)
RegisterNetEvent('friese-phone:server:call',function(receiver)
    local src=source; local sender=numberFor(src); receiver=type(receiver)=='string' and receiver:gsub('%D',''):sub(1,16) or ''
    if not sender or #receiver<8 or receiver==sender then return end
    local target=MySQL.single.await('SELECT citizenid FROM friese_phone_numbers WHERE phone_number=?',{receiver})
    if not target then notify(src,'Nummer niet gevonden.','error'); return end
    MySQL.insert.await('INSERT INTO friese_phone_calls (caller_number,receiver_number,status) VALUES (?,?,?)',{sender,receiver,'calling'})
    for _,v in ipairs(GetPlayers()) do local t=tonumber(v); if cid(t)==target.citizenid then TriggerClientEvent('friese-phone:client:incomingCall',t,{number=sender}); break end end
    notify(src,'Oproep gestart. Voor daadwerkelijk geluid/voice is een voice-resource-koppeling nodig.','info')
end)
