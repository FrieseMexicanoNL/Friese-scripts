Friese = Friese or {}
Friese.Database = {}

function Friese.Database.GetIdentifier(src)
    local wanted = Friese.Config.IdentifierType or 'license'
    for _, identifier in ipairs(GetPlayerIdentifiers(src)) do
        if identifier:sub(1, #wanted + 1) == wanted .. ':' then return identifier end
    end
end

function Friese.Database.GetCharacters(identifier)
    return MySQL.query.await('SELECT citizenid, slot, charinfo, job, last_seen FROM friese_characters WHERE identifier = ? ORDER BY slot ASC', { identifier }) or {}
end

function Friese.Database.GetCharacter(identifier, citizenid)
    return MySQL.single.await('SELECT * FROM friese_characters WHERE identifier = ? AND citizenid = ?', { identifier, citizenid })
end

function Friese.Database.CreateCharacter(identifier, slot, info)
    local citizenid = ('FR%08d'):format(math.random(0, 99999999))
    while MySQL.scalar.await('SELECT citizenid FROM friese_characters WHERE citizenid = ?', { citizenid }) do
        citizenid = ('FR%08d'):format(math.random(0, 99999999))
    end
    local charinfo = {
        firstname = info.firstname, lastname = info.lastname,
        birthdate = info.birthdate, gender = info.gender,
        nationality = info.nationality or 'Nederland'
    }
    local job = Friese.Config.DefaultJob
    local money = { cash = Friese.Config.StartingCash, bank = Friese.Config.StartingBank, black = 0 }
    MySQL.insert.await([[
        INSERT INTO friese_characters (citizenid, identifier, slot, name, money, charinfo, job, metadata)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ]], {
        citizenid, identifier, slot, (info.firstname .. ' ' .. info.lastname),
        json.encode(money), json.encode(charinfo), json.encode(job), json.encode(Friese.Config.DefaultMetadata)
    })
    return Friese.Database.GetCharacter(identifier, citizenid)
end

function Friese.Database.SavePlayer(player)
    local data = player and player.PlayerData
    if not data then return false end
    MySQL.update.await([[
        UPDATE friese_characters
        SET name = ?, money = ?, charinfo = ?, job = ?, metadata = ?, last_seen = CURRENT_TIMESTAMP
        WHERE citizenid = ? AND identifier = ?
    ]], {
        GetPlayerName(player.Source) or data.name, json.encode(data.money), json.encode(data.charinfo),
        json.encode(data.job), json.encode(data.metadata), data.citizenid, data.identifier
    })
    return true
end
