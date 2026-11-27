fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-phone'
author 'Friese-Core'
description 'Standalone smartphone with contacts, SMS, recent calls and service apps'
version '0.9.0'
ui_page 'html/index.html'
shared_scripts {'shared/config.lua'}
client_scripts {'client/main.lua'}
server_scripts {'@oxmysql/lib/MySQL.lua','server/main.lua'}
files {'html/index.html','html/style.css','html/app.js'}
dependencies {'friese-core','oxmysql'}
