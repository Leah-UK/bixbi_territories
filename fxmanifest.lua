--[[----------------------------------
Creation Date:	10/05/2021
Discord: View Link on 'versioncheck' URL
]]------------------------------------
fx_version 'cerulean'
game 'gta5'
author 'Leah#0001'
version '1.0'
-- versioncheck 'https://raw.githubusercontent.com/Leah-UK/FiveM-Script-Versioning/main/bixbi_territories.lua'

shared_scripts {
	'@es_extended/imports.lua',
	'config.lua'
}

client_scripts {
	'client/client.lua',
	'client/menu.lua'
}

server_scripts {
	-- '@async/async.lua',
	-- '@mysql-async/lib/MySQL.lua',
	'server/server.lua'
}

dependencies {
	'bixbi_core',
	'ox_inventory'
}

exports {
	"TerritoryInfoMenu"
}