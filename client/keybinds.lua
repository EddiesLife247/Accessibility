-- =============================================================================
-- KEYBIND IMPLEMENTATION (CLIENT-SIDE)
-- =============================================================================

-- Register keybinds when resource starts
Citizen.CreateThread(function()
    if not Config.Keybinds.enabled then
        print("^3[Accessibility] Keybinds are disabled in config^7")
        return
    end
    
    -- Wait for game to be ready
    while not NetworkIsPlayerActive(PlayerId()) do
        Wait(100)
    end
    
    print("^2[Accessibility] Registering keybinds...^7")
    
    -- Register toggle menu keybind
    RegisterKeyMapping('accessibility_menu', 'Open Accessibility Menu', 'keyboard', Config.Keybinds.default.toggleMenu)
    
    -- Register quick toggle weather keybind
    RegisterKeyMapping('accessibility_quick_weather', 'Quick Toggle Static Weather', 'keyboard', Config.Keybinds.default.quickToggleWeather)
    
    -- Register quick toggle lighting keybind
    RegisterKeyMapping('accessibility_quick_lighting', 'Quick Toggle Emergency Lighting', 'keyboard', Config.Keybinds.default.quickToggleLighting)
    
    print("^2[Accessibility] Keybinds registered successfully^7")
end)

-- =============================================================================
-- KEYBIND COMMAND HANDLERS
-- =============================================================================

-- Toggle accessibility menu
RegisterCommand('accessibility_menu', function()
    if not AccessibilityManager then
        Config.Notify('Error', 'Accessibility system not ready.', 'error')
        return
    end
    
    print("^3[Accessibility] Opening menu via keybind^7")
    openAccessibilityToggleMenu()
end, false)

-- Quick toggle static weather
RegisterCommand('accessibility_quick_weather', function()
    if not AccessibilityManager then
        Config.Notify('Error', 'Accessibility system not ready.', 'error')
        return
    end
    
    local currentState = AccessibilityManager:GetState('weather')
    toggleAccessibilityOption('weather')
    local newState = AccessibilityManager:GetState('weather')
    
    local statusText = newState and "ENABLED" or "DISABLED"
    local threadStatus = ""
    if newState and AccessibilityManager.weatherThreadActive then
        threadStatus = " (Thread Active)"
    end
    
    Config.Notify('Quick Toggle', 'Static Weather ' .. statusText .. threadStatus, newState and 'success' or 'inform')
    print("^3[Accessibility] Quick toggle weather: " .. statusText .. threadStatus .. "^7")
end, false)

-- Quick toggle emergency lighting
RegisterCommand('accessibility_quick_lighting', function()
    if not AccessibilityManager then
        Config.Notify('Error', 'Accessibility system not ready.', 'error')
        return
    end
    
    local currentState = AccessibilityManager:GetState('lighting')
    toggleAccessibilityOption('lighting')
    local newState = AccessibilityManager:GetState('lighting')
    
    local statusText = newState and "ENABLED" or "DISABLED"
    
    Config.Notify('Quick Toggle', 'Emergency Lighting ' .. statusText, newState and 'success' or 'inform')
    print("^3[Accessibility] Quick toggle lighting: " .. statusText .. "^7")
end, false)

-- =============================================================================
-- KEYBIND HELP FUNCTION
-- =============================================================================

function showKeybindHelp()
    if not Config.Keybinds.enabled then
        Config.Notify('Keybinds', 'Keybinds are currently disabled', 'inform')
        return
    end
    
    print("^3=== ACCESSIBILITY KEYBINDS ===^7")
    print("^3" .. Config.Keybinds.default.toggleMenu .. "^7 - Open Accessibility Menu")
    print("^3" .. Config.Keybinds.default.quickToggleWeather .. "^7 - Quick Toggle Static Weather")
    print("^3" .. Config.Keybinds.default.quickToggleLighting .. "^7 - Quick Toggle Emergency Lighting")
    print("^3==============================^7")
    
    Config.Notify('Keybinds', 'Keybind help printed to console', 'inform')
end

-- Register help command
RegisterCommand('accessibility_keybinds', function()
    showKeybindHelp()
end, false)

print("^2[Accessibility] Keybind system loaded^7")
