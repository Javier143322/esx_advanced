fx_version 'cerulean'
game 'gta5'

name 'esx_advanced_weapons'
author 'TuNombre'
description 'Sistema avanzado de fabricación y modificación de armas legales, ilegales y futuristas'
version '3.0.0'

shared_scripts {
    '@es_extended/imports.lua',
    'config.lua',
    'config_advanced_weapons.lua'
}

client_scripts {
    'client/main.lua',
    'client/crafting.lua',
    'client/modifications.lua',
    'client/licenses.lua',
    'client/weapons.lua',
    'client/energy_weapons.lua'
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    'server/main.lua',
    'server/crafting.lua',
    'server/modifications.lua',
    'server/licenses.lua',
    'server/police.lua',
    'server/energy_weapons.lua'
}

dependencies {
    'es_extended'
}
