# Friese-Chat 1.0.0
Eigen NUI-chat voor Friese-Core. Gebruik T of /chat om te openen. Berichten zonder slash zijn lokale OOC-chat.

## Commands
- Iedereen: `/me`, `/do`, `/ooc`, `/tweet`, `/ad`, `/report`, `/id`
- Politie: `/politie` (job police/sheriff)
- Ambulance: `/ambulance` (job ambulance/ems)
- Monteurs: `/monteur` (job mechanic)
- Admin ACE `friese.admin`: `/staff`, `/announce`, `/clearchat`, `/kick [id] [reden]`, `/setjob [id] [job] [grade]`

Zet standaard CFX `chat` uit om dubbele chat te voorkomen. Voeg `ensure friese-chat` toe na `friese-core` en vóór jobs die chatcommands gebruiken. Pas Config.JobChatJobs aan voor jouw jobnamen.
