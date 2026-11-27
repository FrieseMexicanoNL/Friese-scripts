Friese = Friese or {}
Friese.Players = {}
Friese.Player = {}
Friese.Player.__index = Friese.Player

function Friese.Player.Create(src, row)
    local self = setmetatable({}, Friese.Player)
    self.Source = src
    self.PlayerData = {
        source = src, identifier = row.identifier, name = GetPlayerName(src) or row.name,
        citizenid = row.citizenid, slot = row.slot,
        money = Friese.SafeDecode(row.money, { cash = 0, bank = 0, black = 0 }),
        charinfo = Friese.SafeDecode(row.charinfo, {}),
        job = Friese.SafeDecode(row.job, Friese.Config.DefaultJob),
        metadata = Friese.SafeDecode(row.metadata, Friese.Config.DefaultMetadata), loaded = true
    }
    Friese.Players[src] = self
    TriggerClientEvent('friese-core:client:playerLoaded', src, self.PlayerData)
    TriggerEvent('friese-core:server:playerLoaded', src, self.PlayerData)
    return self
end

function Friese.Player.Get(src) return Friese.Players[tonumber(src)] end

function Friese.Player.LoadCharacter(src, citizenid)
    src = tonumber(src)
    if not src or not GetPlayerName(src) then return false, 'invalid_source' end
    if Friese.Players[src] then return false, 'already_loaded' end
    local identifier = Friese.Database.GetIdentifier(src)
    if not identifier then return false, 'missing_identifier' end
    local row = Friese.Database.GetCharacter(identifier, citizenid)
    if not row then return false, 'character_not_found' end
    Friese.Player.Create(src, row)
    return true
end

function Friese.Player.Save(src)
    local player = Friese.Player.Get(src)
    if not player then return false end
    return Friese.Database.SavePlayer(player)
end

function Friese.Player.Unload(src)
    local player = Friese.Player.Get(src)
    if not player then return end
    Friese.Database.SavePlayer(player)
    TriggerEvent('friese-core:server:playerUnloaded', src, player.PlayerData)
    TriggerClientEvent('friese-core:client:playerUnloaded', src)
    Friese.Players[src] = nil
end
