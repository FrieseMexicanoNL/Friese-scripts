local menuOpen = false
local componentNames = { [0]='Gezicht', [1]='Masker', [2]='Haar', [3]='Bovenlichaam', [4]='Broek', [5]='Tas', [6]='Schoenen', [7]='Accessoires', [8]='Onderhemd', [9]='Body armor', [10]='Emblemen', [11]='Bovenkleding' }
local propNames = { [0]='Hoed', [1]='Bril', [2]='Ooraccessoire', [6]='Horloge', [7]='Armband' }

local function capture()
    local ped, data = PlayerPedId(), { components = {}, props = {} }
    for i=0,11 do data.components[tostring(i)] = { drawable = GetPedDrawableVariation(ped,i), texture = GetPedTextureVariation(ped,i) } end
    for i=0,7 do data.props[tostring(i)] = { drawable = GetPedPropIndex(ped,i), texture = math.max(0,GetPedPropTextureIndex(ped,i)) } end
    return data
end

local function apply(data)
    if type(data) ~= 'table' then return end
    local ped = PlayerPedId()
    for key, item in pairs(data.components or {}) do
        local id, drawable, texture = tonumber(key), tonumber(item.drawable), tonumber(item.texture)
        if id and id >= 0 and id <= 11 and drawable and texture then
            local max = GetNumberOfPedDrawableVariations(ped,id)
            if drawable >= 0 and drawable < max then
                local textures = GetNumberOfPedTextureVariations(ped,id,drawable)
                if texture >= 0 and texture < textures then SetPedComponentVariation(ped,id,drawable,texture,0) end
            end
        end
    end
    for key, item in pairs(data.props or {}) do
        local id, drawable, texture = tonumber(key), tonumber(item.drawable), tonumber(item.texture)
        if id and id >= 0 and id <= 7 and drawable and texture then
            if drawable == -1 then ClearPedProp(ped,id) else
                local max = GetNumberOfPedPropDrawableVariations(ped,id)
                if drawable >= 0 and drawable < max then
                    local textures = GetNumberOfPedPropTextureVariations(ped,id,drawable)
                    if texture >= 0 and texture < textures then SetPedPropIndex(ped,id,drawable,texture,true) end
                end
            end
        end
    end
end

RegisterNetEvent('friese-appearance:client:load', function(data) if data then apply(data) end end)
RegisterNetEvent('friese-core:client:playerLoaded', function() Wait(1500); TriggerServerEvent('friese-appearance:server:request') end)
RegisterCommand('outfit', function()
    menuOpen = true; SetNuiFocus(true,true)
    SendNUIMessage({ action='open', appearance=capture(), components=componentNames, props=propNames })
end, false)
RegisterNUICallback('close', function(_,cb) menuOpen=false; SetNuiFocus(false,false); cb({ok=true}) end)
RegisterNUICallback('apply', function(data,cb)
    local id, drawable, texture = tonumber(data.id), tonumber(data.drawable), tonumber(data.texture)
    local ped = PlayerPedId()
    if data.kind == 'component' and id and id>=0 and id<=11 and drawable and texture then
        local max=GetNumberOfPedDrawableVariations(ped,id)
        if drawable>=0 and drawable<max then SetPedComponentVariation(ped,id,drawable,math.max(0,texture),0) end
    elseif data.kind == 'prop' and id and id>=0 and id<=7 and drawable and texture then
        if drawable == -1 then ClearPedProp(ped,id) else
            local max=GetNumberOfPedPropDrawableVariations(ped,id)
            if drawable>=0 and drawable<max then SetPedPropIndex(ped,id,drawable,math.max(0,texture),true) end
        end
    end
    cb({ok=true})
end)
RegisterNUICallback('save', function(_,cb) TriggerServerEvent('friese-appearance:server:save',capture()); cb({ok=true}) end)
