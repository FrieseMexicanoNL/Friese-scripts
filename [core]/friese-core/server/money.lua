Friese = Friese or {}
local accounts = { cash = true, bank = true, black = true }
local function getPlayer(src) return Friese.Player.Get(src) end

function Friese.AddMoney(src, account, amount, reason)
    local player = getPlayer(src); amount = tonumber(amount)
    if not player or not accounts[account] or not Friese.IsPositiveNumber(amount) then return false end
    player.PlayerData.money[account] = (tonumber(player.PlayerData.money[account]) or 0) + amount
    TriggerClientEvent('friese-core:client:moneyChanged', src, account, amount, 'add', reason or 'unknown')
    TriggerEvent('friese-core:server:moneyChanged', src, account, amount, 'add', reason or 'unknown')
    return true
end

function Friese.RemoveMoney(src, account, amount, reason)
    local player = getPlayer(src); amount = tonumber(amount)
    if not player or not accounts[account] or not Friese.IsPositiveNumber(amount) then return false end
    local current = tonumber(player.PlayerData.money[account]) or 0
    if current < amount then return false end
    player.PlayerData.money[account] = current - amount
    TriggerClientEvent('friese-core:client:moneyChanged', src, account, amount, 'remove', reason or 'unknown')
    TriggerEvent('friese-core:server:moneyChanged', src, account, amount, 'remove', reason or 'unknown')
    return true
end

function Friese.SetMoney(src, account, amount, reason)
    local player = getPlayer(src); amount = tonumber(amount)
    if not player or not accounts[account] or not amount or amount < 0 or amount ~= math.floor(amount) then return false end
    local old = tonumber(player.PlayerData.money[account]) or 0
    player.PlayerData.money[account] = amount
    TriggerClientEvent('friese-core:client:moneyChanged', src, account, amount, 'set', reason or 'unknown')
    TriggerEvent('friese-core:server:moneyChanged', src, account, amount - old, 'set', reason or 'unknown')
    return true
end

exports('AddMoney', Friese.AddMoney)
exports('RemoveMoney', Friese.RemoveMoney)
exports('SetMoney', Friese.SetMoney)
