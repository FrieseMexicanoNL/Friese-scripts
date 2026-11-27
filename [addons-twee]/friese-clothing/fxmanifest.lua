fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-clothing'
description 'Basic clothing presets and outfit persistence'
version '1.1.0'
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'friese-core', 'oxmysql' }
