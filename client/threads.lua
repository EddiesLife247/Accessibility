-- =============================================================================
-- FIVEM ACCESSIBILITY SYSTEM - THREADS / ACCESSIBILITY FEATURES
-- =============================================================================
-- Covers:
--   1. Emergency lighting suppression (visual only, audio preserved)
--   2. Explosion flash suppression
--   3. Muzzle flash reduction
--   4. Screen shake reduction
--   5. Motion blur disable
--   6. Chromatic aberration disable
--   7. Camera sway reduction
--   8. Headlight glare reduction
--   9. Sprint toggle mode
--  10. Visual sound alerts (hearing impaired)
--  11. Simplified HUD
-- =============================================================================

-- =============================================================================
-- 1. EMERGENCY LIGHTING SUPPRESSION
-- Suppresses visual extras on emergency vehicles client-side only.
-- Does NOT call SetVehicleSiren on other players' vehicles — that is a
-- network-synced native and causes periodic blipping as the server fights
-- the client state. Extras are suppressed client-side only.
-- Audio (sirens) deliberately preserved.
-- Only runs when the player has opted into suppression (lighting toggle = true).
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('lighting') then
            local system = Config.LightingSystem and Config.LightingSystem.system or "default"

            if system == "oels" then
                -- OELS manages its own suppression, nothing to do here
                Wait(1000)
            else
                local localPed = PlayerPedId()
                local localVeh = GetVehiclePedIsUsing(localPed)

                for _, vehicle in ipairs(GetGamePool('CVehicle')) do
                    if GetVehicleClass(vehicle) == 18 and vehicle ~= localVeh then
                        for extra = 1, 12 do
                            if DoesExtraExist(vehicle, extra) and IsVehicleExtraTurnedOn(vehicle, extra) then
                                SetVehicleExtra(vehicle, extra, true)
                            end
                        end
                    end
                end
                Wait(0)
            end
        else
            Wait(2000)
        end
    end
end)

-- =============================================================================
-- 2. EXPLOSION FLASH SUPPRESSION
-- Detects nearby damage events and briefly dims the screen to
-- suppress the blinding white flash from explosions.
-- =============================================================================
local explosionFlashActive = false

Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('explosionFlash') then
            local playerPed = PlayerPedId()

            if not explosionFlashActive then
                if HasEntityBeenDamagedByAnyObject(playerPed) or
                   HasEntityBeenDamagedByAnyVehicle(playerPed) then

                    explosionFlashActive = true

                    if not AccessibilityManager:UpdateTimecycle() then
                        SetTimecycleModifier("glasses_black")
                        SetTimecycleModifierStrength(0.6)
                    end

                    ClearEntityLastDamageEntity(playerPed)

                    Citizen.SetTimeout(400, function()
                        explosionFlashActive = false
                        AccessibilityManager:UpdateTimecycle()
                    end)
                end
            end

            Wait(50)
        else
            explosionFlashActive = false
            Wait(1000)
        end
    end
end)

-- =============================================================================
-- 3. MUZZLE FLASH REDUCTION
-- Dampens the HDR bloom that makes muzzle flash so intense/strobing.
-- Uses a timecycle modifier during active firing only.
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('muzzleFlash') then
            local playerPed = PlayerPedId()

            if IsPedShooting(playerPed) then
                SetTimecycleModifier("no_extra_hdr")
                SetTimecycleModifierStrength(0.8)
            else
                AccessibilityManager:UpdateTimecycle()
            end

            Wait(0)
        else
            if AccessibilityManager then
                AccessibilityManager:UpdateTimecycle()
            end
            Wait(500)
        end
    end
end)

-- =============================================================================
-- 4. SCREEN SHAKE REDUCTION
-- Clamps shake amplitude every frame while active.
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('screenShake') then
            if IsGameplayCamShaking() then
                SetGameplayCamShakeAmplitude(0.05)
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

-- =============================================================================
-- 5. MOTION BLUR DISABLE
-- 0x4CA3B078 = SET_USE_HIDOF — disables depth-of-field & motion blur pass.
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('motionBlur') then
            Citizen.InvokeNative(0x4CA3B078, false)
            Wait(1000)
        else
            Citizen.InvokeNative(0x4CA3B078, true)
            Wait(2000)
        end
    end
end)

-- =============================================================================
-- 6. CHROMATIC ABERRATION DISABLE
-- 0x12E4F3CB = SET_CHROMATIC_ABERRATION_ENABLED
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('chromaticAberration') then
            Citizen.InvokeNative(0x12E4F3CB, false)
            Wait(2000)
        else
            Citizen.InvokeNative(0x12E4F3CB, true)
            Wait(2000)
        end
    end
end)

-- =============================================================================
-- 7. CAMERA SWAY REDUCTION
-- Reduces on-foot head bob using gameplay cam shake clamping.
-- 0xDC51E4F4 = DISABLE_CAM_COLLISION_FOR_ENTITY
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('cameraSway') then
            if IsGameplayCamShaking() then
                SetGameplayCamShakeAmplitude(0.0)
            end
            Citizen.InvokeNative(0xDC51E4F4, PlayerPedId())
            Wait(500)
        else
            Wait(2000)
        end
    end
end)

-- =============================================================================
-- 8. HEADLIGHT GLARE REDUCTION
-- SetArtificialLightsState reduces intensity of dynamic lights including
-- vehicle headlights. true = reduced, false = normal.
-- =============================================================================
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('headlightGlare') then
            SetArtificialLightsState(true)
            Wait(2000)
        else
            SetArtificialLightsState(false)
            Wait(2000)
        end
    end
