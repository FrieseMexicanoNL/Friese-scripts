fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-documents'
author 'Friese-Core'
description 'Identity and licence documents for Friese-Core'
version '1.0.0'
ui_page 'html/index.html'
shared_scripts {'shared/config.lua'}
client_scripts {'client/main.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','server/main.lua'}
files {'html/index.html','html/style.css','html/app.js'}
dependencies {'friese-core','oxmysql'}
