-- =============================================================================
-- FIVEM ACCESSIBILITY SYSTEM - SERVER SIDE (IMPROVED)
-- =============================================================================
-- Enhanced server-side script with better error handling, caching, and logging
-- =============================================================================

-- =============================================================================
-- CONFIGURATION AND STATE MANAGEMENT
-- =============================================================================

local AccessibilityServer = {
    playerCache = {}, -- Cache player settings indexed by their license identifier
    isInitialized = false,
    debugMode = false -- Set to true for debug logging
}

-- Initialize the server module
function AccessibilityServer:Initialize()
    if self.isInitialized then return end
    
    self.isInitialized = true
    print("^2[Accessibility] Server module initialized^7")
end

-- Debug logging function
function AccessibilityServer:DebugLog(message)
    if self.debugMode then
        print("^3[Accessibility Debug] " .. message .. "^7")
    end
end

-- Get player identifier with error handling
function AccessibilityServer:GetPlayerIdentifier(source)
    local identifier = GetPlayerIdentifier(source, 0)
    if not identifier then
        print("^1[Accessibility] ERROR: Could not get identifier for player " .. tostring(source) .. "^7")
        return nil
    end
    return identifier
end

-- Validate accessibility key
function AccessibilityServer:ValidateKey(key)
    if not Config or not Config.Toggles then
        print("^1[Accessibility] ERROR: Config.Toggles not found^7")
        return false
    end
    
    if not Config.Toggles[key] then
        print("^1[Accessibility] WARNING: Unknown accessibility key '" .. tostring(key) .. "'^7")
        return false
    end
    
    return true
end

-- Get KVP key for a player setting
function AccessibilityServer:GetKVPKey(key, identifier)
    return "accessibility:" .. key .. ":" .. identifier
end

-- Save setting to KVP with error handling
function AccessibilityServer:SaveSetting(key, identifier, state)
    local kvpKey = self:GetKVPKey(key, identifier)
    local success, error = pcall(function()
        SetResourceKvp(kvpKey, tostring(state))
    end)
    
    if not success then
        print("^1[Accessibility] ERROR: Failed to save KVP setting - " .. tostring(error) .. "^7")
        return false
    end
    
    self:DebugLog("Saved setting for " .. identifier .. " -> " .. key .. " = " .. tostring(state))
    return true
end

-- Load setting from KVP with error handling
function AccessibilityServer:LoadSetting(key, identifier)
    local kvpKey = self:GetKVPKey(key, identifier)
    local success, storedValue = pcall(function()
        return GetResourceKvpString(kvpKey)
    end)
    
    if not success then
        print("^1[Accessibility] ERROR: Failed to load KVP setting - " .. tostring(storedValue) .. "^7")
        return nil
    end
    
    if storedValue == nil then
        return nil
    end
    
    -- Convert string to boolean
    local boolValue = (storedValue == 'true')
    self:DebugLog("Loaded setting for " .. identifier .. " -> " .. key .. " = " .. tostring(boolValue))
    return boolValue
end

-- Update player cache
function AccessibilityServer:UpdatePlayerCache(identifier, key, state)
    if not self.playerCache[identifier] then
        self.playerCache[identifier] = {}
    end
    
    self.playerCache[identifier][key] = state
    self:DebugLog("Updated cache for " .. identifier .. " -> " .. key .. " = " .. tostring(state))
end

-- Get player settings from cache
function AccessibilityServer:GetPlayerSettings(identifier)
    return self.playerCache[identifier] or {}
end

-- Clear player from cache
function AccessibilityServer:ClearPlayerCache(identifier)
    if self.playerCache[identifier] then
        self.playerCache[identifier] = nil
        self:DebugLog("Cleared cache for " .. identifier)
        return true
    end
    return false
end

-- =============================================================================
-- EXPORTS FOR OTHER RESOURCES
-- =============================================================================

-- Export function to get player settings
exports('GetPlayerSettings', function(identifier)
    return AccessibilityServer:GetPlayerSettings(identifier)
end)

