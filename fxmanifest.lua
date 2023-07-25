fx_version 'cerulean'
game 'gta5'

version '1.1.1'
repository 'https://github.com/Qbox-project/qbx-spawn'

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua',
	'@qbx-core/import.lua'
}

modules {
	'qbx-core:core'
}

client_scripts {
	'client/*.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server.lua'
}

lua54 'yes'
use_experimental_fxv2_oal 'yes'
