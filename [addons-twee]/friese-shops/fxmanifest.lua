fx_version 'cerulean'
game 'gta5'
lua54 'yes'
author 'Friese-Core'
description 'Friese-Shops module'
version '1.4.0'
shared_scripts { 'shared/config.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
client_scripts { 'client/main.lua' }
dependencies { 'oxmysql', 'friese-core', 'friese-inventory', 'friese-integrations' }
