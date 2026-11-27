fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'friese-inventory'
author 'Friese-Core'
description 'Standalone inventory for Friese-Core'
version '0.4.0'

ui_page 'html/index.html'

shared_scripts {
    'shared/config.lua',
    'shared/items.lua'
}

client_scripts { 'client/main.lua' }
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

files { 'html/index.html', 'html/style.css', 'html/app.js', 'html/assets/*' }
dependencies { 'oxmysql', 'friese-core' }
