fx_version 'cerulean'
game 'gta5'

author 'Siku Studio'
description 'A modern, modular HUD for the SIKU ecosystem — delivering clean, responsive player vitals, navigation, voice, radio, and vehicle telemetry through a lightweight, customizable interface built for immersive FiveM roleplay experiences.'
version '0.2.0'

name 'siku_hud'

lua54 'yes'

shared_scripts {
  '@siku_core/init.lua',
  'config/translation.lua',
  'config/hud.lua',
}

server_scripts {
  'server/init.lua',
}

client_scripts {
  'client/modules/push.lua',
  'client/modules/api.lua',
  'client/modules/vitals.lua',
  'client/modules/location.lua',
  'client/modules/vehicle.lua',
  'client/modules/voice.lua',
  'client/modules/nui.lua',
}

ui_page 'web/dist/index.html'

files {
  'translations/*.lua',
  'web/dist/**/*',
}

dependencies {
  'siku_core',
  'siku_status',
}
