CreateThread(function()
    while GetResourceState('friese-core') ~= 'started' do Wait(250) end
    for name, data in pairs(FrieseJobs) do
        exports['friese-core']:RegisterJob(name, data)
    end
    print(('[Friese-Jobs] %s functies geregistreerd.'):format((function() local n=0 for _ in pairs(FrieseJobs) do n=n+1 end return n end)()))
end)

RegisterCommand('setjob', function(src, args)
    if src ~= 0 and not IsPlayerAceAllowed(src, 'friese.admin') then
        TriggerClientEvent('friese-notify:client:notify', src, 'Geen toestemming.', 'error' )
        return
    end
    local target, job, grade = tonumber(args[1]), tostring(args[2] or ''), tonumber(args[3])
    if not target or not GetPlayerName(target) or not FrieseJobs[job] or not grade or not FrieseJobs[job].grades[grade] then
        local usage = 'Gebruik: /setjob [ speler-ID ] [ job ] [ grade ]'
        if src == 0 then print(usage) else TriggerClientEvent('friese-notify:client:notify', src, usage, 'error' ) end
        return
    end
    local ok = exports['friese-core']:SetJob(target, job, grade)
    if ok then
        exports['friese-core']:SavePlayer(target)
        TriggerClientEvent('friese-notify:client:notify', target, ('Je functie is gewijzigd naar %s.'):format(FrieseJobs[job].label), 'success' )
        if src ~= 0 then TriggerClientEvent('friese-notify:client:notify', src, 'Functie succesvol aangepast.', 'success' ) end
    end
end, false)

exports('GetJobs', function() return FrieseJobs end)
