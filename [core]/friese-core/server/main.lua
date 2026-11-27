CreateThread(function()
    while GetResourceState('oxmysql') ~= 'started' do Wait(250) end
    Friese.Debug('Core v0.2.0 gestart. Wacht op karakterselectie.')
end)

AddEventHandler('playerDropped', function() Friese.Player.Unload(source) end)

CreateThread(function()
    while true do
        Wait((Friese.Config.SaveInterval or 5) * 60000)
        for src in pairs(Friese.Players) do Friese.Player.Save(src) end
        Friese.Debug('Automatische spelersopslag uitgevoerd.')
    end
end)

Friese.CreateCallback('friese-core:server:getPlayerData', function(src)
    local player = Friese.Player.Get(src)
    return player and player.PlayerData or nil
end)

exports('GetPlayer', function(src) return Friese.Player.Get(src) end)
exports('GetPlayers', function() return Friese.Players end)
exports('GetIdentifier', function(src) return Friese.Database.GetIdentifier(src) end)
exports('GetCharacters', function(src)
    local identifier = Friese.Database.GetIdentifier(src)
    return identifier and Friese.Database.GetCharacters(identifier) or {}
end)
exports('CreateCharacter', function(src, slot, info)
    local identifier = Friese.Database.GetIdentifier(src)
    if not identifier then return nil end
    slot = tonumber(slot)
    if not slot or slot < 1 or slot > Friese.Config.MaxCharacters then return nil end
    if MySQL.scalar.await('SELECT citizenid FROM friese_characters WHERE identifier = ? AND slot = ?', { identifier, slot }) then return nil end
    return Friese.Database.CreateCharacter(identifier, slot, info)
end)
exports('LoadCharacter', function(src, citizenid) return Friese.Player.LoadCharacter(src, citizenid) end)
exports('SavePlayer', function(src) return Friese.Player.Save(src) end)
