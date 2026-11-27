fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-appearance'
author 'Friese-Core'
description 'Standalone character clothing and appearance persistence'
version '0.6.0'
ui_page 'html/index.html'
files { 'html/index.html', 'html/style.css', 'html/app.js' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
dependencies { 'oxmysql', 'friese-core' }
