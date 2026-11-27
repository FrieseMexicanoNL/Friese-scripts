local function player(src) return exports['friese-core']:GetPlayer(src) end
local function isPolice(src)
    local p = player(src); return p and p.PlayerData.job and PoliceConfig.Jobs[p.PlayerData.job.name] == true
end
local function nearby(a,b,max)
    local pa,pb=GetPlayerPed(a),GetPlayerPed(b); if pa==0 or pb==0 then return false end
    return #(GetEntityCoords(pa)-GetEntityCoords(pb)) <= (max or PoliceConfig.InteractionDistance)
end
RegisterNetEvent('friese-police:server:fine', function(target, amount, reason)
    local src=source; target=tonumber(target); amount=math.floor(tonumber(amount) or 0); reason=tostring(reason or 'Verkeersovertreding'):sub(1,160)
    if not isPolice(src) or not target or target==src or amount<1 or amount>PoliceConfig.MaxFine or not player(target) or not nearby(src,target,5.0) then return end
    local p=player(target)
    local fineId = MySQL.insert.await('INSERT INTO friese_police_fines (officer_citizenid,target_citizenid,amount,reason) VALUES (?,?,?,?)', {player(src).PlayerData.citizenid,p.PlayerData.citizenid,amount,reason})
    -- Fine is registered as an unpaid invoice so it appears in the shared banking/invoice flow.
    if GetResourceState('friese-integrations') == 'started' then
        exports['friese-integrations']:CreateInvoice(src, target, amount, reason, 'police_fine')
    else
        TriggerEvent('friese-police:server:fineIssued', fineId, src, target, amount, reason)
    end
    TriggerEvent('friese-police:server:fineRecorded', fineId, src, target, amount, reason)
    TriggerClientEvent('friese-notify:client:notify',target,('Je hebt een boete ontvangen van €%s: %s'):format(amount,reason),'error')
    TriggerClientEvent('friese-notify:client:notify',src,'Boete succesvol uitgeschreven.','success')
end)
RegisterNetEvent('friese-police:server:arrest', function(target, state)
    local src=source; target=tonumber(target); if not isPolice(src) or not target or not player(target) or not nearby(src,target,3.0) then return end
    TriggerClientEvent('friese-police:client:setCuffed',target,state==true)
    MySQL.insert.await('INSERT INTO friese_police_actions (officer_citizenid,target_citizenid,action,details) VALUES (?,?,?,?)', {player(src).PlayerData.citizenid,player(target).PlayerData.citizenid,state and 'boeien' or 'ontboeien',''} )
end)
RegisterNetEvent('friese-police:server:jail', function(target, minutes, reason)
    local src=source; target=tonumber(target); minutes=math.floor(tonumber(minutes) or 0); reason=tostring(reason or 'Geen reden opgegeven'):sub(1,160)
    if not isPolice(src) or not target or not player(target) or minutes<1 or minutes>PoliceConfig.MaxJailMinutes or not nearby(src,target,3.0) then return end
    TriggerClientEvent('friese-police:client:jail',target,minutes,reason)
    MySQL.insert.await('INSERT INTO friese_police_actions (officer_citizenid,target_citizenid,action,details) VALUES (?,?,?,?)', {player(src).PlayerData.citizenid,player(target).PlayerData.citizenid,'gevangenis',json.encode({minutes=minutes,reason=reason})})
end)
RegisterCommand('boete',function(src,args)
 if src==0 or not isPolice(src) then return end
 TriggerClientEvent('friese-police:client:requestFine',src,tonumber(args[1]),tonumber(args[2]),table.concat(args,' ',3))
end)
RegisterCommand('boeien',function(src,args)
 if src==0 or not isPolice(src) then return end
 local target=tonumber(args[1]); if not target or not player(target) or not nearby(src,target,3.0) then return end
 TriggerClientEvent('friese-police:client:setCuffed',target,true)
 local a,b=player(src),player(target)
 MySQL.insert('INSERT INTO friese_police_actions (officer_citizenid,target_citizenid,action,details) VALUES (?,?,?,?)',{a.PlayerData.citizenid,b.PlayerData.citizenid,'boeien','via commando'})
end)
exports('IsPolice',isPolice)
