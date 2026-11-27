local function notify(src, message)
    TriggerClientEvent('friese-multicharacter:client:notify', src, message)
end

local function validName(value)
    if type(value) ~= 'string' then return false end
    value = value:gsub('^%s+', ''):gsub('%s+$', '')
    return #value >= 2 and #value <= 24 and value:match("^[%aÀ-ÿ'%-]+$") ~= nil
end

local function validBirthdate(value)
    if type(value) ~= 'string' or not value:match('^%d%d%d%d%-%d%d%-%d%d$') then return false end
    local y, m, d = value:match('^(%d%d%d%d)%-(%d%d)%-(%d%d)$')
    y, m, d = tonumber(y), tonumber(m), tonumber(d)
    if not y or not m or not d or y < 1900 or y > 2010 or m < 1 or m > 12 or d < 1 or d > 31 then return false end
    local stamp = os.time({ year = y, month = m, day = d, hour = 12 })
    return stamp and os.date('%Y-%m-%d', stamp) == value
end

local function sendCharacters(src)
    local chars = exports['friese-core']:GetCharacters(src) or {}
    TriggerClientEvent('friese-multicharacter:client:open', src, chars, FrieseCharacters.MaxCharacters)
end

AddEventHandler('playerJoining', function()
    local src = source
    CreateThread(function()
        Wait(1800)
        if GetPlayerName(src) then sendCharacters(src) end
    end)
end)

RegisterNetEvent('friese-multicharacter:server:requestCharacters', function()
    sendCharacters(source)
end)

RegisterNetEvent('friese-multicharacter:server:createCharacter', function(data)
    local src = source
    if type(data) ~= 'table' then return end
    if not validName(data.firstname) or not validName(data.lastname) or not validBirthdate(data.birthdate) then
        notify(src, 'Controleer je voornaam, achternaam en geboortedatum.')
        return
    end
    local gender = tonumber(data.gender)
    if gender ~= 0 and gender ~= 1 then notify(src, 'Ongeldig geslacht.'); return end

    local chars = exports['friese-core']:GetCharacters(src) or {}
    if #chars >= FrieseCharacters.MaxCharacters then notify(src, 'Je hebt het maximale aantal personages bereikt.'); return end
    local used = {}
    for _, char in ipairs(chars) do used[tonumber(char.slot)] = true end
    local slot
    for i = 1, FrieseCharacters.MaxCharacters do if not used[i] then slot = i break end end
    if not slot then notify(src, 'Er is geen vrije personageslot beschikbaar.'); return end

    local created = exports['friese-core']:CreateCharacter(src, slot, {
        firstname = data.firstname:gsub('^%l', string.upper),
        lastname = data.lastname:gsub('^%l', string.upper),
        birthdate = data.birthdate,
        gender = gender,
        nationality = 'Nederland'
    })
    if not created then notify(src, 'Personage aanmaken is niet gelukt. Probeer opnieuw.'); return end
    sendCharacters(src)
    notify(src, 'Je personage is aangemaakt. Selecteer het om verder te gaan.')
end)

RegisterNetEvent('friese-multicharacter:server:selectCharacter', function(citizenid)
    local src = source
    if type(citizenid) ~= 'string' or #citizenid > 20 then return end
    local ok = exports['friese-core']:LoadCharacter(src, citizenid)
    if not ok then notify(src, 'Dit personage kon niet worden geladen.'); sendCharacters(src); return end
    TriggerClientEvent('friese-multicharacter:client:characterSelected', src, FrieseCharacters.Spawn)
end)

CreateThread(function()
    Wait(2500)
    for _, playerId in ipairs(GetPlayers()) do
        local src = tonumber(playerId)
        if src and not exports['friese-core']:GetPlayer(src) then sendCharacters(src) end
    end
end)
