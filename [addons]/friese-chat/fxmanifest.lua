fx_version 'cerulean'
game 'gta5'
lua54 'yes'
name 'friese-chat'
author 'Friese-Core'
description 'Integrated Dutch roleplay chat and command suite'
version '1.0.0'
ui_page 'html/index.html'
files { 'html/index.html', 'html/style.css', 'html/app.js' }
shared_script 'config.lua'
client_scripts { 'client/main.lua' }
server_scripts { 'server/main.lua' }
dependencies { 'friese-core' }
