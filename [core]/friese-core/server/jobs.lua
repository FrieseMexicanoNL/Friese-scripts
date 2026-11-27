Friese = Friese or {}
Friese.Jobs = { unemployed = { label = 'Werkloos', grades = { [0] = { label = 'Inwoner', payment = 0 } } } }
function Friese.RegisterJob(name, data)
    if type(name) ~= 'string' or type(data) ~= 'table' or type(data.grades) ~= 'table' then return false end
    Friese.Jobs[name] = data; return true
end
function Friese.SetJob(src, name, grade)
    local player, job = Friese.Player.Get(src), Friese.Jobs[name]
    grade = tonumber(grade)
    if not player or not job or not grade or not job.grades[grade] then return false end
    local g = job.grades[grade]
    player.PlayerData.job = { name = name, label = job.label, grade = grade, gradeLabel = g.label, payment = g.payment or 0, onduty = false }
    TriggerClientEvent('friese-core:client:jobUpdated', src, player.PlayerData.job)
    TriggerEvent('friese-core:server:jobUpdated', src, player.PlayerData.job)
    return true
end
exports('SetJob', Friese.SetJob)
exports('RegisterJob', Friese.RegisterJob)
