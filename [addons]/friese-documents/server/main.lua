local function getPlayer(src)
    local ok,p=pcall(function() return exports['friese-core']:GetPlayer(src) end)
    if not ok then return nil end; return p
end
local function makeDocument(src,kind)
    local p=getPlayer(src); if not p or not p.PlayerData then return nil end
    local d=p.PlayerData; local c=d.charinfo or {}; local cfg=Documents.Config.Types[kind]
    if not cfg then return nil end
    local name=((c.firstname or 'Onbekend')..' '..(c.lastname or '')):gsub('%s+$','')
    local row=MySQL.single.await('SELECT status, issued_at FROM friese_documents WHERE citizenid = ? AND document_type = ?', {d.citizenid,kind})
    if kind~='id' and not row then return nil end
    return {type=kind,label=cfg.label,name=name,birthdate=c.birthdate or 'Onbekend',gender=c.gender or 'Onbekend',citizenid=d.citizenid,status=(row and row.status) or 'Geldig',issued=(row and row.issued_at) or 'Niet geregistreerd'}
end
RegisterNetEvent('friese-documents:server:requestOwn',function(kind)
    local src=source; if kind~='id' and not Documents.Config.Types[kind] then return end
    local doc=makeDocument(src,kind); if not doc then TriggerClientEvent('chat:addMessage',src,{args={'Friese','Dit document is niet geregistreerd.'}}); return end
    TriggerClientEvent('friese-documents:client:show',src,doc,GetPlayerName(src))
end)
RegisterNetEvent('friese-documents:server:showTo',function(target,kind)
    local src=source; target=tonumber(target); kind=tostring(kind or 'id')
    if not target or not GetPlayerName(target) or #(GetEntityCoords(GetPlayerPed(src))-GetEntityCoords(GetPlayerPed(target)))>Documents.Config.Distance then return end
    local doc=makeDocument(src,kind); if not doc then TriggerClientEvent('chat:addMessage',src,{args={'Friese','Je beschikt niet over dit document.'}}); return end
    TriggerClientEvent('friese-documents:client:show',target,doc,GetPlayerName(src))
end)
exports('IssueDocument',function(citizenid,kind,status)
    if not Documents.Config.Types[kind] or kind=='id' then return false end
    MySQL.insert.await('INSERT INTO friese_documents (citizenid,document_type,status) VALUES (?,?,?) ON DUPLICATE KEY UPDATE status=VALUES(status), issued_at=CURRENT_TIMESTAMP', {citizenid,kind,status or 'Geldig'})
    return true
end)
exports('RevokeDocument',function(citizenid,kind)
    return MySQL.update.await('UPDATE friese_documents SET status = ? WHERE citizenid = ? AND document_type = ?', {'Ingetrokken',citizenid,kind})>0
end)
