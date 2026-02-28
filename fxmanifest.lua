fx_version 'cerulean'
game 'gta5'

name 'sv_compat'
author 'SanctusVoid Development'
description 'Lightweight compatibility bridge (framework, inventory, notify, progress, target)'
version '2.0.0'

lua54 'yes'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua',
    'framework/**/server.lua',
    'inventory/**/server.lua',
    'target/**/server.lua',
    'notify/**/server.lua',
    'dispatch/**/server.lua',
    'progress/**/server.lua',
    'textui/**/server.lua'
}

client_scripts {
    'client.lua',
    'framework/**/client.lua',
    'inventory/**/client.lua',
    'target/**/client.lua',
    'notify/**/client.lua',
    'dispatch/**/client.lua',
    'progress/**/client.lua',
    'textui/**/client.lua',
    'zone/**/client.lua'
}
