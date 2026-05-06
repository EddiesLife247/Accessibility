-- =============================================================================
-- FIVEM ACCESSIBILITY SYSTEM - CORE MODULE (CLIENT FOLDER VERSION)
-- =============================================================================
-- This file MUST be loaded FIRST to define AccessibilityManager globally
-- All other client modules depend on this being loaded first
-- =============================================================================

-- =============================================================================
-- GLOBAL STATE MANAGEMENT
-- =============================================================================
AccessibilityManager = {
    states = {},
    timecycleFilters = {
        dim = "glasses_black",
        blackwhite = "bawe_main", 
        highcontrast = "MP_race_crash",
        brown = "glasses_brown",
        blue = "glasses_blue",
        green = "glasses_green",
        orange = "glasses_orange",
        protanopia = "NG_filmic01",
        deuteranopia = "spectator7",
        tritanopia = "spectator6",
    },
    isInitialized = false,
    weatherThreadActive = false
}

-- Initialize states with default values
function AccessibilityManager:Initialize()
    if self.isInitialized then return end
    
    for key, data in pairs(Config.Toggles) do
        self.states[key] = data.default or false
    end
    
    self.isInitialized = true
    print("^2[Accessibility] Manager initialized successfully^7")
end

-- Get current state of an option
function AccessibilityManager:GetState(key)
    return self.states[key] or false
end

-- Set state for an option
function AccessibilityManager:SetState(key, value)
    if not Config.Toggles[key] then
        print("^1[Accessibility] Warning: Unknown option '" .. tostring(key) .. "'^7")
        return false
    end
    
    self.states[key] = value
    return true
end

-- Get all states
function AccessibilityManager:GetAllStates()
    return self.states
end

-- Update timecycle modifier based on current states
function AccessibilityManager:UpdateTimecycle()
    -- Clear any existing modifier first
    ClearTimecycleModifier()
    
    -- Apply the first active filter (priority based on order)
    local filterOrder = {
        'blackwhite', 'highcontrast', 'dim', 'brown', 'blue', 
        'green', 'orange', 'protanopia', 'deuteranopia', 'tritanopia'
    }
    
    for _, filterKey in ipairs(filterOrder) do
        if self.states[filterKey] and self.timecycleFilters[filterKey] then
            SetTimecycleModifier(self.timecycleFilters[filterKey])
            SetTimecycleModifierStrength(1.0)
            return filterKey -- Return which filter was applied
        end
    end
    
    return nil -- No filter applied
end

-- =============================================================================
-- WEATHER THREAD METHODS (defined here for global access)
-- =============================================================================

-- Start weather thread method
function AccessibilityManager:StartWeatherThread()
    if self.weatherThreadActive then 
        print("^3[Accessibility] Weather thread already active, skipping start^7")
        return 
    end
    
    -- Double check that weather is actually enabled
    if not self:GetState('weather') then
        print("^3[Accessibility] Weather state is OFF, not starting thread^7")
        return
    end
    
    self.weatherThreadActive = true

    local STATIC_WEATHER = Config.StaticWeather or 'CLEAR'
    print("^2[Accessibility] Starting static weather lock (" .. STATIC_WEATHER .. ")^7")

    Citizen.CreateThread(function()
        while self.weatherThreadActive and self:GetState('weather') do
            -- Force static weather (defined in weather.lua but called from here)
            if enforceStaticWeatherOnce then
                enforceStaticWeatherOnce()
            end

            Wait(Config.WeatherThread.updateInterval or 1000)
        end

        -- Clean shutdown
        self.weatherThreadActive = false
        print("^3[Accessibility] Weather thread stopped^7")
        
        -- Re-enable server weather (defined in weather.lua but called from here)
        if enableServerWeather then
            enableServerWeather()
        end
    end)
end

-- Stop weather thread method
function AccessibilityManager:StopWeatherThread()
    if not self.weatherThreadActive then return end
    self.weatherThreadActive = false

    print("^3[Accessibility] Stopping static weather lock, returning control to server^7")
end

-- =============================================================================
-- CORE TOGGLE FUNCTIONALITY
-- =============================================================================

-- Toggle an accessibility option (GLOBAL FUNCTION)
function toggleAccessibilityOption(section)
    if not Config.Toggles[section] then 
        Config.Notify("Error", "Unknown accessibility option: " .. tostring(section), "error")
        return false
    end
    
    local currentState = AccessibilityManager:GetState(section)
    local newState = not currentState
    
    -- Update local state
    AccessibilityManager:SetState(section, newState)
    
    -- Sync with server
    TriggerServerEvent('Accessibility:UpdatePreference', section, newState)
    
    -- Handle timecycle filters (only one can be active at a time)
    if AccessibilityManager.timecycleFilters[section] then
        if newState then
            -- Disable other timecycle filters when enabling this one
            for filterKey, _ in pairs(AccessibilityManager.timecycleFilters) do
                if filterKey ~= section and AccessibilityManager:GetState(filterKey) then
                    AccessibilityManager:SetState(filterKey, false)
                    TriggerServerEvent('Accessibility:UpdatePreference', filterKey, false)
                end
            end
        end
        AccessibilityManager:UpdateTimecycle()
    end
    
    -- Handle weather toggle
    if section == 'weather' then
        if newState then
            -- ON = static weather
            print("^3[Accessibility] Weather ON -> static weather^7")
            AccessibilityManager:StartWeatherThread()
        else
            -- OFF = server weather
            print("^2[Accessibility] Weather OFF -> server weather^7")
            AccessibilityManager:StopWeatherThread()
        end
    end
    
    -- Show notification
    local stateText = newState and "enabled" or "disabled"
    local notificationType = newState and "success" or "inform"
    Config.Notify(Config.Toggles[section].label, "Has been " .. stateText, notificationType)
    
    return true
end

print("^2[Accessibility] Core module loaded - AccessibilityManager is now global^7")