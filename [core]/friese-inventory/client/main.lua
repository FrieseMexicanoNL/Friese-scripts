local isOpen=false
local function setOpen(state,data)
 isOpen=state; SetNuiFocus(state,state); SendNUIMessage({action=state and 'open' or 'close',data=data})
end
RegisterCommand(FrInv.Config.OpenCommand,function() if not isOpen then TriggerServerEvent('friese-inventory:server:requestOpen') end end,false)
RegisterKeyMapping(FrInv.Config.OpenCommand,'Open Friese-Inventory','keyboard',FrInv.Config.OpenKey)
RegisterNetEvent('friese-inventory:client:open',function(data) setOpen(true,data) end)
RegisterNetEvent('friese-inventory:client:refresh',function(data) if isOpen then SendNUIMessage({action='refresh',data=data}) end end)
RegisterNetEvent('friese-inventory:client:notify',function(msg) TriggerEvent('chat:addMessage',{color={40,150,255},args={'Friese-Inventory',msg}}) end)
RegisterNetEvent('friese-inventory:client:useItem',function(name) TriggerEvent('friese-inventory:client:usedItem',name) end)
RegisterNUICallback('close',function(_,cb) setOpen(false); cb({ok=true}) end)
RegisterNUICallback('use',function(data,cb) TriggerServerEvent('friese-inventory:server:use',tonumber(data.index)); cb({ok=true}) end)
RegisterNUICallback('drop',function(data,cb) TriggerServerEvent('friese-inventory:server:moveToGround',tonumber(data.index),tonumber(data.amount) or 1); cb({ok=true}) end)
RegisterNUICallback('takeGround',function(data,cb) TriggerServerEvent('friese-inventory:server:takeGround',data.id,tonumber(data.index),tonumber(data.amount) or 1); cb({ok=true}) end)
RegisterNUICallback('give',function(data,cb) TriggerServerEvent('friese-inventory:server:give',tonumber(data.index),tonumber(data.target),tonumber(data.amount) or 1); cb({ok=true}) end)
RegisterNUICallback('split',function(data,cb) TriggerServerEvent('friese-inventory:server:split',tonumber(data.index),tonumber(data.amount)); cb({ok=true}) end)
CreateThread(function() while true do if isOpen then DisableControlAction(0,1,true); DisableControlAction(0,2,true); DisableControlAction(0,24,true); DisableControlAction(0,25,true); DisableControlAction(0,200,true); Wait(0) else Wait(500) end end end)

RegisterNetEvent('friese-inventory:client:equipWeapon',function(weapon)
 local hash=GetHashKey(weapon); GiveWeaponToPed(PlayerPedId(),hash,0,false,true); SetCurrentPedWeapon(PlayerPedId(),hash,true)
end)
RegisterNetEvent('friese-inventory:client:addAmmo',function(amount)
 local ped=PlayerPedId(); local weapon=GetSelectedPedWeapon(ped); if weapon and weapon~=GetHashKey('WEAPON_UNARMED') then AddAmmoToPed(ped,weapon,math.max(0,math.floor(amount or 0))) else TriggerEvent('friese-inventory:client:notify','Je hebt geen wapen vast.') end
end)
