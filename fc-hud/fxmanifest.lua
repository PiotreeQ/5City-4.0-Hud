fx_version 'cerulean'
game 'gta5'
author 'piotreq'
description '5City 4.0 Hud [discord.gg/piotreqscripts]'
lua54 'yes'

client_scripts {
    'client/*.lua'
}

ui_page 'web/index.html'

files {
    'web/index.html',
    'web/style.css',
    'web/app.js',
    'web/img/*.svg',
    'web/fonts/*.TTF'
}

shared_scripts {
    '@ox_lib/init.lua'
}