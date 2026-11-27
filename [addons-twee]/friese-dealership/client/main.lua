RegisterCommand('autocatalogus',function() TriggerServerEvent('friese-dealership:server:catalog') end)
RegisterNetEvent('friese-dealership:client:catalog',function(vehicles)
 local lines={}; for key,v in pairs(vehicles or {}) do lines[#lines+1]=('%s — €%s — /koopauto %s'):format(v.label,v.price,key) end
 TriggerEvent('friese-notify:client:notify',table.concat(lines,' | '),'info')
end)
RegisterCommand('koopauto',function(_,args) if args[1] then TriggerServerEvent('friese-dealership:server:buy',args[1]) end end)
RegisterNetEvent('friese-dealership:client:purchaseComplete',function(model,plate)
 local hash=joaat(model); RequestModel(hash); local timeout=GetGameTimer()+10000; while not HasModelLoaded(hash) and GetGameTimer()<timeout do Wait(50) end
 if not HasModelLoaded(hash) then return end
 local ped=PlayerPedId(); local c=GetEntityCoords(ped); local h=GetEntityHeading(ped); local veh=CreateVehicle(hash,c.x+3.0,c.y,c.z,h,true,true)
 if veh~=0 then SetVehicleNumberPlateText(veh,plate); SetPedIntoVehicle(ped,veh,-1); SetEntityAsMissionEntity(veh,true,true) end; SetModelAsNoLongerNeeded(hash)
end)
