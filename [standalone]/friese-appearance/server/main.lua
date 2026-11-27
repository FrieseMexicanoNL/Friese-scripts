local function getCitizen(src)
    local player = exports['friese-core']:GetPlayer(src)
    return player and player.PlayerData and player.PlayerData.citizenid
end

RegisterNetEvent('friese-appearance:server:request', function()
    local src, citizenid = source, getCitizen(source)
    if not citizenid then return end
    local raw = MySQL.scalar.await('SELECT appearance FROM friese_appearances WHERE citizenid = ?', { citizenid })
    local appearance = raw and json.decode(raw) or nil
    TriggerClientEvent('friese-appearance:client:load', src, appearance)
end)

RegisterNetEvent('friese-appearance:server:save', function(appearance)
    local src, citizenid = source, getCitizen(source)
    if not citizenid or type(appearance) ~= 'table' then return end
    local encoded = json.encode(appearance)
    if #encoded > 20000 then return end
    if type(appearance.components) ~= 'table' or type(appearance.props) ~= 'table' then return end
    for key, entry in pairs(appearance.components) do
        local id = tonumber(key)
        if not id or id < 0 or id > 11 or type(entry) ~= 'table' then return end
        local drawable, texture = tonumber(entry.drawable), tonumber(entry.texture)
        if not drawable or not texture or drawable < 0 or drawable > 500 or texture < 0 or texture > 100 then return end
    end
    for key, entry in pairs(appearance.props) do
        local id = tonumber(key)
        if not id or id < 0 or id > 7 or type(entry) ~= 'table' then return end
        local drawable, texture = tonumber(entry.drawable), tonumber(entry.texture)
        if not drawable or not texture or drawable < -1 or drawable > 500 or texture < 0 or texture > 100 then return end
    end
    MySQL.prepare.await('INSERT INTO friese_appearances (citizenid, appearance) VALUES (?, ?) ON DUPLICATE KEY UPDATE appearance = VALUES(appearance)', { citizenid, encoded })
    TriggerClientEvent('friese-notify:client:notify', src, 'Je outfit is opgeslagen.', 'success' )
end)
