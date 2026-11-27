# Friese-Core

**Friese-Core** is een zelfstandig FiveM-roleplayframework met losse resources voor core-functionaliteit, publieke banen, overheidsdiensten, roleplay-tools en aanvullende gameplay-systemen.

> **Projectstatus:** dit project is in ontwikkeling. De aanwezigheid van een resource betekent niet automatisch dat alle functies of koppelingen al volledig zijn getest op een live FXServer. Test wijzigingen eerst op een aparte server en maak altijd een backup van je database en resources.

## Inhoud

- [Functies en resources](#functies-en-resources)
- [Mappenstructuur](#mappenstructuur)
- [Benodigdheden](#benodigdheden)
- [Installatie](#installatie)
- [Database](#database)
- [txAdmin Recipe](#txadmin-recipe)
- [Configuratie en startvolgorde](#configuratie-en-startvolgorde)
- [Problemen melden](#problemen-melden)

## Functies en resources

### Core — `[core]`

| Resource | Doel |
|---|---|
| `friese-core` | Frameworkbasis en spelergegevens |
| `friese-inventory` | Inventaris en itembeheer |
| `friese-banking` | Geld- en bankfunctionaliteit |
| `friese-integrations` | Gedeelde integratie-API's tussen resources |
| `friese-notify` | Meldingen |

### Addons — `[addons]`

`friese-admin`, `friese-chat`, `friese-dispatch`, `friese-documents`, `friese-meos` en `friese-phone`.

### Addons twee — `[addons-twee]`

`friese-business`, `friese-clothing`, `friese-crafting`, `friese-dealership`, `friese-garage`, `friese-hospital`, `friese-housing`, `friese-impound`, `friese-keys`, `friese-shops` en `friese-storage`.

### Onderwereldjobs — `[onderwereldjobs]`

`friese-crime`, `friese-drugs` en `friese-gangs`.

### Overheidjobs — `[overheidjobs]`

`friese-police`, `friese-ambulance` en `friese-mechanic`.

### Publieke banen — `[publicjobs]`

`friese-jobs`, `Friese-Construction`, `Friese-Delivery`, `Friese-Diving`, `Friese-Farming`, `Friese-Fishing`, `Friese-Garbage`, `Friese-Hunting`, `Friese-Lumberjack`, `Friese-Mining`, `Friese-Postal`, `Friese-Recycling` en `Friese-Trucker`.

### Standalone — `[standalone]`

`friese-appearance`, `friese-hud`, `friese-logs` en `friese-multicharacter`.

## Mappenstructuur

```text
resources/
├── [addons]/
├── [addons-twee]/
├── [core]/
├── [onderwereldjobs]/
├── [overheidjobs]/
├── [publicjobs]/
└── [standalone]/
```

Resource-mapnamen zijn belangrijk: gebruik de namen zoals ze in deze repository staan. Hernoem resources niet zonder ook eventuele `ensure`-regels, exports en resource-referenties aan te passen.

## Benodigdheden

- Een werkende FXServer-artifact.
- txAdmin (optioneel, aanbevolen voor serverbeheer en recipe-installatie).
- MySQL/MariaDB.
- `oxmysql` voor databaseverbindingen.
- De Cfx.re standaardresources die jouw serverconfiguratie nodig heeft.

Controleer per `fxmanifest.lua` welke dependencies daadwerkelijk vereist zijn. Installeer niet blind extra frameworks zoals ESX, QBCore of Qbox: Friese-Core is opgezet als eigen framework en zulke frameworks kunnen dubbele systemen veroorzaken.

## Installatie

1. Maak een backup van je volledige servermap en database.
2. Download deze repository als ZIP of clone hem met Git.
3. Plaats de resourcecategorieën in de `resources`-map van je FXServer.
4. Controleer de dependencies in de `fxmanifest.lua`-bestanden.
5. Configureer de databaseverbinding van `oxmysql` in je serverconfiguratie. Zet wachtwoorden en tokens nooit in een openbare repository.
6. Importeer de SQL volgens de database-instructies hieronder.
7. Voeg de resources aan `server.cfg` toe in dependency-volgorde.
8. Start eerst op een testserver en controleer de serverconsole, F8-console en database.

## Database

SQL-bestanden kunnen per resource in een `sql/`-map aanwezig zijn. Controleer de repository op alle `.sql`-bestanden en voer de benodigde schema's uit op de juiste database voordat je de bijbehorende resources start.

Voer SQL niet zomaar herhaaldelijk uit op een live database. `CREATE TABLE IF NOT EXISTS` maakt ontbrekende tabellen aan, maar wijzigt bestaande tabelstructuren niet automatisch. Maak vooraf een backup en controleer eventuele migraties.

## txAdmin Recipe

De txAdmin Recipe is bedoeld om de installatie te automatiseren. Gebruik de recipe-YAML die bij de release of installatiehandleiding van dit project hoort en volg de instructies daarin. Een recipe moet worden getest op een lege testserver: controleer of alle GitHub-downloadpaden, SQL-importacties, configuratievariabelen en `ensure`-regels overeenkomen met de huidige repositorybranch.

Recipe-template (na het toevoegen van `recipe.yaml` aan de hoofdmap):

```text
https://raw.githubusercontent.com/FrieseMexicanoNL/Friese-scripts/main/recipe.yaml
```

Als `recipe.yaml` niet in de hoofdmap van de gekozen branch staat, werkt deze URL niet; plaats het bestand dan eerst op die locatie of gebruik de juiste raw-URL.

## Configuratie en startvolgorde

Start database-afhankelijkheden en de frameworkbasis vóór resources die daarvan gebruikmaken. Een algemene richtlijn:

1. `oxmysql`
2. `friese-core`
3. `friese-notify`
4. `friese-inventory` en `friese-banking`
5. `friese-integrations`
6. overige resources, in volgorde van hun daadwerkelijke dependencies

Dit is een richtlijn, geen gegarandeerde volledige `server.cfg`. Controleer de exports en dependencies in de huidige code voordat je de definitieve startvolgorde vastlegt. Start niet tegelijk meerdere resources die dezelfde chat, spawn-, inventory- of geldfunctionaliteit beheren.

## Problemen melden

Open een GitHub Issue en vermeld:

- Welke resource en versie je gebruikt.
- Welke FXServer-artifact en databaseversie je gebruikt.
- De exacte foutmelding uit de serverconsole of F8-console.
- De stappen waarmee je de fout kunt reproduceren.
- Relevante configuratie (verwijder wachtwoorden, tokens en identifiers).

## Licentie

Controleer de licentie- en gebruiksvoorwaarden in deze repository voordat je scripts herverdeelt of commercieel gebruikt. Als er nog geen `LICENSE`-bestand aanwezig is, is er hiermee geen open-sourcelicentie verleend.

---

Gemaakt voor de Friese-Core FiveM roleplay-community. Bijdragen en foutmeldingen zijn welkom via GitHub.