end)

-- =============================================================================
-- 9. SPRINT TOGGLE MODE
-- Press sprint once to sprint, press again to stop.
-- Uses SetControlNormal to simulate holding the sprint key.
-- =============================================================================
local sprintToggledOn = false
local SPRINT_KEY      = 21 -- INPUT_SPRINT (Left Shift)

Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('sprintToggle') then

            if IsControlJustPressed(0, SPRINT_KEY) then
                sprintToggledOn = not sprintToggledOn
            end

            if sprintToggledOn then
                SetControlNormal(0, SPRINT_KEY, 1.0)
            end

            Wait(0)
        else
            if sprintToggledOn then
                sprintToggledOn = false
            end
            Wait(500)
        end
    end
end)

-- =============================================================================
-- 10. VISUAL SOUND ALERTS (Hearing Impaired)
-- On-screen HUD indicators for sirens, gunshots, and explosions.
-- =============================================================================
local activeAlerts   = {}
local alertIdCounter = 0

local function drawAlert(alert)
    local x = 0.5
    local y = 0.85 - (alert.slot * 0.06)

    DrawRect(x, y, 0.25, 0.045, 0, 0, 0, 180)

    local r, g, b = table.unpack(alert.color)
    DrawRect(x - 0.115, y, 0.02, 0.045, r, g, b, 255)

    SetTextFont(4)
    SetTextScale(0.0, 0.32)
    SetTextColour(255, 255, 255, 255)
    SetTextEntry("STRING")
    AddTextComponentString(alert.message)
    DrawText(x - 0.10, y - 0.015)
end

local function addVisualAlert(message, color)
    for _, a in pairs(activeAlerts) do
        if a.message == message then return end
    end

    alertIdCounter = alertIdCounter + 1
    local id = alertIdCounter

    local slot = 0
    for _, a in pairs(activeAlerts) do
        if a.slot >= slot then slot = a.slot + 1 end
        if slot > 3 then slot = 3 end
    end

    local duration = Config.VisualAlerts and Config.VisualAlerts.alertDuration or 3000

    activeAlerts[id] = {
        message = message,
        color   = color,
        slot    = slot,
    }

    Citizen.SetTimeout(duration, function()
        activeAlerts[id] = nil
    end)
end

-- Render thread
Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('visualAlerts') and next(activeAlerts) then
            for _, alert in pairs(activeAlerts) do
                drawAlert(alert)
            end
        end
        Wait(0)
    end
end)

-- Detection thread
local lastSirenCheck     = 0
local lastGunshotCheck   = 0
local lastExplosionCheck = 0

Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('visualAlerts') then
            local now          = GetGameTimer()
            local playerPed    = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local cfg          = Config.VisualAlerts or {}
            local interval     = cfg.checkInterval or 500

            if now - lastSirenCheck > interval then
                lastSirenCheck = now
                for _, veh in ipairs(GetGamePool('CVehicle')) do
                    if IsVehicleSirenOn(veh) then
                        local dist = #(playerCoords - GetEntityCoords(veh))
                        if dist <= (cfg.sirenRadius or 50.0) then
                            addVisualAlert("🚨 Siren nearby (" .. math.floor(dist) .. "m)", {255, 80, 80})
                            break
                        end
                    end
                end
            end

            if now - lastGunshotCheck > interval then
                lastGunshotCheck = now
                for _, ped in ipairs(GetGamePool('CPed')) do
                    if ped ~= playerPed then
                        local dist = #(playerCoords - GetEntityCoords(ped))
                        if dist <= (cfg.gunshotRadius or 30.0) and IsPedShooting(ped) then
                            addVisualAlert("🔫 Gunfire nearby (" .. math.floor(dist) .. "m)", {255, 180, 0})
                            break
                        end
                    end
                end
                if not IsEntityDead(playerPed) and GetEntityHealth(playerPed) < 200 then
                    addVisualAlert("⚠️ Taking damage!", {255, 60, 0})
                end
            end

            if now - lastExplosionCheck > interval then
                lastExplosionCheck = now
                if HasEntityBeenDamagedByAnyObject(playerPed) or
                   HasEntityBeenDamagedByAnyVehicle(playerPed) then
                    addVisualAlert("💣 Explosion/Impact nearby!", {255, 60, 0})
                    ClearEntityLastDamageEntity(playerPed)
                end
            end

            Wait(0)
        else
            activeAlerts = {}
            Wait(1000)
        end
    end
end)

-- =============================================================================
-- 11. SIMPLIFIED HUD
-- Hides non-essential HUD components every frame.
-- Full component list: https://docs.fivem.net/natives/?_0x0CE29B5BABB87373
-- =============================================================================
local hiddenHudComponents = {
    1,  -- WANTED_STARS
    2,  -- WEAPON_ICON
    3,  -- CASH
    4,  -- MP_CASH
    6,  -- MP_MESSAGE
    8,  -- VEHICLE_NAME
    9,  -- AREA_NAME
    13, -- STREET_NAME
    20, -- SAVING_GAME
}

Citizen.CreateThread(function()
    while true do
        if AccessibilityManager and AccessibilityManager:GetState('simplifiedHud') then
            for _, component in ipairs(hiddenHudComponents) do
                HideHudComponentThisFrame(component)
            end
            Wait(0)
        else
            Wait(500)
        end
    end
end)

print("^2[Accessibility] Threads loaded successfully^7")