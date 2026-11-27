local function notify(src, msg) TriggerClientEvent('friese-garage:client:notify', src, msg) end
local function playerData(src)
    local p = exports['friese-core']:GetPlayer(src)
    return p and p.PlayerData or nil
end
local function cleanPlate(plate) return (tostring(plate or ''):upper():gsub('%s+', '')) end

CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do Wait(250) end
    MySQL.query.await([[CREATE TABLE IF NOT EXISTS friese_vehicles (
        id INT NOT NULL AUTO_INCREMENT,
        citizenid VARCHAR(32) NOT NULL,
        plate VARCHAR(12) NOT NULL,
        vehicle VARCHAR(60) NOT NULL,
        props LONGTEXT NOT NULL,
        garage VARCHAR(40) NOT NULL DEFAULT 'legion',
        state TINYINT NOT NULL DEFAULT 1,
        created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (id), UNIQUE KEY uq_friese_plate (plate), KEY idx_friese_citizenid (citizenid)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4]])
    print('^2[Friese-Garage]^7 Database gereed.')
end)

RegisterNetEvent('friese-garage:server:requestVehicles', function(garageId)
    local src, p = source, playerData(source)
    if not p or not FrGarage.Config.Garages[garageId] then return end
    local rows = MySQL.query.await('SELECT id, plate, vehicle, props, garage, state FROM friese_vehicles WHERE citizenid = ? ORDER BY id DESC', { p.citizenid }) or {}
    local list = {}
    for _, row in ipairs(rows) do
        local ok, props = pcall(json.decode, row.props or '{}')
        list[#list + 1] = { id = row.id, plate = row.plate, model = row.vehicle, props = ok and props or {}, garage = row.garage, state = tonumber(row.state) or 1 }
    end
    TriggerClientEvent('friese-garage:client:open', src, garageId, FrGarage.Config.Garages[garageId].label, list)
end)

RegisterNetEvent('friese-garage:server:spawn', function(vehicleId, garageId)
    local src, p = source, playerData(source)
    vehicleId, garageId = tonumber(vehicleId), tostring(garageId or '')
    local garage = FrGarage.Config.Garages[garageId]
    if not p or not vehicleId or not garage then return end
    local row = MySQL.single.await('SELECT id, plate, vehicle, props FROM friese_vehicles WHERE id = ? AND citizenid = ? AND state = 1', { vehicleId, p.citizenid })
    if not row then notify(src, 'Dit voertuig staat niet in deze garage of is al buiten.'); return end
    local ok, props = pcall(json.decode, row.props or '{}')
    if not ok or type(props) ~= 'table' then props = {} end
    MySQL.update.await('UPDATE friese_vehicles SET state = 0 WHERE id = ? AND citizenid = ?', { vehicleId, p.citizenid })
    TriggerClientEvent('friese-garage:client:spawn', src, { model = row.vehicle, plate = row.plate, props = props, spawn = garage.spawn })
end)

RegisterNetEvent('friese-garage:server:store', function(plate, props, garageId)
    local src, p = source, playerData(source)
    if not p or type(props) ~= 'table' or not FrGarage.Config.Garages[garageId] then return end
    plate = cleanPlate(plate)
    if #plate < 2 or #plate > 12 then return end
    local row = MySQL.single.await('SELECT id FROM friese_vehicles WHERE citizenid = ? AND REPLACE(UPPER(plate), " ", "") = ?', { p.citizenid, plate })
    if not row then notify(src, 'Dit voertuig staat niet op jouw naam.'); return end
    MySQL.update.await('UPDATE friese_vehicles SET props = ?, garage = ?, state = 1 WHERE id = ? AND citizenid = ?', { json.encode(props), garageId, row.id, p.citizenid })
    TriggerClientEvent('friese-garage:client:stored', src)
end)

-- Server-side ownership-safe registration export for dealerships/admin systems.
exports('AddOwnedVehicle', function(src, model, plate, props, garageId)
    local p = playerData(tonumber(src)); if not p then return false end
    plate = cleanPlate(plate)
    if type(model) ~= 'string' or #model < 2 or #model > 60 or #plate < 2 or #plate > 12 then return false end
    garageId = FrGarage.Config.Garages[garageId] and garageId or 'legion'
    local exists = MySQL.scalar.await('SELECT id FROM friese_vehicles WHERE plate = ?', { plate })
    if exists then return false end
    MySQL.insert.await('INSERT INTO friese_vehicles (citizenid, plate, vehicle, props, garage, state) VALUES (?, ?, ?, ?, ?, 1)', { p.citizenid, plate, model, json.encode(type(props) == 'table' and props or {}), garageId })
    return true
end)
exports('GetOwnedVehicles', function(src)
    local p = playerData(tonumber(src)); if not p then return {} end
    return MySQL.query.await('SELECT id, plate, vehicle, garage, state FROM friese_vehicles WHERE citizenid = ?', { p.citizenid }) or {}
end)

RegisterNetEvent('friese-garage:server:spawnFailed', function(plate)
    local src, p = source, playerData(source)
    if not p then return end
    MySQL.update.await('UPDATE friese_vehicles SET state = 1 WHERE citizenid = ? AND REPLACE(UPPER(plate), " ", "") = ?', { p.citizenid, cleanPlate(plate) })
end)