-- Export function to get specific player setting
exports('GetPlayerSetting', function(identifier, key)
    local settings = AccessibilityServer:GetPlayerSettings(identifier)
    return settings[key]
end)

-- Export function to set player setting (for admin tools, etc.)
exports('SetPlayerSetting', function(source, key, state)
    if not AccessibilityServer:ValidateKey(key) then
        return false
    end
    
    local identifier = AccessibilityServer:GetPlayerIdentifier(source)
    if not identifier then
        return false
    end
    
    -- Save to KVP
    if not AccessibilityServer:SaveSetting(key, identifier, state) then
        return false
    end
    
    -- Update cache
    AccessibilityServer:UpdatePlayerCache(identifier, key, state)
    
    -- Notify client
    TriggerClientEvent('Accessibility:ReceivePreference', source, key, state)
    
    return true
end)

-- =============================================================================
-- EVENT HANDLERS
-- =============================================================================

-- Handle player updating their preference
RegisterNetEvent('Accessibility:UpdatePreference', function(key, state)
    local src = source
    
    -- Validate the key
    if not AccessibilityServer:ValidateKey(key) then
        return
    end
    
    -- Get player identifier
    local identifier = AccessibilityServer:GetPlayerIdentifier(src)
    if not identifier then
        return
    end
    
    -- Validate state (should be boolean)
    if type(state) ~= "boolean" then
        print("^1[Accessibility] ERROR: Invalid state type for key '" .. key .. "' - expected boolean, got " .. type(state) .. "^7")
        return
    end
    
    -- Save to KVP
    if not AccessibilityServer:SaveSetting(key, identifier, state) then
        return
    end
    
    -- Update cache
    AccessibilityServer:UpdatePlayerCache(identifier, key, state)
    
    AccessibilityServer:DebugLog("Player " .. GetPlayerName(src) .. " updated " .. key .. " to " .. tostring(state))
end)

-- Handle player requesting all their preferences
RegisterNetEvent('Accessibility:RequestAllPreferences', function()
    local src = source
    
    -- Get player identifier
    local identifier = AccessibilityServer:GetPlayerIdentifier(src)
    if not identifier then
        return
    end
    
    -- Initialize player cache
    AccessibilityServer.playerCache[identifier] = {}
    
    local settingsLoaded = 0
    local settingsTotal = 0
    
    -- Loop through all possible toggles from the config
    if Config and Config.Toggles then
        for key, data in pairs(Config.Toggles) do
            settingsTotal = settingsTotal + 1
            
            -- Load setting from KVP
            local storedValue = AccessibilityServer:LoadSetting(key, identifier)
            local finalState
            
            if storedValue == nil then
                -- If no value is saved, use the default from config
                finalState = data.default or false
            else
                finalState = storedValue
                settingsLoaded = settingsLoaded + 1
            end
            
            -- Update cache and send to client
            AccessibilityServer:UpdatePlayerCache(identifier, key, finalState)
            TriggerClientEvent('Accessibility:ReceivePreference', src, key, finalState)
        end
    else
        print("^1[Accessibility] ERROR: Config.Toggles not found when loading player preferences^7")
        return
    end
    
    local playerName = GetPlayerName(src)
    print(("^2[Accessibility] Loaded settings for %s (%s) - %d/%d from storage^7"):format(
        playerName, identifier, settingsLoaded, settingsTotal))
end)

-- =============================================================================
-- TEXT-TO-SPEECH FUNCTIONALITY
-- =============================================================================

