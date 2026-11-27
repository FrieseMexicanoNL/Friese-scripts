local opened = false
local currentCitizen = nil
local function setOpen(state)
    opened = state
    SetNuiFocus(state,state)
    SendNUIMessage({ action = state and 'open' or 'close' })
end
RegisterNetEvent('friese-meos:client:open',function() setOpen(true) end)
RegisterNetEvent('friese-meos:client:searchResults',function(rows) SendNUIMessage({action='results',rows=rows}) end)
RegisterNetEvent('friese-meos:client:dossier',function(data) currentCitizen=data.citizenid; SendNUIMessage({action='dossier',data=data}) end)
RegisterNetEvent('friese-meos:client:refreshDossier',function(cid) TriggerServerEvent('friese-meos:server:getDossier',cid) end)
RegisterNUICallback('close',function(_,cb) setOpen(false); cb({ok=true}) end)
RegisterNUICallback('search',function(data,cb) TriggerServerEvent('friese-meos:server:search',data.term or ''); cb({ok=true}) end)
RegisterNUICallback('dossier',function(data,cb) currentCitizen=data.citizenid; TriggerServerEvent('friese-meos:server:getDossier',currentCitizen); cb({ok=true}) end)
RegisterNUICallback('report',function(data,cb) TriggerServerEvent('friese-meos:server:addReport',data.citizenid,data.title,data.body); cb({ok=true}) end)
RegisterKeyMapping('friesemeosclose','MEOS sluiten','keyboard','ESC')
RegisterCommand('friesemeosclose',function() if opened then setOpen(false) end end)
