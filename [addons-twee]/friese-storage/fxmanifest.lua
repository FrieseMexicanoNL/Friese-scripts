fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-storage'
author 'Friese-Core'
description 'Persistent vehicle trunk and glovebox storage for Friese-Core'
version '0.5.0'
ui_page 'html/index.html'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
files { 'html/index.html', 'html/style.css', 'html/app.js' }
dependencies { 'oxmysql', 'friese-core', 'friese-inventory' }
