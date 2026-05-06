-- =============================================================================
-- TEXT-TO-SPEECH FUNCTIONALITY (CLIENT FOLDER VERSION)
-- =============================================================================

-- Get nearby players within specified radius
local function getNearbyPlayers(radius)
    local nearbyPlayers = {}
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local playersList = GetActivePlayers()
    
    for _, playerId in pairs(playersList) do
        if NetworkIsPlayerConnected(playerId) then
            local playerPed = GetPlayerPed(playerId)
            local playerCoords = GetEntityCoords(playerPed)
            local distance = #(coords - playerCoords)
            
            if distance <= radius then
                table.insert(nearbyPlayers, GetPlayerServerId(playerId))
            end
        end
    end
    
    return nearbyPlayers
end

-- Function to handle text-to-speech
function handleTextToSpeech(text)
    print("^2[accessibility] Processing TTS text: " .. tostring(text))
    
    local success, error = pcall(function()
        local nearbyPlayers = getNearbyPlayers(Config.distance or 5.0)
        local playerCoords = GetEntityCoords(PlayerPedId())
        
        print("^2[accessibility] Found " .. #nearbyPlayers .. " nearby players^7")
        print("^2[accessibility] Sending TTS to server^7")
        
        TriggerServerEvent("Accessibility:playsound", nearbyPlayers, playerCoords, text)
    end)
    
    if success then
        print("^2[accessibility] TTS request processed successfully^7")
    else
        print("^1[accessibility] Error processing TTS request: " .. tostring(error) .. "^7")
    end
end

-- Main TTS command (simple and reliable)
RegisterCommand('tts', function(source, args, rawCommand)
    local text = table.concat(args, " ", 1) 
    if not text or text == "" then
        Config.Notify("TTS Usage", "Use: /tts [your message] to speak text aloud to nearby players", "info")
        return
    end
    
    -- Use config for max length validation
    local maxLength = Config.TextToSpeech and Config.TextToSpeech.maxTextLength or 200
    if #text > maxLength then
        Config.Notify("TTS Error", "Message too long. Maximum " .. maxLength .. " characters.", "error")
        return
    end
    
    print("^2[accessibility] TTS Command: " .. text .. "^7")
    handleTextToSpeech(text)
    
    Config.Notify("TTS", "Speaking: " .. text, "success")
end, false)

-- Alternative commands for TTS
RegisterCommand('speak', function(source, args, rawCommand)
    ExecuteCommand('tts ' .. table.concat(args, " "))
end, false)

RegisterCommand('say', function(source, args, rawCommand)
    ExecuteCommand('tts ' .. table.concat(args, " "))
end, false)

-- Help command for TTS
RegisterCommand('ttshelp', function()
    print("^3=== TEXT-TO-SPEECH HELP ===^7")
    print("^3Commands:^7")
    print("  ^2/tts [message]^7 - Speak text to nearby players")
    print("  ^2/speak [message]^7 - Same as /tts")
    print("  ^2/say [message]^7 - Same as /tts")
    print("^3Examples:^7")
    print("  ^2/tts Hello everyone!^7")
    print("  ^2/speak I need help here^7")
    print("^3Notes:^7")
    print("  - Maximum 200 characters")
    print("  - Only nearby players will hear it")
    print("  - Requires xsound resource")
    print("^3============================^7")
end, false)

print("^2[Accessibility] TTS functions loaded^7")