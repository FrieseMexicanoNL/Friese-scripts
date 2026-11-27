fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-police'
description 'Politie basis: boetes, arrestaties, fouilleren en dienststatus'
version '1.1.0'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'friese-core', 'friese-integrations', 'oxmysql' }
