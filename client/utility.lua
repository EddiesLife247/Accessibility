-- =============================================================================
-- UTILITY FUNCTIONS (CLIENT FOLDER VERSION - FINAL FIX)
-- =============================================================================

-- =============================================================================
-- EXPORT FUNCTIONS (WITH SAFETY CHECKS)
-- =============================================================================

-- Get current lighting state (for OELS compatibility)
function GetLighting()
    return AccessibilityManager:GetState('lighting')
end

-- Alternative function name for OELS compatibility
function getAccessibilityLightingState()
    return GetLighting()
end

-- Get accessibility state for external scripts
function GetAccessibilityState(key)
    if not AccessibilityManager then 
        print("^1[Accessibility] Warning: AccessibilityManager not ready in GetAccessibilityState^7")
        return false 
    end
    return AccessibilityManager:GetState(key)
end

-- Set accessibility state for external scripts
function SetAccessibilityState(key, value)
    if not AccessibilityManager then 
        print("^1[Accessibility] Warning: AccessibilityManager not ready in SetAccessibilityState^7")
        return false 
    end
    
    if AccessibilityManager:SetState(key, value) then
        TriggerServerEvent('Accessibility:UpdatePreference', key, value)
        
        -- Handle weather thread if this is weather setting
        if key == 'weather' then
            if value then
                AccessibilityManager:StartWeatherThread()
            else
                AccessibilityManager:StopWeatherThread()
            end
        end
        
        return true
    end
    return false
end

-- Get all accessibility states (for other scripts)
function GetAccessibilityStates()
    if not AccessibilityManager then return {} end
    return AccessibilityManager:GetAllStates()
end

-- Check if weather control is active
function IsWeatherControlActive()
    if not AccessibilityManager then return false end
    return AccessibilityManager.weatherThreadActive
end

-- Manual weather control functions for external scripts
function ForceWeatherCloudy()
    if not AccessibilityManager then return false end
    AccessibilityManager:SetState('weather', true)
    AccessibilityManager:StartWeatherThread()
    return true
end

function ReleaseWeatherControl()
    if not AccessibilityManager then return false end
    AccessibilityManager:SetState('weather', false)
    AccessibilityManager:StopWeatherThread()
    return true
end

-- =============================================================================
-- REGISTER EXPORTS
-- =============================================================================
exports("GetLighting", GetLighting)
exports("getAccessibilityLightingState", getAccessibilityLightingState)
exports("GetAccessibilityState", GetAccessibilityState)
exports("SetAccessibilityState", SetAccessibilityState)
exports("GetAccessibilityStates", GetAccessibilityStates)
exports("IsWeatherControlActive", IsWeatherControlActive)
exports("ForceWeatherCloudy", ForceWeatherCloudy)
exports("ReleaseWeatherControl", ReleaseWeatherControl)

print("^2[Accessibility] Utility functions loaded^7")