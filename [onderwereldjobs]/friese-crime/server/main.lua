local running,locks={},{}
local function policeCount()
 local total=0
 for _,id in ipairs(GetPlayers()) do local p=exports['friese-core']:GetPlayer(tonumber(id)); local j=p and p.PlayerData and p.PlayerData.job
  if j and (j.name=='police' or j.name=='sheriff') then total=total+1 end
 end
 return total
end
local function findLocation(kind,index)
 local a=Config.Activities[kind]; return a and a.locations[tonumber(index)]
end
RegisterNetEvent('friese-crime:server:start',function(kind,index)
 local src=source; local cfg=Config.Activities[kind]; local loc=findLocation(kind,index)
 if not cfg or not loc or running[src] then return end
 local ped=GetPlayerPed(src); if not ped or ped==0 then return end
 if #(GetEntityCoords(ped)-vector3(loc.x,loc.y,loc.z))>Config.InteractDistance then return end
 local key=kind..':'..index; local now=os.time()
 if locks[key] and locks[key]>now then exports['friese-integrations']:Notify(src,'Deze locatie is nog niet beschikbaar.','error'); return end
 if policeCount()<(cfg.policeRequired or Config.MinPolice) then exports['friese-integrations']:Notify(src,'Er zijn onvoldoende politie-eenheden beschikbaar.','error'); return end
 running[src]={kind=kind,index=tonumber(index),finish=now+Config.DurationSeconds,coords=loc}
 TriggerClientEvent('friese-crime:client:started',src,Config.DurationSeconds,cfg.label)
 exports['friese-integrations']:Log('crime',src,'Activiteit gestart',{kind=kind,location=index})
end)
RegisterNetEvent('friese-crime:server:finish',function()
 local src=source; local a=running[src]; if not a then return end
 local cfg=Config.Activities[a.kind]; local ped=GetPlayerPed(src)
 if os.time()<a.finish or not ped or ped==0 or #(GetEntityCoords(ped)-vector3(a.coords.x,a.coords.y,a.coords.z))>Config.InteractDistance+1.5 then return end
 running[src]=nil; locks[a.kind..':'..a.index]=os.time()+((cfg.cooldown or Config.CooldownMinutes)*60)
 local reward=math.random(cfg.min,cfg.max)
 exports['friese-core']:AddMoney(src,Config.RewardAccount,reward,'Friese activiteit: '..a.kind)
 exports['friese-integrations']:Notify(src,('Opdracht afgerond. Opbrengst: €%s'):format(reward),'success')
 exports['friese-integrations']:Log('crime',src,'Activiteit afgerond',{kind=a.kind,reward=reward})
 TriggerClientEvent('friese-crime:client:finished',src)
end)
RegisterNetEvent('friese-crime:server:cancel',function() running[source]=nil end)
AddEventHandler('playerDropped',function() running[source]=nil end)
