-- client.lua (Final Version - Compatible with Older ox_lib)

local accessibilityStates = {}

local timecycleToggles = {
    dim = true,
    blackwhite = true,
    highcontrast = true,
    protanopia = true,
    deuteranopia = true,
    tritanopia = true,
    brown = true,
    blue = true,
    green = true,
    orange = true,
}

-- =============================================================================
-- EXPORT
-- =============================================================================
function GetLighting()
    return accessibilityStates and accessibilityStates['lighting']
end
exports("GetLighting", GetLighting)

-- =============================================================================
-- THE MAIN ENGINE & THREAD
-- =============================================================================
local function updateTimecycle()
    if accessibilityStates['blackwhite'] then
        SetTimecycleModifier("bawe_main")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['highcontrast'] then
        SetTimecycleModifier("MP_race_crash")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['dim'] then
        SetTimecycleModifier("glasses_black")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['brown'] then
        SetTimecycleModifier("glasses_brown")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['blue'] then
        SetTimecycleModifier("glasses_blue")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['green'] then
        SetTimecycleModifier("glasses_green")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['orange'] then
        SetTimecycleModifier("glasses_orange")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['protanopia'] then
        SetTimecycleModifier("NG_filmic01")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['deuteranopia'] then
        SetTimecycleModifier("spectator7")
        SetTimecycleModifierStrength(1.0)
    elseif accessibilityStates['tritanopia'] then
        SetTimecycleModifier("spectator6")
        SetTimecycleModifierStrength(1.0)
    else
        ClearTimecycleModifier()
    end
end

-- =============================================================================
-- REFACTORED STATE MANAGEMENT
-- =============================================================================
function toggleAccessibilityOption(section)
    if not Config.Toggles[section] then return end
    local newState = not accessibilityStates[section]
    accessibilityStates[section] = newState
    TriggerServerEvent('Accessibility:UpdatePreference', section, newState)
    if timecycleToggles[section] and newState == true then
        for toggleKey, _ in pairs(timecycleToggles) do
            if toggleKey ~= section and accessibilityStates[toggleKey] then
                accessibilityStates[toggleKey] = false
                TriggerServerEvent('Accessibility:UpdatePreference', toggleKey, false)
            end
        end
    end
    if timecycleToggles[section] then
        updateTimecycle()
    end
    if section == 'weather' then
        if newState == true then
            SetWeatherTypeNowPersist('CLOUDY')
        else
            ClearWeatherTypePersist()
        end
    end
    local stateText = newState and "enabled" or "disabled"
    Config.Notify(Config.Toggles[section].label, "Has been " .. stateText, newState and "success" or "error")
end

-- =============================================================================
-- ACCESSIBILITY MENU (GUARANTEED TO WORK)
-- =============================================================================
local function openAccessibilityMenu()
    if not lib then
        print("^1[Accessibility] ERROR: ox_lib is not available.")
        return
    end
    local elements = {}
    if Config and Config.Toggles then
        for key, data in pairs(Config.Toggles) do
            local statusIcon = accessibilityStates[key] and '?' or '?'
            table.insert(elements, {
                title = statusIcon .. ' ' .. data.label,
                description = data.description or "Toggle this accessibility option.",
                -- This onSelect function is the fix. It no longer tries to refresh the menu.
                onSelect = function()
                    toggleAccessibilityOption(key)
                end
            })
        end
    end
    if #elements == 0 then
        print("^1[Accessibility] ERROR: No toggle options found in Config.Toggles.")
        Config.Notify('Menu Error', 'No accessibility options are configured.', 'error')
        return
    end
    lib.showMenu({
        id = 'accessibility_menu',
        title = '? Accessibility Options',
        elements = elements,
        position = 'top-right'
    })
end
RegisterCommand('accmenu', openAccessibilityMenu, false)

-- =============================================================================
-- ORIGINAL COMMAND
-- =============================================================================
RegisterCommand('accessibility', function(source, args, rawCommand)
    local section = args[1]
    if not section or not Config.Toggles[section] then
        local suggestions = {}
        for key, data in pairs(Config.Toggles) do table.insert(suggestions, { name = key, help = data.label }) end
        TriggerEvent('chat:addSuggestions', suggestions)
        Config.Notify('Invalid Option', 'Usage: /accessibility [option]', 'error')
        return
    end
    toggleAccessibilityOption(section)
end, false)

-- =============================================================================
-- LIVE FILTER TESTING TOOL
-- =============================================================================
RegisterCommand('testfilter', function(source, args, raw)
    local filterName = args[1]
    if not filterName then
        TriggerEvent('chat:addMessage', { args = { 'Usage', '/testfilter [filtername]  or  /testfilter off' } })
        return
    end
    if filterName == 'off' or filterName == 'clear' then
        ClearTimecycleModifier()
        TriggerEvent('chat:addMessage', { args = { 'Filter', 'Cleared.' } })
    else
        ClearTimecycleModifier()
        SetTimecycleModifier(filterName)
        SetTimecycleModifierStrength(1.0)
        TriggerEvent('chat:addMessage', { args = { 'Filter', 'Applied: ' .. filterName } })
    end
end, false)

-- =============================================================================
-- STARTUP AND DATA SYNC
-- =============================================================================
RegisterNetEvent('Accessibility:ReceivePreference', function(key, state)
    accessibilityStates[key] = state
    if timecycleToggles[key] then
        updateTimecycle()
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for key, data in pairs(Config.Toggles) do
            accessibilityStates[key] = data.default
        end
        TriggerServerEvent('Accessibility:RequestAllPreferences')
    end
end)

AddEventHandler('playerSpawned', function()
    Wait(1500)
    updateTimecycle()
    if accessibilityStates['weather'] == false then
        ClearWeatherTypePersist()
    end
end)