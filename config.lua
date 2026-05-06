-- =============================================================================
-- FIVEM ACCESSIBILITY SYSTEM - CONFIGURATION
-- =============================================================================

Config = {}

-- =============================================================================
-- ADVANCED FEATURES
-- =============================================================================

Config.Advanced = {
    debugMode = true,
    autoSaveInterval = 30000,
    performanceMonitoring = false,
    maxSettingsPerPlayer = 50,
    serverValidation = true,
    auditLogging = true,
    externalBackup = false,
    customFilters = {}
}

-- =============================================================================
-- TIMING
-- =============================================================================
Config.failSafeInterval = 5000
Config.failsafe = false
Config.StaticWeather = 'CLEAR'
Config.WeatherThread = { updateInterval = 750 }

-- =============================================================================
-- LIGHTING SYSTEM CONFIGURATION
-- =============================================================================
Config.LightingSystem = {
    -- Which lighting system does your server use?
    -- "default" = Built-in GTA/FiveM native suppression
    -- "luxart"  = Luxart Vehicle Control (lvc)
    -- "oels"    = Open Emergency Lighting System
    system = "default",

    resourceNames = {
        luxart = "lvc",
        oels   = "oels"
    }
}

-- =============================================================================
-- VISUAL ALERT SYSTEM (for hearing impaired)
-- =============================================================================
Config.VisualAlerts = {
    -- Enable visual HUD alerts when sounds occur nearby
    enabled = true,

    -- Detection radius in metres
    sirenRadius    = 50.0,
    gunshotRadius  = 30.0,
    explosionRadius = 80.0,

    -- How long each alert shows on screen (milliseconds)
    alertDuration = 3000,

    -- How often to check for nearby events (milliseconds)
    checkInterval = 500,
}

-- =============================================================================
-- ACCESSIBILITY TOGGLES
-- =============================================================================
Config.Toggles = {

    -- -------------------------------------------------------------------------
    -- EPILEPSY / FLASH PROTECTION
    -- -------------------------------------------------------------------------
    lighting = {
        label       = 'Emergency Vehicle Lighting',
        description = 'Suppress flashing/strobing lights on emergency vehicles. Audio (sirens) continues to play.',
        default     = false,
        category    = 'epilepsy'
    },
    explosionFlash = {
        label       = 'Explosion Flash Suppression',
        description = 'Reduce the intense white screen flash caused by explosions and grenades.',
        default     = false,
        category    = 'epilepsy'
    },
    muzzleFlash = {
        label       = 'Muzzle Flash Reduction',
        description = 'Reduce the strobe-like muzzle flash from rapid gunfire.',
        default     = false,
        category    = 'epilepsy'
    },
    screenShake = {
        label       = 'Screen Shake Reduction',
        description = 'Dampen violent camera shake caused by explosions, crashes, and ragdolling.',
        default     = false,
        category    = 'epilepsy'
    },
    weather = {
        label       = 'Static Weather',
        description = 'Force clear static weather, preventing lightning flashes and storm effects.',
        default     = false,
        category    = 'epilepsy'
    },

    -- -------------------------------------------------------------------------
    -- VISUAL COMFORT
    -- -------------------------------------------------------------------------
    motionBlur = {
        label       = 'Disable Motion Blur',
        description = 'Remove the motion blur effect that occurs at high speeds or during camera movement.',
        default     = false,
        category    = 'visual'
    },
    chromaticAberration = {
        label       = 'Disable Chromatic Aberration',
        description = 'Remove the colour fringing post-processing effect on screen edges.',
        default     = false,
        category    = 'visual'
    },
    cameraSway = {
        label       = 'Reduce Camera Sway',
        description = 'Minimise the constant camera bob and sway while walking or running.',
        default     = false,
        category    = 'visual'
    },
    headlightGlare = {
        label       = 'Reduce Headlight Glare',
        description = 'Reduce the intense glare effect from oncoming vehicle headlights at night.',
        default     = false,
        category    = 'visual'
    },

    -- -------------------------------------------------------------------------
    -- COLOR FILTERS
    -- -------------------------------------------------------------------------
    dim = {
        label       = 'Dimming Filter',
        description = 'Apply a dimming overlay to reduce overall screen brightness and eye strain.',
        default     = false,
        category    = 'filters'
    },
    brown = {
        label       = 'Brown Tint Filter',
        description = 'Apply a warm brown/sepia tint that can reduce eye strain.',
        default     = false,
        category    = 'filters'
    },
    blue = {
        label       = 'Blue Tint Filter',
        description = 'Apply a cool blue tint that may help with certain visual sensitivities.',
        default     = false,
        category    = 'filters'
    },
    green = {
        label       = 'Green Tint Filter',
        description = 'Apply a green tint that can be easier on the eyes for some users.',
        default     = false,
        category    = 'filters'
    },
    orange = {
        label       = 'Orange Tint Filter',
        description = 'Apply a warm orange tint similar to blue-light filtering for evening use.',
        default     = false,
        category    = 'filters'
    },

    -- -------------------------------------------------------------------------
    -- COLOUR BLINDNESS ASSISTANCE
    -- -------------------------------------------------------------------------
    protanopia = {
        label       = 'Protanopia Assistance',
        description = 'Filter to help users with red colour blindness distinguish colours better.',
        default     = false,
        category    = 'colorblind'
    },
    deuteranopia = {
        label       = 'Deuteranopia Assistance',
        description = 'Filter to help users with green colour blindness distinguish colours better.',
        default     = false,
        category    = 'colorblind'
    },
    tritanopia = {
        label       = 'Tritanopia Assistance',
        description = 'Filter to help users with blue colour blindness distinguish colours better.',
        default     = false,
        category    = 'colorblind'
    },

    -- -------------------------------------------------------------------------
    -- MOTOR / PHYSICAL ACCESSIBILITY
    -- -------------------------------------------------------------------------
    sprintToggle = {
        label       = 'Sprint Toggle Mode',
        description = 'Press once to sprint, press again to stop. No need to hold the sprint key.',
        default     = false,
        category    = 'motor'
    },

    -- -------------------------------------------------------------------------
    -- HEARING IMPAIRED
    -- -------------------------------------------------------------------------
    visualAlerts = {
        label       = 'Visual Sound Alerts',
        description = 'Show on-screen HUD indicators when sirens, gunshots, or explosions occur nearby — useful if you cannot hear audio cues.',
        default     = false,
        category    = 'hearing'
    },

    -- -------------------------------------------------------------------------
    -- COGNITIVE / HUD
    -- -------------------------------------------------------------------------
    simplifiedHud = {
        label       = 'Simplified HUD',
        description = 'Hide non-essential HUD elements to reduce visual noise and on-screen clutter.',
        default     = false,
        category    = 'cognitive'
    },
}

