-- =============================================================================
-- MENU SYSTEMS - CATEGORY-BASED NAVIGATION
-- =============================================================================

-- Category display configuration (order + labels + icons)
local categoryConfig = {
    { key = 'epilepsy',   label = '⚡ Epilepsy & Flash Protection',  icon = 'fa-solid fa-bolt'          },
    { key = 'visual',     label = '👁 Visual Comfort',               icon = 'fa-solid fa-eye'           },
    { key = 'filters',    label = '🎨 Colour Filters',               icon = 'fa-solid fa-palette'       },
    { key = 'colorblind', label = '🌈 Colour Blindness Assistance',  icon = 'fa-solid fa-circle-half-stroke' },
    { key = 'motor',      label = '🖐 Motor Accessibility',          icon = 'fa-solid fa-hand'          },
    { key = 'hearing',    label = '🔔 Hearing Impaired Aids',        icon = 'fa-solid fa-bell'          },
    { key = 'cognitive',  label = '🧠 Cognitive / HUD',             icon = 'fa-solid fa-brain'         },
}

-- Order within each category
local categoryOrder = {
    epilepsy   = { 'lighting', 'explosionFlash', 'muzzleFlash', 'screenShake', 'weather' },
    visual     = { 'motionBlur', 'chromaticAberration', 'cameraSway', 'headlightGlare' },
    filters    = { 'dim', 'blackwhite', 'highcontrast', 'brown', 'blue', 'green', 'orange' },
    colorblind = { 'protanopia', 'deuteranopia', 'tritanopia' },
    motor      = { 'sprintToggle' },
    hearing    = { 'visualAlerts' },
    cognitive  = { 'simplifiedHud' },
}

-- Build an ordered list for a given category
local function getOptionsForCategory(categoryKey)
    local options = {}
    local order   = categoryOrder[categoryKey] or {}

    -- Ordered items first
    for _, key in ipairs(order) do
        if Config.Toggles[key] then
            local data = Config.Toggles[key]
            table.insert(options, {
                key         = key,
                label       = data.label,
                description = data.description or "Toggle this accessibility option.",
                data        = data
            })
        end
    end

    -- Any extras not in the order list (future-proofing)
    for key, data in pairs(Config.Toggles) do
        if data.category == categoryKey then
            local found = false
            for _, o in ipairs(order) do
                if o == key then found = true; break end
            end
            if not found then
                table.insert(options, {
                    key         = key,
                    label       = data.label,
                    description = data.description or "Toggle this accessibility option.",
                    data        = data
                })
            end
        end
    end

    return options
end

-- =============================================================================
-- CATEGORY SUB-MENU
-- =============================================================================
function openCategoryMenu(categoryKey, categoryLabel)
    if not lib or not AccessibilityManager then return end

    local options      = getOptionsForCategory(categoryKey)
    local menuOptions  = {}

    for _, item in ipairs(options) do
        local key       = item.key
        local isEnabled = AccessibilityManager:GetState(key)
        local statusIcon = isEnabled and '✅' or '❌'
        local statusText = isEnabled and 'ON' or 'OFF'

        if key == 'weather' and isEnabled and AccessibilityManager.weatherThreadActive then
            statusText = 'ON (Active)'
        end

        table.insert(menuOptions, {
            title       = statusIcon .. '  ' .. item.label,
            description = 'Status: ' .. statusText .. '\n' .. item.description,
            icon        = 'fa-solid fa-toggle-' .. (isEnabled and 'on' or 'off'),
            iconColor   = isEnabled and '#00cc44' or '#ff4444',
            onSelect    = function()
                toggleAccessibilityOption(key)
                Wait(120)
                openCategoryMenu(categoryKey, categoryLabel)
            end
        })
    end

    if #menuOptions == 0 then
        Config.Notify('Category', 'No options in this category.', 'inform')
        return
    end

    local success, err = pcall(function()
        lib.registerContext({
            id      = 'accessibility_category_' .. categoryKey,
            title   = '♿ ' .. categoryLabel,
            menu    = 'accessibility_main_menu',
            options = menuOptions
        })
        lib.showContext('accessibility_category_' .. categoryKey)
    end)

    if not success then
        print("^1[Accessibility] Category menu error: " .. tostring(err) .. "^7")
    end
