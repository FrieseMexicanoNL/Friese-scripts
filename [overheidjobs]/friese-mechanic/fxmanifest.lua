fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-mechanic'
description 'Mechanic service, repair and vehicle service records'
version '1.1.0'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'friese-core', 'oxmysql' }
