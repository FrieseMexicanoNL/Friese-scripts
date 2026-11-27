local visible = true
RegisterCommand('hud', function() visible = not visible; SendNUIMessage({ action = 'visible', visible = visible }) end, false)
CreateThread(function()
    while true do
        Wait(500)
        if visible and exports['friese-core']:IsPlayerLoaded() then
            local ped = PlayerPedId()
            local data = exports['friese-core']:GetPlayerData() or {}
            local money = data.money or {}
            local job = data.job or {}
            local metadata = data.metadata or {}
            SendNUIMessage({ action = 'update', data = {
                health = math.max(0, GetEntityHealth(ped) - 100), armor = GetPedArmour(ped),
                hunger = tonumber(metadata.hunger) or 100, thirst = tonumber(metadata.thirst) or 100,
                cash = tonumber(money.cash) or 0, bank = tonumber(money.bank) or 0,
                job = job.label or job.name or 'Werkloos', grade = job.gradeLabel or ''
            } })
        end
    end
end)
