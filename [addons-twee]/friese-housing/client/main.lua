local nearId=nil
CreateThread(function()
    while true do
        local wait=1000; local ped=PlayerPedId(); local pos=GetEntityCoords(ped); nearId=nil
        for id,house in pairs(Housing.Config.Properties) do
            local dist=#(pos-house.entrance)
            if dist<15.0 then wait=0; DrawMarker(2,house.entrance.x,house.entrance.y,house.entrance.z+0.15,0,0,0,0,0,0,0.22,0.22,0.22,24,137,255,190,false,true,2,false,nil,nil,false) end
            if dist<Housing.Config.InteractionDistance then nearId=id; BeginTextCommandDisplayHelp('STRING'); AddTextComponentSubstringPlayerName(('Druk op ~INPUT_CONTEXT~ om woning te beheren: %s'):format(house.label)); EndTextCommandDisplayHelp(0,false,true,-1) end
        end
        if nearId and IsControlJustReleased(0,38) then TriggerServerEvent('friese-housing:server:propertyInfo',nearId) end
        Wait(wait)
    end
end)
RegisterNetEvent('friese-housing:client:info',function(data)
    local msg=('Woning: %s | Prijs: €%s | %s'):format(data.label,data.price,data.owner and 'Eigenaar: '..data.owner or 'Beschikbaar')
    TriggerEvent('chat:addMessage',{color={45,150,255},args={'Friese Housing',msg}})
    if not data.owner then TriggerEvent('chat:addMessage',{args={'Friese','Koop met /huis kopen '..data.id}}) end
end)
RegisterCommand('huis',function(_,args)
    local action=args[1]; local id=args[2]
    if action=='kopen' and id then TriggerServerEvent('friese-housing:server:buy',id)
    elseif action=='sleutel' and id and tonumber(args[3]) then TriggerServerEvent('friese-housing:server:giveKey',id,tonumber(args[3]))
    elseif action=='mijn' then TriggerServerEvent('friese-housing:server:myHomes')
    else TriggerEvent('chat:addMessage',{args={'Friese','Gebruik: /huis kopen [id] | /huis sleutel [id] [server-id] | /huis mijn'}}) end
end)
RegisterNetEvent('friese-housing:client:homes',function(rows)
    if #rows==0 then TriggerEvent('chat:addMessage',{args={'Friese','Je bezit nog geen woningen.'}}); return end
    for _,r in ipairs(rows) do TriggerEvent('chat:addMessage',{args={'Woning',r.property_id..' - '..r.label}}) end
end)
