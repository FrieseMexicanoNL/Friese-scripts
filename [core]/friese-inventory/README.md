# Friese-Inventory v0.3.0

Zelfstandige inventory-resource voor Friese-Core. De interface gebruikt de Friese-Core donkerblauw/blauwe huisstijl.

## Vereisten
- FXServer met OneSync
- `oxmysql`
- `friese-core` v0.2.0 of nieuwer
- Een actief geladen personage via Friese-Core

## Installatie
1. Plaats `friese-inventory` naast `friese-core` in `resources/[friese]/`.
2. Controleer dat `oxmysql` en `friese-core` eerder starten.
3. Voeg toe aan `server.cfg`:

```cfg
ensure oxmysql
ensure friese-core
ensure friese-multicharacter
ensure friese-inventory
```

4. De tabel `friese_inventories` wordt bij het starten automatisch aangemaakt. Het SQL-bestand staat ook in `sql/friese-inventory.sql`.
5. Start de server opnieuw en open met F2 of `/inventory`.

## Items toevoegen
Bewerk `shared/items.lua`. Voorbeeld:

```lua
water = {
    label = 'Waterfles',
    weight = 0.5,
    image = 'water.png',
    description = 'Een fles drinkwater.',
    usable = true
}
```

Itemnamen moeten uniek zijn. Het inventorymodel bewaart itemnaam, aantal en metadata. De `image`-waarde is voorbereid voor eigen PNG-bestanden; de huidige UI gebruikt ingebouwde pictogrammen als fallback.

## Usable items
Een andere serverresource kan een itemhandler registreren:

```lua
exports['friese-inventory']:RegisterUsableItem('water', function(source, item)
    -- Valideer en voer server-side de gewenste actie uit.
    -- Verwijder het item pas nadat de actie succesvol is:
    exports['friese-inventory']:RemoveItem(source, 'water', 1)
end)
```

Of luister naar `friese-inventory:server:useItem`.

## Exports
- `AddItem(source, itemName, amount, metadata)`
- `RemoveItem(source, itemName, amount, metadata)`
- `GetInventory(source)`
- `GetItemCount(source, itemName)`
- `RegisterUsableItem(itemName, callback)`

## Huidige functies
- 30 slots, instelbaar in `shared/config.lua`
- 5 visuele quickslots (eerste vijf inventoryposities)
- Gewichtslimiet en itemmetadata
- Item selecteren, gebruiken via geregistreerde handler, splitsen, geven aan speler in de buurt
- Items op de grond leggen en oppakken binnen bereik
- Wallet-overzicht voor cash, bank en zwart geld uit Friese-Core
- Automatische opslag en database-autocreatie
- Server-side validatie van aantallen, itemnamen, gewicht en afstanden

## Bekende grenzen van deze ontwikkelversie
- Gronddrops zijn tijdelijk en verdwijnen na de ingestelde levensduur of bij een serverrestart; persistente world drops volgen later.
- Kofferbakken, handschoenenkastjes, stashcontainers, kleding/equipment, wapenslots en echte toegewezen hotkeys zijn nog niet geïmplementeerd.
- De standaard usable-itemlijst bevat voorbeelditems. De server moet voor elk bruikbaar item een handler registreren.
- Test op een stagingserver voordat je dit op een live server gebruikt.
