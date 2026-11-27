RegisterCommand('drugmenu',function()
 if not lib then return end
 local opts={}
 for id,d in pairs(Config.Drugs) do
  opts[#opts+1]={title=d.label..' - oogsten',onSelect=function() TriggerServerEvent('friese-drugs:server:harvest',id) end}
  for i,step in ipairs(d.stages) do opts[#opts+1]={title=d.label..' - '..step.label,onSelect=function() TriggerServerEvent('friese-drugs:server:process',id,i) end} end
  opts[#opts+1]={title=d.label..' - verkopen aan NPC',onSelect=function() TriggerServerEvent('friese-drugs:server:sell',id,1,false) end}
  opts[#opts+1]={title=d.label..' - geheime verkoop',onSelect=function() TriggerServerEvent('friese-drugs:server:sell',id,1,true) end}
 end
 lib.registerContext({id='friese_drugs',title='Friese Drugs',options=opts}); lib.showContext('friese_drugs')
end)
