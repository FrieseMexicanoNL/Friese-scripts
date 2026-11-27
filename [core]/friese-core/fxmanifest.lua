fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'friese-core'
author 'Friese-Core'
description 'Standalone FiveM roleplay framework core'
version '0.6.0'

shared_scripts {
    'shared/config.lua',
    'shared/utils.lua'
}

client_scripts {
    'client/main.lua',
    'client/functions.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/database.lua',
    'server/callbacks.lua',
    'server/player.lua',
    'server/money.lua',
    'server/jobs.lua',
    'server/main.lua'
}

dependencies { 'oxmysql' }
provide 'friese_core'