-- Handle text-to-speech requests
RegisterServerEvent("Accessibility:playsound")
AddEventHandler("Accessibility:playsound", function(nearPlayers, pos, text)
    local source = source
    print("^2[Accessibility] TTS request received from player " .. source .. "^7")
    print("^3[Accessibility] Text: '" .. tostring(text) .. "'^7")
    print("^3[Accessibility] Players nearby: " .. tostring(#nearPlayers or 0) .. "^7")
    
    -- Validate inputs
    if not nearPlayers or type(nearPlayers) ~= "table" then
        print("^1[Accessibility] ERROR: Invalid nearPlayers data - type: " .. type(nearPlayers) .. "^7")
        return
    end
    
    if not pos then
        print("^1[Accessibility] ERROR: Position data is nil^7")
        return
    end
    
    if not text or type(text) ~= "string" or #text == 0 then
        print("^1[Accessibility] ERROR: Invalid text data - type: " .. type(text) .. ", length: " .. tostring(#tostring(text)) .. "^7")
        return
    end
    
    -- Sanitize text (basic protection)
    local sanitizedText = string.gsub(text, "[<>\"']", "")
    if #sanitizedText > 500 then
        sanitizedText = string.sub(sanitizedText, 1, 500) .. "..."
    end
    
    print("^2[Accessibility] Sanitized text: '" .. sanitizedText .. "'^7")
    
    -- Check if xsound export exists
    if not exports.xsound then
        print("^1[Accessibility] ERROR: xsound resource not found^7")
        return
    end
    
    print("^2[Accessibility] xsound found, attempting to play TTS^7")
    
    -- Play text-to-speech for nearby players
    local playersNotified = 0
    for _, targetSource in pairs(nearPlayers) do
        if GetPlayerPing(targetSource) > 0 then -- Check if player is still connected
            local success, error = pcall(function()
                exports.xsound:TextToSpeechPos(
                    targetSource, 
                    "accessibility_tts", 
                    Config.lang or "en-US", 
                    sanitizedText, 
                    Config.volume or 0.2, 
                    pos, 
                    false
                )
            end)
            
            if success then
                playersNotified = playersNotified + 1
                print("^2[Accessibility] TTS sent to player " .. targetSource .. "^7")
            else
                print("^1[Accessibility] ERROR: Failed to play TTS for player " .. targetSource .. " - " .. tostring(error) .. "^7")
            end
        else
            print("^3[Accessibility] Skipping disconnected player " .. targetSource .. "^7")
        end
    end
    
    print("^2[Accessibility] TTS completed for " .. playersNotified .. " players^7")
end)

-- =============================================================================
-- PLAYER CONNECTION HANDLERS
-- =============================================================================

-- Handle player disconnection
AddEventHandler("playerDropped", function(reason)
    local src = source
    local identifier = AccessibilityServer:GetPlayerIdentifier(src)
    
    if identifier then
        local playerName = GetPlayerName(src) or "Unknown"
        AccessibilityServer:ClearPlayerCache(identifier)
        print(("^3[Accessibility] Player %s (%s) disconnected - cleared from cache^7"):format(playerName, identifier))
    end
end)

-- Handle resource start
AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    AccessibilityServer:Initialize()
    
    print("^2[Accessibility] Server-side loaded successfully^7")
    print("^3Available exports:^7")
    print("^3  GetPlayerSettings(identifier) - Get all settings for a player^7")
    print("^3  GetPlayerSetting(identifier, key) - Get specific setting for a player^7")
    print("^3  SetPlayerSetting(source, key, state) - Set setting for a player^7")

    if GetCurrentResourceName() == resourceName then
        print("^2[Accessibility]^0 Server-side script loaded, developed by EddiesLife247 Scripts. Support at: https://discord.eddieslife247.co.uk/")

        -- Check for updates asynchronously
        PerformHttpRequest("https://eddieslife247.co.uk/Accessibility/version.txt", function(statusCode, response, headers)
            if statusCode == 200 and response then
                local currentVersion = GetResourceMetadata(GetCurrentResourceName(), "version", 0)
                local remoteVersion = response:match("%S+") -- Extract the version string

                if remoteVersion and currentVersion ~= remoteVersion then
                    print("^3[Accessibility]^0 A New Update is available on the keymaster site! Version: " .. remoteVersion)
                else
                    print("^2[Accessibility]^0 You are using the latest version.")
                end
            else
                print("^1[Accessibility]^0 Failed to check for updates. Status Code: " .. tostring(statusCode))
            end
        end, "GET", "", {['Content-Type'] = 'text/plain'})
    end

end)

-- Handle resource stop
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    
    print("^3[Accessibility] Server-side stopped^7")
end)

-- =============================================================================
-- ADMIN COMMANDS (OPTIONAL)
-- =============================================================================

-- Admin command to view player settings (requires ace permission)
RegisterCommand('viewaccessibility', function(source, args, rawCommand)
    if source == 0 then -- Console
        if not args[1] then
            print("Usage: viewaccessibility <player_id>")
            return
        end
        
        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerPing(targetId) then
            print("Invalid player ID")
            return
        end
        
        local identifier = AccessibilityServer:GetPlayerIdentifier(targetId)
        if not identifier then
            print("Could not get player identifier")
            return
        end
        
        local settings = AccessibilityServer:GetPlayerSettings(identifier)
        print("=== Accessibility Settings for " .. GetPlayerName(targetId) .. " ===")
        for key, value in pairs(settings) do
            print(key .. ": " .. tostring(value))
        end
        print("=" .. string.rep("=", 40))
    end
end, true)

-- Admin command to reset player settings
RegisterCommand('resetaccessibility', function(source, args, rawCommand)
    if source == 0 then -- Console only
        if not args[1] then
            print("Usage: resetaccessibility <player_id>")
            return
        end
        
        local targetId = tonumber(args[1])
        if not targetId or not GetPlayerPing(targetId) then
            print("Invalid player ID")
            return
        end
        
        local identifier = AccessibilityServer:GetPlayerIdentifier(targetId)
        if not identifier then
            print("Could not get player identifier")
            return
        end
        
        -- Reset all settings to defaults
        if Config and Config.Toggles then
            for key, data in pairs(Config.Toggles) do
                local defaultState = data.default or false
                AccessibilityServer:SaveSetting(key, identifier, defaultState)
                AccessibilityServer:UpdatePlayerCache(identifier, key, defaultState)
                TriggerClientEvent('Accessibility:ReceivePreference', targetId, key, defaultState)
            end
            
            print("Reset accessibility settings for " .. GetPlayerName(targetId))
        else
            print("ERROR: Config.Toggles not found")
        end
    end
end, true)

-- =============================================================================
-- UTILITIES AND HELPERS
-- =============================================================================

-- Function to get online players count with accessibility settings
function GetAccessibilityStats()
    local stats = {
        totalPlayers = 0,
        playersWithSettings = 0,
        settingsBreakdown = {}
    }
    
    local players = GetPlayers()
    stats.totalPlayers = #players
    
    for _, playerId in pairs(players) do
        local identifier = AccessibilityServer:GetPlayerIdentifier(tonumber(playerId))
        if identifier and AccessibilityServer.playerCache[identifier] then
            stats.playersWithSettings = stats.playersWithSettings + 1
            
            for key, value in pairs(AccessibilityServer.playerCache[identifier]) do
                if not stats.settingsBreakdown[key] then
                    stats.settingsBreakdown[key] = { enabled = 0, disabled = 0 }
                end
                
                if value then
                    stats.settingsBreakdown[key].enabled = stats.settingsBreakdown[key].enabled + 1
                else
                    stats.settingsBreakdown[key].disabled = stats.settingsBreakdown[key].disabled + 1
                end
            end
        end
    end
    
    return stats
end

-- Export the stats function
exports('GetAccessibilityStats', GetAccessibilityStats)

-- Debug command to show server stats
RegisterCommand('accessibilitystats', function(source, args, rawCommand)
    if source == 0 then -- Console only
        local stats = GetAccessibilityStats()
        
        print("=== Accessibility Server Statistics ===")
        print("Total Players Online: " .. stats.totalPlayers)
        print("Players with Settings: " .. stats.playersWithSettings)
        print("")
        print("Settings Breakdown:")
        for key, data in pairs(stats.settingsBreakdown) do
            print("  " .. key .. ": " .. data.enabled .. " enabled, " .. data.disabled .. " disabled")
        end
        print("=" .. string.rep("=", 30))
    end
end, true)

print("^2[Accessibility] Server script loaded successfully^7")