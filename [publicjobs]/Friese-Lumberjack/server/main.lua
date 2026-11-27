local active, lastAction = {}, {}
local function notify(src, msg) exports['friese-integrations']:Notify(src, msg, 'info', Config.Label) end
RegisterNetEvent('friese-lumberjack:server:start', function()
    local src=source; local player=exports['friese-core']:GetPlayer(src)
    if not player or not player.PlayerData or not player.PlayerData.loaded then return end
    if active[src] then notify(src, 'Je bent al aan het werk.'); return end
    active[src]={step=1, started=os.time()}
    TriggerClientEvent('friese-lumberjack:client:route', src, 1, Config.Route[1])
    notify(src, 'Je bent begonnen als '..Config.Label..'.')
end)
RegisterNetEvent('friese-lumberjack:server:complete', function(step)
    local src=source; local a=active[src]; step=tonumber(step)
    if not a or a.step~=step or not Config.Route[step] then return end
    if lastAction[src] and os.time()-lastAction[src] < Config.StopCooldown then return end
    local ped=GetPlayerPed(src); if not ped or ped==0 then return end
    local p=Config.Route[step]; local c=GetEntityCoords(ped)
    if #(c-vector3(p.x,p.y,p.z)) > Config.MaxDistance then return end
    lastAction[src]=os.time()
    local pay=math.random(Config.MinPay,Config.MaxPay)
    local ok=exports['friese-core']:AddMoney(src,Config.PayoutAccount,pay,'Public job: '..Config.JobId)
    if not ok then notify(src,'Uitbetaling is mislukt.'); return end
    local reward=Config.ItemReward
    if reward and GetResourceState('friese-inventory')=='started' then
        exports['friese-inventory']:AddItem(src,reward.name,math.random(reward.min,reward.max))
    end
    a.step=a.step+1
    if a.step>#Config.Route then active[src]=nil; TriggerClientEvent('friese-lumberjack:client:finished',src); notify(src,('Route afgerond. Je ontving €%s.'):format(pay))
    else TriggerClientEvent('friese-lumberjack:client:route',src,a.step,Config.Route[a.step]); notify(src,('Stop afgerond: €%s.'):format(pay)) end
end)
RegisterNetEvent('friese-lumberjack:server:stop',function() active[source]=nil; TriggerClientEvent('friese-lumberjack:client:finished',source) end)
AddEventHandler('playerDropped',function() active[source]=nil; lastAction[source]=nil end)
