RegisterCommand('outfitopslaan',function(_,args)
 local name=table.concat(args,' '); if name=='' then TriggerEvent('friese-notify:client:notify','Gebruik /outfitopslaan [naam].','info'); return end
 local ped=PlayerPedId(); local c,p={},{}
 for i=0,11 do c[i]={GetPedDrawableVariation(ped,i),GetPedTextureVariation(ped,i),GetPedPaletteVariation(ped,i)} end
 for i=0,7 do p[i]={GetPedPropIndex(ped,i),GetPedPropTextureIndex(ped,i)} end
 TriggerServerEvent('friese-clothing:server:saveOutfit',name,c,p)
end)
RegisterCommand('outfits',function() TriggerServerEvent('friese-clothing:server:getOutfits') end)
RegisterNetEvent('friese-clothing:client:outfits',function(rows)
 if not rows or #rows==0 then TriggerEvent('friese-notify:client:notify','Je hebt nog geen opgeslagen outfits.','info'); return end
 for _,r in ipairs(rows) do print(('[Friese-Clothing] Outfit beschikbaar: %s'):format(r.name)) end
 TriggerEvent('friese-notify:client:notify',('Je hebt %s outfits. Namen staan in F8.'):format(#rows),'info')
end)
