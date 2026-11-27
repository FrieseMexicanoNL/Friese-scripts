RegisterNetEvent('friese-core:client:jobUpdated', function(job)
    if job and job.label then
        TriggerEvent('friese-notify:client:notify', ('Je functie is nu: %s (%s).'):format(job.label, job.gradeLabel or 'Onbekend'), 'info')
    end
end)
