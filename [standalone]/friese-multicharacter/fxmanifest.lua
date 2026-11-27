fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'friese-multicharacter'
author 'Friese-Core'
description 'Friese-Core character selection and creation'
version '0.2.0'

shared_script 'config.lua'
client_script 'client/main.lua'
server_script 'server/main.lua'

ui_page 'html/index.html'
files { 'html/index.html', 'html/style.css', 'html/app.js' }

dependencies { 'friese-core' }
