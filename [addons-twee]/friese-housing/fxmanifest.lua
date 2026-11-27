fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-housing'
author 'Friese-Core'
description 'Property ownership and key management for Friese-Core'
version '1.0.0'
shared_scripts {'shared/config.lua'}
client_scripts {'client/main.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','server/main.lua'}
dependencies {'friese-core','oxmysql'}
