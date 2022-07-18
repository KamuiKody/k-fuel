fx_version 'cerulean'
game 'gta5'

name 'K-Fuel'
description 'MultiFuel Handling resource! -- This resource is still a big work in progress any large contributions to the code would be greatly appreciated!'
author 'KamuiKody'
contact 'https://discord.gg/3j9b439TeY'

shared_script 'config.lua'

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    'client.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}