fx_version 'cerulean'
game 'gta5'

author 'EddiesLife247'
description 'Enhanced FiveM Accessibility System - Epilepsy protection, visual filters, motor aids, hearing aids, TTS, and more'
version '5.1.2'

license 'MIT'

dependencies {
    'ox_lib',
    'xsound',
}

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua'
}

client_scripts {
    'client/core.lua',          -- MUST BE FIRST - defines AccessibilityManager
    'client/weather.lua',       -- Weather functionality
    'client/accessibility.lua', -- All new accessibility features (epilepsy, motor, hearing, etc.)
    'client/menu.lua',          -- Menu systems
    'client/tts.lua',           -- Text-to-speech
    'client/utility.lua',       -- Utility functions & exports
    'client/commands.lua',      -- Command registration
    'client/keybinds.lua',      -- Keybind registration
    'client/events.lua',        -- Event handlers (last)
    'client/threads.lua',
}

server_scripts {
    'server.lua'
}

lua54 'yes'

provides {
    'accessibility-filters',
    'accessibility-tts',
    'accessibility-menu',
    'accessibility-epilepsy',
    'accessibility-motor',
    'accessibility-hearing'
}

exports {
    'GetLighting',
    'GetAccessibilityState',
    'GetAccessibilityStates',
    'SetAccessibilityState'
}

server_exports {
    'GetPlayerSettings',
    'GetPlayerSetting',
    'SetPlayerSetting',
    'GetAccessibilityStats'
}

tags {
    'accessibility',
    'epilepsy',
    'visual-filters',
    'color-blind',
    'text-to-speech',
    'a11y',
    'disability-support',
    'hearing-impaired',
    'motor-accessibility',
    'ox_lib',
    'menu-system'
}

escrow_ignore {
    'config.lua',
    'IMPORT INTO OELS/*.*',
    'REPLACE XSOUND/*.*'
}