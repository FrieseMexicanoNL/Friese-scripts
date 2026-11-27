fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-hospital'
author 'Friese-Core'
description 'Hospital check-in and medical record system for Friese-Core'
version '1.2.0'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'oxmysql', 'friese-core', 'friese-notify' }
