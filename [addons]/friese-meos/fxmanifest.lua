fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-meos'
author 'Friese-Core'
description 'Standalone police MEOS with searchable citizen records and reports'
version '1.2.0'
ui_page 'html/index.html'
shared_scripts { 'shared/config.lua' }
client_scripts { 'client/main.lua' }
server_scripts { '@oxmysql/lib/MySQL.lua', 'server/main.lua' }
files { 'html/index.html', 'html/style.css', 'html/app.js' }
dependencies { 'oxmysql', 'friese-core' }
