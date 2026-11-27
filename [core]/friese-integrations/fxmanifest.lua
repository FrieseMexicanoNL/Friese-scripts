fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'friese-integrations'
author 'Friese-Core'
description 'Cross-resource integration layer for the Friese-Core ecosystem'
version '1.0.0'

shared_script 'shared/config.lua'
server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}
dependencies { 'oxmysql', 'friese-core' }
