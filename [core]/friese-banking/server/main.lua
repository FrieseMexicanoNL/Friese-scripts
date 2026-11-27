local function notify(src, msg, kind)
    TriggerClientEvent('friese-notify:client:notify', src, { title = 'Friese Bank', description = msg, type = kind or 'info' })
end
RegisterNetEvent('friese-banking:server:open', function()
    local src = source
    local p = exports['friese-core']:GetPlayer(src)
    if not p or not p.PlayerData then return end
    TriggerClientEvent('friese-banking:client:show', src, { bank = p.PlayerData.money.bank or 0, cash = p.PlayerData.money.cash or 0, name = ((p.PlayerData.charinfo or {}).firstname or '') .. ' ' .. ((p.PlayerData.charinfo or {}).lastname or '') })
end)
RegisterNetEvent('friese-banking:server:transfer', function(targetId, amount)
    local src = source; targetId = tonumber(targetId); amount = tonumber(amount)
    if not targetId or targetId == src or not amount or amount % 1 ~= 0 or amount < FrieseBanking.MinTransfer or amount > FrieseBanking.MaxTransfer then return end
    local sender = exports['friese-core']:GetPlayer(src); local receiver = exports['friese-core']:GetPlayer(targetId)
    if not sender or not receiver then notify(src, 'Ontvanger is niet online.', 'error'); return end
    if not exports['friese-core']:RemoveMoney(src, 'bank', amount, 'bank-transfer') then notify(src, 'Onvoldoende banksaldo.', 'error'); return end
    if not exports['friese-core']:AddMoney(targetId, 'bank', amount, 'bank-transfer') then
        exports['friese-core']:AddMoney(src, 'bank', amount, 'transfer-refund'); notify(src, 'Overboeking mislukt; bedrag teruggestort.', 'error'); return
    end
    exports['friese-core']:SavePlayer(src); exports['friese-core']:SavePlayer(targetId)
    MySQL.insert('INSERT INTO friese_bank_transactions (sender_citizenid, receiver_citizenid, amount, transaction_type) VALUES (?, ?, ?, ?)', {sender.PlayerData.citizenid, receiver.PlayerData.citizenid, amount, 'transfer'})
    notify(src, ('€%s is overgemaakt.'):format(amount), 'success'); notify(targetId, ('Je hebt €%s ontvangen.'):format(amount), 'success')
end)
RegisterNetEvent('friese-banking:server:deposit', function(amount)
    local src=source; amount=tonumber(amount); if not amount or amount%1~=0 or amount<1 or amount>FrieseBanking.MaxTransfer then return end
    if exports['friese-core']:RemoveMoney(src,'cash',amount,'bank-deposit') then exports['friese-core']:AddMoney(src,'bank',amount,'bank-deposit'); exports['friese-core']:SavePlayer(src); notify(src,('€%s gestort.'):format(amount),'success') else notify(src,'Onvoldoende contant geld.','error') end
end)
RegisterNetEvent('friese-banking:server:withdraw', function(amount)
    local src=source; amount=tonumber(amount); if not amount or amount%1~=0 or amount<1 or amount>FrieseBanking.MaxTransfer then return end
    if exports['friese-core']:RemoveMoney(src,'bank',amount,'bank-withdraw') then exports['friese-core']:AddMoney(src,'cash',amount,'bank-withdraw'); exports['friese-core']:SavePlayer(src); notify(src,('€%s opgenomen.'):format(amount),'success') else notify(src,'Onvoldoende banksaldo.','error') end
end)