-- =============================================================================
-- TEXT-TO-SPEECH CONFIGURATION
-- =============================================================================

Config.TextToSpeech = {
    command      = "tts",
    language     = "en-US",
    maxDistance  = 5.0,
    volume       = 1.0,
    maxTextLength = 500,
    cooldown     = 3000,
    logUsage     = false
}

-- =============================================================================
-- USER INTERFACE CONFIGURATION
-- =============================================================================

Config.UI = {
    useAnimations = true,
    theme         = "default",
    iconSet       = "fontawesome",
    showDescriptions = true,
    menuPosition  = "center",
    fontSize      = "normal",
}

-- =============================================================================
-- NOTIFICATION SYSTEM
-- =============================================================================

Config.Notify = function(title, message, type)
    local notificationType = type or "inform"

    if lib and lib.notify then
        lib.notify({
            title       = title,
            description = message,
            type        = notificationType,
            duration    = 5000,
            position    = 'top-right',
            style = {
                backgroundColor = '#141517',
                color           = '#C1C2C5',
                ['.description'] = { color = '#909296' }
            }
        })
        return true
    end

    if ESX and ESX.ShowNotification then
        local color = 'blue'
        if notificationType == 'error'   then color = 'red'
        elseif notificationType == 'success' then color = 'green'
        elseif notificationType == 'warning' then color = 'orange'
        end
        ESX.ShowNotification('~' .. color .. '~[' .. title .. ']~s~ ' .. message)
        return true
    end

    if QBCore and QBCore.Functions and QBCore.Functions.Notify then
        QBCore.Functions.Notify('[' .. title .. '] ' .. message, notificationType)
        return true
    end

    TriggerEvent('chat:addMessage', {
        color     = { 255, 255, 255 },
        multiline = true,
        args      = { "^3[" .. title .. "]^7", message }
    })
    return false
end

-- =============================================================================
-- INTEGRATION SETTINGS
-- =============================================================================

Config.Integration = {
    framework = "auto",
    requiredResources  = { "ox_lib", "xsound" },
    optionalResources  = { "screenshot-basic", "dpemotes", "pma-voice" },
    database = {
        enabled = false,
        type    = "mysql",
        table   = "user_accessibility_settings"
    }
}

-- =============================================================================
-- KEYBIND CONFIGURATION
-- =============================================================================

Config.Keybinds = {
    enabled = true,
    default = {
        toggleMenu          = "F9",
        quickToggleWeather  = "F11",
        quickToggleLighting = "F12",
    },
    allowCustomization = true
}

-- =============================================================================
-- VALIDATION AND HELPERS
-- =============================================================================

function Config.Validate()
    local errors = {}

    if not Config.Toggles or type(Config.Toggles) ~= "table" then
        table.insert(errors, "Config.Toggles is missing or invalid")
    end

    if not Config.Notify or type(Config.Notify) ~= "function" then
        table.insert(errors, "Config.Notify is missing or not a function")
    end

    for key, toggle in pairs(Config.Toggles or {}) do
        if not toggle.label or type(toggle.label) ~= "string" then
            table.insert(errors, "Toggle '" .. key .. "' missing or invalid label")
        end
        if toggle.default ~= nil and type(toggle.default) ~= "boolean" then
            table.insert(errors, "Toggle '" .. key .. "' default value must be boolean")
        end
    end

    if Config.TextToSpeech then
        if Config.TextToSpeech.maxDistance and Config.TextToSpeech.maxDistance <= 0 then
            table.insert(errors, "TextToSpeech.maxDistance must be greater than 0")
        end
        if Config.TextToSpeech.volume and (Config.TextToSpeech.volume < 0 or Config.TextToSpeech.volume > 1) then
            table.insert(errors, "TextToSpeech.volume must be between 0 and 1")
        end
    end

    return errors
end

function Config.GetTogglesByCategory(category)
    local result = {}
    for key, toggle in pairs(Config.Toggles) do
        if toggle.category == category then
            result[key] = toggle
        end
    end
    return result
end

function Config.GetCategories()
    local categories = {}
    for _, toggle in pairs(Config.Toggles) do
        if toggle.category and not categories[toggle.category] then
            categories[toggle.category] = true
        end
    end
    return categories
end

-- =============================================================================
-- INITIALIZATION
-- =============================================================================

local validationErrors = Config.Validate()
if #validationErrors > 0 then
    print("^1[Accessibility] Configuration validation errors:^7")
    for _, err in ipairs(validationErrors) do
        print("^1  - " .. err .. "^7")
    end
else
    print("^2[Accessibility] Configuration loaded successfully^7")
end

return Config