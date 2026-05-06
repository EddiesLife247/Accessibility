-- =============================================================================
-- EVENT HANDLERS (CLIENT FOLDER VERSION)
-- =============================================================================

-- =============================================================================
-- MAIN EVENT HANDLERS
-- =============================================================================

-- Receive preference from server
RegisterNetEvent('Accessibility:ReceivePreference', function(key, state)
    -- Safety check
    if not AccessibilityManager then
        print("^1[Accessibility] ERROR: AccessibilityManager not available in events.lua^7")
        return
    end

    local oldState = AccessibilityManager:GetState(key)
    AccessibilityManager:SetState(key, state)

    -- Update visual filters
    if AccessibilityManager.timecycleFilters[key] then
        AccessibilityManager:UpdateTimecycle()
    end

    -- Handle WEATHER preference
    if key == 'weather' then
        if state then
            -- ON = static weather
            print("^3[Accessibility] Event: Weather ON -> static weather^7")
            AccessibilityManager:StartWeatherThread()
        else
            -- OFF = server weather
            print("^2[Accessibility] Event: Weather OFF -> server weather^7")
            AccessibilityManager:StopWeatherThread()
        end
    end
end)

-- Resource start event
AddEventHandler('onClientResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Safety check and initialization
    if not AccessibilityManager then
        print("^1[Accessibility] CRITICAL ERROR: AccessibilityManager not found on resource start^7")
        return
    end

    -- Initialize the accessibility manager
    AccessibilityManager:Initialize()
    
    -- Request all preferences from server
    TriggerServerEvent('Accessibility:RequestAllPreferences')
    
    -- Print startup information
    print("^2[Accessibility] Resource started successfully!^7")
    print("^3Available commands:^7")
    print("^3  /accessibility - Open toggle menu (or specify option)^7")
    print("^3  /eoa - Ease of Access toggle menu^7")
    print("^3  /access - Alternative toggle menu command^7")
    print("^3  /a11y - Accessibility toggle menu (short)^7")
    print("^3  /tts [message] - Text-to-speech for nearby players^7")
    print("^3  /speak [message] - Same as /tts^7")
    print("^3  /say [message] - Same as /tts^7")
    print("^3  /ttshelp - Show TTS help and examples^7")
end)

-- Player spawned event
AddEventHandler('playerSpawned', function()
    -- Wait a moment for everything to load
    Wait(1500)
    
    -- Safety check
    if not AccessibilityManager then
        print("^1[Accessibility] ERROR: AccessibilityManager not available on spawn^7")
        return
    end
    
    -- Reapply current settings
    AccessibilityManager:UpdateTimecycle()
    
    -- Apply weather setting on spawn
    if AccessibilityManager:GetState('weather') then
        -- ON = static weather
        print("^3[Accessibility] Spawn: Weather ON -> static weather^7")
        AccessibilityManager:StartWeatherThread()
    else
        -- OFF = server weather
        print("^2[Accessibility] Spawn: Weather OFF -> server weather^7")
        AccessibilityManager:StopWeatherThread()
    end
    
    print("^2[Accessibility] Settings reapplied after spawn^7")
end)

-- Resource stop event
AddEventHandler('onClientResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    -- Safety check
    if AccessibilityManager then
        -- Stop weather thread
        AccessibilityManager:StopWeatherThread()
        -- Clear timecycle filters
        ClearTimecycleModifier()
    end
    
    print("^3[Accessibility] Resource stopped, cleanup completed^7")
end)

-- Debug command to check weather state
RegisterCommand('debugweather', function()
    if not AccessibilityManager then
        print("^1[Accessibility] ERROR: AccessibilityManager not available^7")
        return
    end
    
    print("^3=== WEATHER DEBUG INFO ===^7")
    print("^3Weather Setting State: ^7" .. tostring(AccessibilityManager:GetState('weather')))
    print("^3Weather Thread Active: ^7" .. tostring(AccessibilityManager.weatherThreadActive))
    print("^3Static Weather Config: ^7" .. tostring(Config.StaticWeather or 'CLEAR'))
    print("^3Thread Update Interval: ^7" .. tostring(Config.WeatherThread.updateInterval or 1000) .. "ms")
    
    -- Get current weather
    local currentWeather = GetPrevWeatherTypeHashName()
    local nextWeather = GetNextWeatherTypeHashName()
    print("^3Current Weather: ^7" .. tostring(currentWeather))
    print("^3Next Weather: ^7" .. tostring(nextWeather))
    print("^3==========================^7")
end, false)

-- Manual command to force stop weather thread
RegisterCommand('stopweatherthread', function()
    if not AccessibilityManager then
        print("^1[Accessibility] ERROR: AccessibilityManager not available^7")
        return
    end
    
    print("^3[Accessibility] Manually stopping weather thread^7")
    AccessibilityManager:SetState('weather', false)
    AccessibilityManager:StopWeatherThread()
    
    -- Force clear weather overrides
    Citizen.CreateThread(function()
        for i = 1, 5 do
            if enableServerWeather then
                enableServerWeather()
            end
            Wait(1000)
        end
        print("^2[Accessibility] Manual weather stop completed^7")
    end)
end, false)

-- Manual command to clear all weather overrides
RegisterCommand('clearweatheroverrides', function()
    print("^3[Accessibility] Manually clearing all weather overrides^7")
    
    pcall(function()
        ClearWeatherTypePersist()
        ClearOverrideWeather()
        print("^2[Accessibility] Native weather overrides cleared^7")
    end)
    
    if enableServerWeather then
        enableServerWeather()
    end
end, false)

print("^2[Accessibility] Event handlers loaded^7")