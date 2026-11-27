Friese = Friese or {}
Friese.PlayerData = {}
Friese.IsLoaded = false

RegisterNetEvent('friese-core:client:playerLoaded', function(data)
    Friese.PlayerData = data or {}; Friese.IsLoaded = true
    TriggerEvent('friese-core:client:ready', Friese.PlayerData)
end)
RegisterNetEvent('friese-core:client:jobUpdated', function(job) Friese.PlayerData.job = job end)
RegisterNetEvent('friese-core:client:moneyChanged', function(account, amount, action, reason)
    if Friese.PlayerData.money then
        local current = tonumber(Friese.PlayerData.money[account]) or 0
        if action == 'add' then Friese.PlayerData.money[account] = current + amount
        elseif action == 'remove' then Friese.PlayerData.money[account] = current - amount
        elseif action == 'set' then Friese.PlayerData.money[account] = amount end
    end
    TriggerEvent('friese-core:client:moneyUpdated', account, amount, action, reason)
end)
RegisterNetEvent('friese-core:client:playerUnloaded', function()
    Friese.PlayerData = {}; Friese.IsLoaded = false
end)
exports('GetPlayerData', function() return Friese.PlayerData end)
exports('IsPlayerLoaded', function() return Friese.IsLoaded end)
