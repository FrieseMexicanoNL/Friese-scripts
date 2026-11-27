local blip, running = nil, false
RegisterCommand('fishing',function() TriggerServerEvent('friese-fishing:server:start') end,false)
RegisterNetEvent('friese-fishing:client:route',function(step,point)
    running=true; if blip then RemoveBlip(blip) end
    blip=AddBlipForCoord(point.x,point.y,point.z); SetBlipRoute(blip,true); SetBlipRouteColour(blip,3)
    SetBlipSprite(blip,1); SetBlipScale(blip,0.85); SetBlipAsShortRange(blip,false)
    BeginTextCommandSetBlipName('STRING'); AddTextComponentString(Config.Label..' - '..step); EndTextCommandSetBlipName(blip)
    CreateThread(function()
        while running and DoesBlipExist(blip) do
            Wait(0); local c=GetEntityCoords(PlayerPedId())
            if #(c-vector3(point.x,point.y,point.z)) < Config.InteractionDistance then
                DrawMarker(2,point.x,point.y,point.z+0.35,0,0,0,0,0,0,0.35,0.35,0.25,35,125,220,190,false,true,2,false,nil,nil,false)
                BeginTextCommandDisplayHelp('STRING'); AddTextComponentSubstringPlayerName('Druk op ~INPUT_CONTEXT~ om '..Config.Action:lower()); EndTextCommandDisplayHelp(0,false,true,-1)
                if IsControlJustReleased(0,38) then TriggerServerEvent('friese-fishing:server:complete',step); Wait(1200); break end
            end
        end
    end)
end)
RegisterNetEvent('friese-fishing:client:finished',function() running=false; if blip then RemoveBlip(blip); blip=nil end end)
RegisterCommand('stopfishing',function() TriggerServerEvent('friese-fishing:server:stop') end,false)
