-- =============================================================================
-- WEATHER FUNCTIONALITY (CLIENT FOLDER VERSION)
-- =============================================================================

local STATIC_WEATHER = Config.StaticWeather or 'CLEAR'

-- Enable server-controlled weather again (GLOBAL FUNCTION)
function enableServerWeather()
    print("^2[Accessibility] Clearing all weather overrides and restoring server control^7")
    
    pcall(function()
        -- Clear native weather overrides first
        ClearWeatherTypePersist()
        ClearOverrideWeather()
        
        -- Try to re-enable weather sync systems
        if GetResourceState('b2_weatheressentials') == 'started' then
            exports['b2_weatheressentials']:EnableWeatherSync()
            exports['b2_weatheressentials']:EnableTimeSync()
            print("^2[Accessibility] Re-enabled b2_weatheressentials sync^7")
        elseif GetResourceState('qb-weathersync') == 'started' then
            exports['qb-weathersync']:EnableWeatherSync()
            print("^2[Accessibility] Re-enabled qb-weathersync^7")
        elseif GetResourceState('cd_easytime') == 'started' then
            exports['cd_easytime']:PauseSync(false)
            print("^2[Accessibility] Re-enabled cd_easytime sync^7")
        else
            print("^3[Accessibility] No weather sync resource detected, weather control returned to server^7")
        end
    end)
    
    print("^2[Accessibility] Dynamic weather restored (server now in control)^7")
end

-- Force static weather locally (GLOBAL FUNCTION)
function enforceStaticWeatherOnce()
    pcall(function()
        if GetResourceState('b2_weatheressentials') == 'started' then
            exports['b2_weatheressentials']:DisableWeatherSync()
            exports['b2_weatheressentials']:DisableTimeSync()
            exports['b2_weatheressentials']:SetWeather(STATIC_WEATHER)
        else
            SetWeatherTypeNowPersist(STATIC_WEATHER)
            SetWeatherTypeNow(STATIC_WEATHER)
            SetWeatherTypePersist(STATIC_WEATHER)
            SetOverrideWeather(STATIC_WEATHER)
        end
    end)
end

print("^2[Accessibility] Weather functions loaded^7")