end

-- =============================================================================
-- MAIN MENU (category picker)
-- =============================================================================
function openAccessibilityToggleMenu()
    if not lib then
        print("^1[Accessibility] ERROR: ox_lib is not available.^7")
        Config.Notify('Library Error', 'ox_lib is required for this menu.', 'error')
        openSimpleNotificationMenu()
        return
    end

    if not AccessibilityManager then
        Config.Notify('Error', 'Accessibility system not ready.', 'error')
        return
    end

    local menuOptions = {}

    for _, cat in ipairs(categoryConfig) do
        local options    = getOptionsForCategory(cat.key)
        local total      = #options
        local activeCount = 0

        for _, opt in ipairs(options) do
            if AccessibilityManager:GetState(opt.key) then
                activeCount = activeCount + 1
            end
        end

        local statusStr = activeCount .. '/' .. total .. ' enabled'

        table.insert(menuOptions, {
            title       = cat.label,
            description = statusStr,
            icon        = cat.icon,
            iconColor   = activeCount > 0 and '#00cc44' or '#888888',
            onSelect    = function()
                openCategoryMenu(cat.key, cat.label)
            end
        })
    end

    -- Quick status footer
    table.insert(menuOptions, {
        title       = '📋 Current Status',
        description = 'View all active settings at a glance',
        icon        = 'fa-solid fa-list-check',
        onSelect    = function()
            openStatusMenu()
        end
    })

    local success, err = pcall(function()
        lib.registerContext({
            id      = 'accessibility_main_menu',
            title   = '♿ Accessibility Settings',
            options = menuOptions
        })
        lib.showContext('accessibility_main_menu')
    end)

    if not success then
        print("^1[Accessibility] Main menu error: " .. tostring(err) .. "^7")
        openSimpleNotificationMenu()
    end
end

-- =============================================================================
-- STATUS OVERVIEW MENU
-- =============================================================================
function openStatusMenu()
    if not lib or not AccessibilityManager then return end

    local menuOptions = {}

    for _, cat in ipairs(categoryConfig) do
        local options = getOptionsForCategory(cat.key)
        for _, opt in ipairs(options) do
            local isEnabled = AccessibilityManager:GetState(opt.key)
            if isEnabled then
                table.insert(menuOptions, {
                    title     = '✅  ' .. opt.label,
                    description = opt.data.description,
                    icon      = 'fa-solid fa-check',
                    iconColor = '#00cc44',
                    readOnly  = true
                })
            end
        end
    end

    if #menuOptions == 0 then
        table.insert(menuOptions, {
            title       = 'No features currently enabled',
            description = 'Go back and enable accessibility features as needed.',
            icon        = 'fa-solid fa-circle-info',
            readOnly    = true
        })
    end

    pcall(function()
        lib.registerContext({
            id      = 'accessibility_status_menu',
            title   = '♿ Active Accessibility Features',
            menu    = 'accessibility_main_menu',
            options = menuOptions
        })
        lib.showContext('accessibility_status_menu')
    end)
end

-- =============================================================================
-- FALLBACK CONSOLE MENU
-- =============================================================================
function openSimpleNotificationMenu()
    if not Config or not Config.Toggles then return end
    if not AccessibilityManager then return end

    print("^3=== ACCESSIBILITY OPTIONS ===^7")

    for _, cat in ipairs(categoryConfig) do
        print("^5" .. cat.label .. "^7")
        local options = getOptionsForCategory(cat.key)
        for _, opt in ipairs(options) do
            local status = AccessibilityManager:GetState(opt.key) and "^2ON^7" or "^1OFF^7"
            print("  ^3" .. opt.key .. "^7 - " .. opt.label .. " [" .. status .. "]")
        end
    end

    print("^3==============================^7")
    print("^3Use: ^7/accessibility [option] ^3to toggle^7")

    Config.Notify('Accessibility Menu', 'Options listed in console. Use /accessibility [option] to toggle.', 'inform')
end

print("^2[Accessibility] Menu system loaded (category-based)^7")