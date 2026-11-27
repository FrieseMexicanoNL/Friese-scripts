local byId = {}
for _, location in ipairs(FrieseSpawn.Locations) do byId[location.id] = location end

RegisterNetEvent('friese-spawn:server:select', function(id)
    local src = source
    if type(id) ~= 'string' then return end
    local player = exports['friese-core']:GetPlayer(src)
    if not player or not player.PlayerData or not player.PlayerData.loaded then return end
    local location = byId[id]
    if not location or type(location.coords) ~= 'table' then return end
    TriggerClientEvent('friese-spawn:client:complete', src, {
        id = location.id, x = location.coords.x, y = location.coords.y,
        z = location.coords.z, w = location.coords.w or 0.0
    })
end)
