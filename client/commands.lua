-- =============================================================================
-- COMMAND REGISTRATION (CLIENT FOLDER VERSION)
-- =============================================================================

-- Main accessibility command
RegisterCommand('accessibility', function(source, args, rawCommand)
    if #args == 0 then
        -- Open menu if no arguments provided
        if lib then
            openAccessibilityToggleMenu()
        else
            openSimpleNotificationMenu()
        end
        return
    end
    
    -- Toggle specific option
    local section = string.lower(args[1])
    if not Config.Toggles[section] then
        Config.Notify('Invalid Option', 'Usage: /accessibility [option] or just /accessibility for menu', 'error')
        openSimpleNotificationMenu()
        return
    end
    
    toggleAccessibilityOption(section)
end, false)

-- Command aliases
local aliases = {'eoa', 'access', 'a11y', 'accmenu'}
for _, alias in ipairs(aliases) do
    RegisterCommand(alias, function()
        if lib then
            openAccessibilityToggleMenu()
        else
            openSimpleNotificationMenu()
        end
    end, false)
end

print("^2[Accessibility] Commands registered^7")