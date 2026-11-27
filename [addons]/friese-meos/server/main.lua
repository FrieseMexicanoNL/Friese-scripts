local function getPlayer(src) return exports['friese-core']:GetPlayer(src) end
local function isPolice(src)
    local p = getPlayer(src)
    return p and p.PlayerData.job and MEOSConfig.Jobs[p.PlayerData.job.name] == true
end
local function clean(value, max)
    if type(value) ~= 'string' then return '' end
    value = value:gsub('[%c]', ' '):gsub('^%s+', ''):gsub('%s+$', '')
    return value:sub(1, max)
end
RegisterNetEvent('friese-meos:server:search', function(term)
    local src = source
    if not isPolice(src) then return end
    term = clean(term, MEOSConfig.MaxSearchLength)
    if #term < 2 then TriggerClientEvent('friese-meos:client:searchResults', src, {}) return end
    local like = '%' .. term .. '%'
    local rows = MySQL.query.await([[SELECT citizenid, charinfo, job FROM friese_characters
        WHERE citizenid LIKE ? OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.firstname')) LIKE ?
        OR JSON_UNQUOTE(JSON_EXTRACT(charinfo, '$.lastname')) LIKE ? ORDER BY citizenid LIMIT ?]],
        { like, like, like, MEOSConfig.SearchLimit }) or {}
    local results = {}
    for _, row in ipairs(rows) do
        local info = json.decode(row.charinfo or '{}') or {}
        results[#results+1] = { citizenid = row.citizenid, name = ((info.firstname or '') .. ' ' .. (info.lastname or '')):gsub('^%s*(.-)%s*$', '%1') }
    end
    TriggerClientEvent('friese-meos:client:searchResults', src, results)
end)
RegisterNetEvent('friese-meos:server:getDossier', function(citizenid)
    local src = source
    if not isPolice(src) then return end
    citizenid = clean(citizenid, 64)
    if citizenid == '' then return end
    local character = MySQL.single.await('SELECT charinfo FROM friese_characters WHERE citizenid = ? LIMIT 1', { citizenid })
    local info = character and (json.decode(character.charinfo or '{}') or {}) or {}
    local fullName = ((info.firstname or '') .. ' ' .. (info.lastname or '')):gsub('^%s*(.-)%s*$', '%1')
    local reports = MySQL.query.await('SELECT id, officer_citizenid, title, body, created_at FROM friese_meos_reports WHERE target_citizenid = ? ORDER BY id DESC LIMIT 50', { citizenid }) or {}
    local fines = MySQL.query.await('SELECT id, amount, reason, created_at FROM friese_police_fines WHERE target_citizenid = ? ORDER BY id DESC LIMIT 50', { citizenid }) or {}
    local actions = MySQL.query.await('SELECT id, action, details, created_at FROM friese_police_actions WHERE target_citizenid = ? ORDER BY id DESC LIMIT 50', { citizenid }) or {}
    TriggerClientEvent('friese-meos:client:dossier', src, { citizenid = citizenid, name = fullName, reports = reports, fines = fines, actions = actions })
end)
RegisterNetEvent('friese-meos:server:addReport', function(citizenid, title, body)
    local src = source
    if not isPolice(src) then return end
    citizenid, title, body = clean(citizenid,64), clean(title,100), clean(body,MEOSConfig.MaxReportLength)
    if citizenid == '' or title == '' or #body < 5 then return end
    local exists = MySQL.scalar.await('SELECT citizenid FROM friese_characters WHERE citizenid = ? LIMIT 1', { citizenid })
    if not exists then TriggerClientEvent('friese-notify:client:notify',src,'Persoon niet gevonden.','error') return end
    local officer = getPlayer(src)
    MySQL.insert.await('INSERT INTO friese_meos_reports (target_citizenid, officer_citizenid, title, body) VALUES (?,?,?,?)',
        { citizenid, officer.PlayerData.citizenid, title, body })
    TriggerClientEvent('friese-notify:client:notify',src,'Rapport opgeslagen in het dossier.','success')
    TriggerClientEvent('friese-meos:client:refreshDossier',src,citizenid)
end)
RegisterCommand(MEOSConfig.Command, function(src)
    if src == 0 or not isPolice(src) then return end
    TriggerClientEvent('friese-meos:client:open',src)
end)
exports('IsPolice', isPolice)
