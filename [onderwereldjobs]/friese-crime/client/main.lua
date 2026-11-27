local active=false
RegisterCommand('overvallen',function()
 if not lib then return end
 local opts={}
 for kind,cfg in pairs(Config.Activities) do
  for i,loc in ipairs(cfg.locations) do
   opts[#opts+1]={title=cfg.label..' #'..i,description=('Politie vereist: %s'):format(cfg.policeRequired or 0),onSelect=function() TriggerServerEvent('friese-crime:server:start',kind,i) end}
  end
 end
 lib.registerContext({id='friese_crime',title='Friese activiteiten',options=opts}); lib.showContext('friese_crime')
end)
RegisterNetEvent('friese-crime:client:started',function(duration,label)
 active=true; CreateThread(function()
  local untilTime=GetGameTimer()+duration*1000
  while active and GetGameTimer()<untilTime do
   Wait(0); DisableControlAction(0,24,true); DisableControlAction(0,25,true)
   BeginTextCommandPrint('STRING'); AddTextComponentSubstringPlayerName(('~b~%s~s~ - bezig: %ss'):format(label,math.ceil((untilTime-GetGameTimer())/1000))); EndTextCommandPrint(1,true)
  end
  if active then TriggerServerEvent('friese-crime:server:finish') end
 end)
end)
RegisterNetEvent('friese-crime:client:finished',function() active=false end)
AddEventHandler('onResourceStop',function(r) if r==GetCurrentResourceName() and active then TriggerServerEvent('friese-crime:server:cancel') end end)
