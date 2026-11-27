fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-impound'
author 'Friese-Core'
description 'Police impound and owner vehicle release system'
version '1.2.0'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'oxmysql', 'friese-core', 'friese-notify', 'friese-police', 'friese-garage' }
