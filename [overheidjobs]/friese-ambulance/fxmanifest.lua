fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-ambulance'
description 'Ambulance en medische hulp voor Friese-Core'
version '1.1.0'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'friese-core', 'oxmysql' }
