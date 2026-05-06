--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
Coded by Lt.Caine
ELS Clicks by Faction
Additional Modification by TrevorBarns
---------------------------------------------------
FILE: cl_lvc.lua
PURPOSE: Core Functionality and User Input
---------------------------------------------------
]]

--[[
---------------------------------------------------
LUXART VEHICLE CONTROL V3 (FOR FIVEM)
---------------------------------------------------
Coded by Lt.Caine
ELS Clicks by Faction
Additional Modification by TrevorBarns
---------------------------------------------------
FILE: cl_lvc.lua
PURPOSE: Core Functionality and User Input
---------------------------------------------------
]]

-- =============================================================================
-- ACCESSIBILITY DEBUG LOGGING
-- Set accessibility_debug = true to enable verbose console logs.
-- Set to false for production — zero performance cost when off.
-- Toggle in-game with command: /lvc_accessdebug
-- =============================================================================
local accessibility_debug = false

local function ALog(msg)
    if accessibility_debug then
        print("^3[LVC:Accessibility]^7 " .. tostring(msg))
    end
end

-- =============================================================================
-- ACCESSIBILITY: LIGHTING STATE
-- Polls the Accessibility export every 500ms.
-- isEnvLightingEnabledForPlayer = true means the player has OPTED IN to
-- suppression. false = normal, no suppression.
-- accessibility_switch_on tracks Q (master switch) state independently of
-- IsVehicleSirenOn() so it stays stable between frames when suppression is on.
-- =============================================================================
local isEnvLightingEnabledForPlayer = exports["Accessibility"]:GetLighting()
local accessibility_switch_on = false

CreateThread(function()
    local last = isEnvLightingEnabledForPlayer
    while true do
        Wait(500)
        isEnvLightingEnabledForPlayer = exports["Accessibility"]:GetLighting()
        if isEnvLightingEnabledForPlayer ~= last then
            ALog("Lighting state changed -> " .. tostring(isEnvLightingEnabledForPlayer))
            -- If suppression just turned OFF, re-sync switch flag to actual vehicle state
            if not isEnvLightingEnabledForPlayer and veh ~= nil then
                accessibility_switch_on = IsVehicleSirenOn(veh)
            end
            last = isEnvLightingEnabledForPlayer
        end
    end
end)

-- =============================================================================
-- ACCESSIBILITY: SUPPRESS OTHER PLAYERS' FLASHING EXTRAS (CLIENT-SIDE ONLY)
-- Only runs when this player has opted into suppression (isEnvLightingEnabledForPlayer = true).
-- Does NOT call SetVehicleSiren on other players' vehicles — that is a
-- network-synced native and causes periodic blipping as the server fights
-- the client state. Extras are suppressed client-side only.
-- Audio (sirens) deliberately preserved.
-- =============================================================================
local lastOccupiedEmergVehLVC = nil

CreateThread(function()
    while true do
        if isEnvLightingEnabledForPlayer then
            local localPed = GetPlayerPed(-1)
            local localVeh = GetVehiclePedIsUsing(localPed)

            if localVeh ~= 0 and GetVehicleClass(localVeh) == 18 then
                lastOccupiedEmergVehLVC = localVeh
            end

            for _, vehEnt in ipairs(GetGamePool('CVehicle')) do
                if GetVehicleClass(vehEnt) == 18 and vehEnt ~= localVeh then
                    SetVehicleHasMutedSirens(vehEnt, true)
                end
            end

            if lastOccupiedEmergVehLVC ~= nil
            and lastOccupiedEmergVehLVC ~= localVeh
            and DoesEntityExist(lastOccupiedEmergVehLVC) then
                SetVehicleHasMutedSirens(lastOccupiedEmergVehLVC, true)
            end

            Wait(0)
        else
            lastOccupiedEmergVehLVC = nil
            Wait(500)
        end
    end
end)

-- =============================================================================
-- GLOBAL VARIABLES used in cl_ragemenu, UTILs, and plug-ins.
-- =============================================================================
key_lock = false
playerped = nil
last_veh = nil
veh = nil
trailer = nil
player_is_emerg_driver = false
debug_mode = false

tone_main_reset_standby     = reset_to_standby_default
tone_airhorn_intrp          = airhorn_interrupt_default
park_kill                   = park_kill_default

local radio_wheel_active = false
local count_bcast_timer = 0
local delay_bcast_timer = 300
local count_sndclean_timer = 0
local delay_sndclean_timer = 400
local actv_ind_timer = false
local count_ind_timer = 0
local delay_ind_timer = 180

actv_lxsrnmute_temp = false
local srntone_temp = 0
local dsrn_mute = true
local lights_on = false
local new_tone = nil
local tone_mem_id = nil
local tone_mem_option = nil
local default_tone = nil
local default_tone_option = nil

state_indic = {}
state_lxsiren = {}
state_pwrcall = {}
state_airmanu = {}

actv_manu = nil
actv_horn = nil

local update_data = {}

local ind_state_o = 0
local ind_state_l = 1
local ind_state_r = 2
local ind_state_h = 3

local snd_lxsiren = {}
local snd_pwrcall = {}
local snd_airmanu = {}

local RegisterKeyMaps, MakeOrdinal

-- =============================================================================
-- THREAD: EMERGENCY DRIVER DETECTION
-- =============================================================================
CreateThread(function()
    if GetResourceState('lux_vehcontrol') ~= 'started' and GetResourceState('lux_vehcontrol') ~= 'starting' then
        if GetCurrentResourceName() == 'lvc' then
            if community_id ~= nil and community_id ~= '' then
                while true do
                    playerped = GetPlayerPed(-1)
                    player_is_emerg_driver = false
                    if IsPedInAnyVehicle(playerped, false) then
                        veh = GetVehiclePedIsUsing(playerped)
                        _, trailer = GetVehicleTrailerVehicle(veh)
                        if GetPedInVehicleSeat(veh, -1) == playerped then
                            if GetVehicleClass(veh) == 18 then
                                player_is_emerg_driver = true
                                DisableControlAction(0, 80, true)
                                DisableControlAction(0, 86, true)
                                DisableControlAction(0, 172, true)
                            end
                        end
                    end
                    Wait(1)
                end
            else
                Wait(1000)
                HUD:ShowNotification(Lang:t('error.missing_community_id_frontend'), true)
                UTIL:Print(Lang:t('error.missing_community_id_console'), true)
            end
        else
            Wait(1000)
            HUD:ShowNotification(Lang:t('error.invalid_resource_name_frontend'), true)
            UTIL:Print(Lang:t('error.invalid_resource_name_console'), true)
        end
    else
        Wait(1000)
        HUD:ShowNotification(Lang:t('error.resource_conflict_frontend'), true)
        UTIL:Print(Lang:t('error.resource_conflict_console'), true)
    end
end)

-- =============================================================================
-- THREAD: STARTUP
-- =============================================================================
CreateThread(function()
    debug_mode = GetResourceMetadata(GetCurrentResourceName(), 'debug_mode', 0) == 'true'
    TriggerEvent('chat:addSuggestion', Lang:t('command.lock_command'), Lang:t('command.lock_desc'))
    SetNuiFocus(false)
    UTIL:FixOversizeKeys(SIREN_ASSIGNMENTS)
    RegisterKeyMaps()
    STORAGE:SetBackupTable()
end)

-- =============================================================================
-- THREAD: RADIO WHEEL / AUX CONTROLS
-- =============================================================================
CreateThread(function()
    while true do
        if player_is_emerg_driver then
            if IsControlPressed(0, 243) and AUDIO.radio_masterswitch then
                while IsControlPressed(0, 243) do
                    radio_wheel_active = true
                    SetControlNormal(0, 85, 1.0)
                    Wait(0)
                end
                Wait(100)
                radio_wheel_active = false
            else
                DisableControlAction(0, 85, true)
                SetVehicleRadioEnabled(veh, false)
            end
        end
        Wait(0)
    end
end)

-- =============================================================================
-- THREAD: VEHICLE EXIT DETECTION
-- =============================================================================
CreateThread(function()
    while true do
        if player_is_emerg_driver then
            while playerped ~= nil and veh ~= nil do
                if GetIsTaskActive(playerped, 2) and GetVehiclePedIsIn(ped, true) then
                    TriggerEvent('lvc:onVehicleExit')
                    Wait(1000)
                end
                Wait(0)
            end
        end
        Wait(1000)
    end
end)

-- =============================================================================
-- THREAD: VEHICLE CHANGE DETECTION
-- =============================================================================
CreateThread(function()
    while true do
        if player_is_emerg_driver and veh ~= nil then
            if last_veh == nil then
                TriggerEvent('lvc:onVehicleChange')
            else
                if last_veh ~= veh then
                    TriggerEvent('lvc:onVehicleChange')
                end
            end
        end
        Wait(1000)
    end
end)

-- =============================================================================
-- REGISTERED VEHICLE EVENTS
-- =============================================================================
RegisterNetEvent('lvc:onVehicleExit')
AddEventHandler('lvc:onVehicleExit', function()
    ALog("onVehicleExit — resetting accessibility_switch_on")

    if isEnvLightingEnabledForPlayer and veh ~= nil and DoesEntityExist(veh) then
        SetVehicleHasMutedSirens(veh, true)
        ALog("onVehicleExit — muted sirens kept on exited vehicle")
    end

    accessibility_switch_on = false

    if park_kill_masterswitch and park_kill then
        if not tone_main_reset_standby and state_lxsiren[veh] ~= 0 then
            UTIL:SetToneByID('MAIN_MEM', state_lxsiren[veh])
        end
        SetLxSirenStateForVeh(veh, 0)
        SetPowercallStateForVeh(veh, 0)
        SetAirManuStateForVeh(veh, 0)
        HUD:SetItemState('siren', false)
        HUD:SetItemState('horn', false)
        count_bcast_timer = delay_bcast_timer
    end
end)

RegisterNetEvent('lvc:onVehicleChange')
AddEventHandler('lvc:onVehicleChange', function()
    ALog("onVehicleChange — resetting accessibility_switch_on")
    accessibility_switch_on = false
    last_veh = veh
    UTIL:UpdateApprovedTones(veh)
    Wait(100)
    STORAGE:ResetSettings()
    UTIL:BuildToneOptions()
    STORAGE:LoadSettings()
    HUD:RefreshHudItemStates()
    SetVehRadioStation(veh, 'OFF')
    Wait(500)
    SetVehRadioStation(veh, 'OFF')
end)

-- =============================================================================
-- REGISTERED COMMANDS
-- =============================================================================
RegisterCommand(Lang:t('command.debug_command'), function(source, args)
    debug_mode = not debug_mode
    HUD:ShowNotification(Lang:t('info.debug_mode_frontend', {state = debug_mode}), true)
    UTIL:Print(Lang:t('info.debug_mode_console', {state = debug_mode}), true)
    if debug_mode then
        TriggerEvent('lvc:onVehicleChange')
    end
end)

-- Toggle accessibility debug logging in-game
RegisterCommand('lvc_accessdebug', function(source, args)
    accessibility_debug = not accessibility_debug
    print("^3[LVC:Accessibility]^7 Debug logging -> " .. tostring(accessibility_debug))
end)

RegisterCommand(Lang:t('command.lock_command'), function(source, args)
    if player_is_emerg_driver then
        key_lock = not key_lock
        AUDIO:Play('Key_Lock', AUDIO.lock_volume, true)
        HUD:SetItemState('lock', key_lock)
        if not HUD:GetHudState() then
            if key_lock then
                HUD:ShowNotification(Lang:t('info.locked'), true)
            else
                HUD:ShowNotification(Lang:t('info.unlocked'), true)
            end
        end
    end
end)

RegisterKeyMapping(Lang:t('command.lock_command'), Lang:t('control.lock_desc'), 'keyboard', lockout_default_hotkey)

-- =============================================================================
-- FUNCTIONS
-- =============================================================================
RegisterKeyMaps = function()
    for i, _ in ipairs(SIRENS) do
        if i ~= 1 then
            local command = '_lvc_siren_' .. i-1
            local description = Lang:t('control.siren_control_desc', {ord_num = MakeOrdinal(i-1)})
            RegisterCommand(command, function(source, args)
                if veh ~= nil and player_is_emerg_driver ~= nil then
                    if IsVehicleSirenOn(veh) and player_is_emerg_driver and not key_lock then
                        local proposed_tone = UTIL:GetToneAtPos(i)
                        local tone_option = UTIL:GetToneOption(proposed_tone)
                        if i-1 < #UTIL:GetApprovedTonesTable() then
                            if tone_option ~= nil then
                                if tone_option == 1 or tone_option == 3 then
                                    if ( state_lxsiren[veh] ~= proposed_tone or state_lxsiren[veh] == 0 ) then
                                        HUD:SetItemState('siren', true)
                                        AUDIO:Play('Upgrade', AUDIO.upgrade_volume)
                                        SetLxSirenStateForVeh(veh, proposed_tone)
                                        count_bcast_timer = delay_bcast_timer
                                    else
                                        if state_pwrcall[veh] == 0 then
                                            HUD:SetItemState('siren', false)
                                        end
                                        AUDIO:Play('Downgrade', AUDIO.downgrade_volume)
                                        SetLxSirenStateForVeh(veh, 0)
                                        count_bcast_timer = delay_bcast_timer
                                    end
                                end
                            else
                                HUD:ShowNotification(Lang:t('error.reg_keymap_nil_1', {i = i, proposed_tone = proposed_tone, profile_name = UTIL:GetVehicleProfileName()}), true)
                                HUD:ShowNotification(Lang:t('error.reg_keymap_nil_2'), true)
                            end
                        end
                    end
                end
            end)
            if i > 0 and i < 11 and main_siren_set_register_keys_set_defaults then
                RegisterKeyMapping(command, description, 'keyboard', i-1)
            elseif i == 11 and main_siren_set_register_keys_set_defaults then
                RegisterKeyMapping(command, description, 'keyboard', '0')
            else
                RegisterKeyMapping(command, description, 'keyboard', '')
            end
        end
    end
end

MakeOrdinal = function(number)
    local sufixes = { 'th', 'st', 'nd', 'rd', 'th', 'th', 'th', 'th', 'th', 'th' }
    local mod = (number % 100)
    if mod == 11 or mod == 12 or mod == 13 then
        return number .. 'th'
    else
        return number..sufixes[(number % 10) + 1]
    end
end

BroadcastPlayerVehicleState = function(vehicle)
    if veh == vehicle then
        update_data = {
            ['state_lxsiren'] = state_lxsiren[veh],
            ['state_indic']   = state_indic[veh],
            ['state_pwrcall'] = state_pwrcall[veh],
            ['state_airmanu'] = state_airmanu[veh],
            ['actv_manu']     = actv_manu,
            ['actv_horn']     = actv_horn
        }
        TriggerEvent('lvc:UpdateThirdParty', update_data)
    end
end

local function CleanupSounds()
    if count_sndclean_timer > delay_sndclean_timer then
        count_sndclean_timer = 0
        for k, v in pairs(state_lxsiren) do
            if v > 0 then
                if not DoesEntityExist(k) or IsEntityDead(k) then
                    if snd_lxsiren[k] ~= nil then
                        StopSound(snd_lxsiren[k])
                        ReleaseSoundId(snd_lxsiren[k])
                        snd_lxsiren[k] = nil
                        state_lxsiren[k] = nil
                    end
                end
            end
        end
        for k, v in pairs(state_pwrcall) do
            if v > 0 then
                if not DoesEntityExist(k) or IsEntityDead(k) then
                    if snd_pwrcall[k] ~= nil then
                        StopSound(snd_pwrcall[k])
                        ReleaseSoundId(snd_pwrcall[k])
                        snd_pwrcall[k] = nil
                        state_pwrcall[k] = nil
                    end
                end
            end
        end
        for k, v in pairs(state_airmanu) do
            if v == true then
                if not DoesEntityExist(k) or IsEntityDead(k) or IsVehicleSeatFree(k, -1) then
                    if snd_airmanu[k] ~= nil then
                        StopSound(snd_airmanu[k])
                        ReleaseSoundId(snd_airmanu[k])
                        snd_airmanu[k] = nil
                        state_airmanu[k] = nil
                    end
                end
            end
        end
    else
        count_sndclean_timer = count_sndclean_timer + 1
    end
end

function TogIndicStateForVeh(vehicle, newstate)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        if newstate == ind_state_o then
            SetVehicleIndicatorLights(vehicle, 0, false)
            SetVehicleIndicatorLights(vehicle, 1, false)
        elseif newstate == ind_state_l then
            SetVehicleIndicatorLights(vehicle, 0, false)
            SetVehicleIndicatorLights(vehicle, 1, true)
        elseif newstate == ind_state_r then
            SetVehicleIndicatorLights(vehicle, 0, true)
            SetVehicleIndicatorLights(vehicle, 1, false)
        elseif newstate == ind_state_h then
            SetVehicleIndicatorLights(vehicle, 0, true)
            SetVehicleIndicatorLights(vehicle, 1, true)
        end
        state_indic[vehicle] = newstate
        BroadcastPlayerVehicleState(vehicle)
    end
end

function TogMuteDfltSrnForVeh(vehicle, toggle)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        DisableVehicleImpactExplosionActivation(vehicle, toggle)
    end
end

function SetLxSirenStateForVeh(vehicle, newstate)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        if newstate ~= state_lxsiren[vehicle] and newstate ~= nil then
            if snd_lxsiren[vehicle] ~= nil then
                StopSound(snd_lxsiren[vehicle])
                ReleaseSoundId(snd_lxsiren[vehicle])
                snd_lxsiren[vehicle] = nil
            end
            if newstate ~= 0 then
                snd_lxsiren[vehicle] = GetSoundId()
                PlaySoundFromEntity(snd_lxsiren[vehicle], SIRENS[newstate].String, vehicle, SIRENS[newstate].Ref, 0, 0)
                TogMuteDfltSrnForVeh(vehicle, true)
                ALog("LxSiren ON -> tone=" .. tostring(newstate) .. " lighting=" .. tostring(isEnvLightingEnabledForPlayer) .. " switch=" .. tostring(accessibility_switch_on))
            else
                ALog("LxSiren OFF | lighting=" .. tostring(isEnvLightingEnabledForPlayer) .. " switch=" .. tostring(accessibility_switch_on))
            end
            state_lxsiren[vehicle] = newstate
            BroadcastPlayerVehicleState(vehicle)
        end
    end
end

function SetPowercallStateForVeh(vehicle, newstate)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        if newstate ~= state_pwrcall[vehicle] and newstate ~= nil then
            if snd_pwrcall[vehicle] ~= nil then
                StopSound(snd_pwrcall[vehicle])
                ReleaseSoundId(snd_pwrcall[vehicle])
                snd_pwrcall[vehicle] = nil
            end
            if newstate ~= 0 then
                snd_pwrcall[vehicle] = GetSoundId()
                PlaySoundFromEntity(snd_pwrcall[vehicle], SIRENS[newstate].String, vehicle, SIRENS[newstate].Ref, 0, 0)
                ALog("Powercall ON -> tone=" .. tostring(newstate))
            else
                ALog("Powercall OFF")
            end
            state_pwrcall[vehicle] = newstate
            BroadcastPlayerVehicleState(vehicle)
        end
    end
end

function SetAirManuStateForVeh(vehicle, newstate)
    if DoesEntityExist(vehicle) and not IsEntityDead(vehicle) then
        if newstate ~= state_airmanu[vehicle] and newstate ~= nil then
            if snd_airmanu[vehicle] ~= nil then
                StopSound(snd_airmanu[vehicle])
                ReleaseSoundId(snd_airmanu[vehicle])
                snd_airmanu[vehicle] = nil
            end
            if newstate ~= 0 then
                snd_airmanu[vehicle] = GetSoundId()
                PlaySoundFromEntity(snd_airmanu[vehicle], SIRENS[newstate].String, vehicle, SIRENS[newstate].Ref, 0, 0)
            end
            state_airmanu[vehicle] = newstate
            BroadcastPlayerVehicleState(vehicle)
        end
    end
end

-- =============================================================================
-- NETWORK EVENT HANDLERS
-- =============================================================================
RegisterNetEvent('lvc:TogIndicState_c')
AddEventHandler('lvc:TogIndicState_c', function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= GetPlayerPed(-1) then
            if IsPedInAnyVehicle(ped_s, false) then
                TogIndicStateForVeh(GetVehiclePedIsUsing(ped_s), newstate)
            end
        end
    end
end)

RegisterNetEvent('lvc:TogDfltSrnMuted_c')
AddEventHandler('lvc:TogDfltSrnMuted_c', function(sender)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= GetPlayerPed(-1) then
            if IsPedInAnyVehicle(ped_s, false) then
                TogMuteDfltSrnForVeh(GetVehiclePedIsUsing(ped_s), true)
            end
        end
    end
end)

RegisterNetEvent('lvc:SetLxSirenState_c')
AddEventHandler('lvc:SetLxSirenState_c', function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= GetPlayerPed(-1) then
            if IsPedInAnyVehicle(ped_s, false) then
                SetLxSirenStateForVeh(GetVehiclePedIsUsing(ped_s), newstate)
            end
        end
    end
end)

RegisterNetEvent('lvc:SetPwrcallState_c')
AddEventHandler('lvc:SetPwrcallState_c', function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= GetPlayerPed(-1) then
            if IsPedInAnyVehicle(ped_s, false) then
                SetPowercallStateForVeh(GetVehiclePedIsUsing(ped_s), newstate)
            end
        end
    end
end)

RegisterNetEvent('lvc:SetAirManuState_c')
AddEventHandler('lvc:SetAirManuState_c', function(sender, newstate)
    local player_s = GetPlayerFromServerId(sender)
    local ped_s = GetPlayerPed(player_s)
    if DoesEntityExist(ped_s) and not IsEntityDead(ped_s) then
        if ped_s ~= GetPlayerPed(-1) then
            if IsPedInAnyVehicle(ped_s, false) then
                SetAirManuStateForVeh(GetVehiclePedIsUsing(ped_s), newstate)
            end
        end
    end
end)

-- =============================================================================
-- MAIN LOOP
-- =============================================================================
CreateThread(function()
    while true do
        CleanupSounds()
        DistantCopCarSirens(false)

        if GetPedInVehicleSeat(veh, -1) == playerped then
            if state_indic[veh] == nil then
                state_indic[veh] = ind_state_o
            end

            -- INDICATOR AUTO CANCEL
            if actv_ind_timer == true then
                if state_indic[veh] == ind_state_l or state_indic[veh] == ind_state_r then
                    if GetEntitySpeed(veh) < 6 then
                        count_ind_timer = 0
                    else
                        if count_ind_timer > delay_ind_timer then
                            count_ind_timer = 0
                            actv_ind_timer = false
                            state_indic[veh] = ind_state_o
                            TogIndicStateForVeh(veh, state_indic[veh])
                            count_bcast_timer = delay_bcast_timer
                        else
                            count_ind_timer = count_ind_timer + 1
                        end
                    end
                end
            end

            if GetVehicleClass(veh) == 18 then

-- =================================================================
-- ACCESSIBILITY: LIGHTS_ON DERIVATION
-- =================================================================
if isEnvLightingEnabledForPlayer then
    if accessibility_switch_on then
        -- Only call these on the first frame after switch_on becomes true
        -- not every frame — prevents audio blip from repeated siren calls
        if not IsVehicleSirenOn(veh) then
            SetVehicleSiren(veh, true)
            SetVehicleHasMutedSirens(veh, true)
            if trailer ~= nil and trailer ~= 0 then
                SetVehicleSiren(trailer, true)
                SetVehicleHasMutedSirens(trailer, true)
            end
        else
            -- Siren already on, just keep muted — no blip
            SetVehicleHasMutedSirens(veh, true)
            if trailer ~= nil and trailer ~= 0 then
                SetVehicleHasMutedSirens(trailer, true)
            end
        end
    else
        if IsVehicleSirenOn(veh) then
            SetVehicleSiren(veh, false)
            if trailer ~= nil and trailer ~= 0 then
                SetVehicleSiren(trailer, false)
            end
        end
    end
    lights_on = accessibility_switch_on
else
    lights_on = IsVehicleSirenOn(veh)
    accessibility_switch_on = lights_on
end
-- =================================================================
                -- =================================================================
                -- =================================================================

                if radio_masterswitch then
                    SetVehicleRadioEnabled(veh, true)
                end

                if not IsEntityDead(veh) then
                    TogMuteDfltSrnForVeh(veh, true)

                    if state_lxsiren[veh] == nil then state_lxsiren[veh] = 0 end
                    if state_pwrcall[veh] == nil then state_pwrcall[veh] = 0 end
                    if state_airmanu[veh] == nil then state_airmanu[veh] = 0 end

                    -- Kill siren audio if lights switched off
                    if not lights_on and state_lxsiren[veh] > 0 then
                        ALog("lights_on=false, killing LxSiren (was " .. tostring(state_lxsiren[veh]) .. ")")
                        if not tone_main_reset_standby then
                            UTIL:SetToneByID('MAIN_MEM', state_lxsiren[veh])
                        end
                        SetLxSirenStateForVeh(veh, 0)
                        count_bcast_timer = delay_bcast_timer
                    end
                    if not lights_on and state_pwrcall[veh] > 0 then
                        ALog("lights_on=false, killing Powercall")
                        SetPowercallStateForVeh(veh, 0)
                        count_bcast_timer = delay_bcast_timer
                    end

                    if not IsPauseMenuActive() and UpdateOnscreenKeyboard() ~= 0 and not radio_wheel_active then
                        if not key_lock then

                            -- Q: MASTER LIGHTS SWITCH
if IsDisabledControlJustReleased(0, 85) then
                                if lights_on then
                                    ALog("Q -> lights OFF | suppression=" .. tostring(isEnvLightingEnabledForPlayer))
                                    AUDIO:Play('Off', AUDIO.off_volume)
                                    HUD:SetItemState('switch', false)
                                    HUD:SetItemState('siren', false)
                                    SetVehicleSiren(veh, false)
                                    if trailer ~= nil and trailer ~= 0 then
                                        SetVehicleSiren(trailer, false)
                                    end
                                    accessibility_switch_on = false
                                else
                                    AUDIO:Play('On', AUDIO.on_volume)
                                    HUD:SetItemState('switch', true)
                                    accessibility_switch_on = true
                                    if not isEnvLightingEnabledForPlayer then
                                        -- Normal mode — full lights and flash
                                        SetVehicleSiren(veh, true)
                                        if trailer ~= nil and trailer ~= 0 then
                                            SetVehicleSiren(trailer, true)
                                        end
                                    else
                                        -- Suppression active — mute flash but keep AI reaction
                                        SetVehicleSiren(veh, true)
                                        SetVehicleHasMutedSirens(veh, true)
                                        if trailer ~= nil and trailer ~= 0 then
                                            SetVehicleSiren(trailer, true)
                                            SetVehicleHasMutedSirens(trailer, true)
                                        end
                                    end
                                end
                                AUDIO:ResetActivityTimer()
                                count_bcast_timer = delay_bcast_timer

                            -- ALT: LX SIREN TOGGLE
                            elseif IsDisabledControlJustReleased(0, 19) then
                                if state_lxsiren[veh] == 0 then
                                    if lights_on then
                                        ALog("ALT -> LxSiren ON")
                                        AUDIO:Play('Upgrade', AUDIO.upgrade_volume)
                                        HUD:SetItemState('siren', true)
                                        if not tone_main_reset_standby then
                                            tone_mem_id = UTIL:GetToneID('MAIN_MEM')
                                            tone_mem_option = UTIL:GetToneOption(tone_mem_id)
                                            if UTIL:IsApprovedTone(tone_mem_id) and tone_mem_option ~= 3 and tone_mem_option ~= 4 then
                                                SetLxSirenStateForVeh(veh, tone_mem_id)
                                            else
                                                new_tone = UTIL:GetNextSirenTone(tone_mem_id, veh, true)
                                                UTIL:SetToneByID('MAIN_MEM', new_tone)
                                                SetLxSirenStateForVeh(veh, new_tone)
                                            end
                                        else
                                            default_tone = UTIL:GetToneAtPos(2)
                                            default_tone_option = UTIL:GetToneOption(default_tone)
                                            if default_tone_option == 3 or default_tone_option == 4 then
                                                new_tone = UTIL:GetNextSirenTone(default_tone, veh, true)
                                            else
                                                new_tone = UTIL:GetToneAtPos(2)
                                            end
                                            SetLxSirenStateForVeh(veh, new_tone)
                                        end
                                    else
                                        ALog("ALT pressed but lights_on=false, ignoring")
                                    end
                                else
                                    ALog("ALT -> LxSiren OFF")
                                    AUDIO:Play('Downgrade', AUDIO.downgrade_volume)
                                    if state_pwrcall[veh] == 0 then
                                        HUD:SetItemState('siren', false)
                                    end
                                    if not tone_main_reset_standby then
                                        UTIL:SetToneByID('MAIN_MEM', state_lxsiren[veh])
                                    end
                                    SetLxSirenStateForVeh(veh, 0)
                                end
                                AUDIO:ResetActivityTimer()
                                count_bcast_timer = delay_bcast_timer

                            -- POWERCALL
                            elseif IsDisabledControlJustReleased(0, 172) and not IsMenuOpen() then
                                if state_pwrcall[veh] == 0 then
                                    if lights_on then
                                        ALog("Powercall -> ON")
                                        AUDIO:Play('Upgrade', AUDIO.upgrade_volume)
                                        HUD:SetItemState('siren', true)
                                        SetPowercallStateForVeh(veh, UTIL:GetToneID('AUX'))
                                        count_bcast_timer = delay_bcast_timer
                                    end
                                else
                                    ALog("Powercall -> OFF")
                                    AUDIO:Play('Downgrade', AUDIO.downgrade_volume)
                                    if state_lxsiren[veh] == 0 then
                                        HUD:SetItemState('siren', false)
                                    end
                                    SetPowercallStateForVeh(veh, 0)
                                end
                                AUDIO:ResetActivityTimer()
                                count_bcast_timer = delay_bcast_timer
                            end

                            -- CYCLE TONES
                            if state_lxsiren[veh] > 0 then
                                if IsDisabledControlJustReleased(0, 80) then
                                    ALog("Tone cycle")
                                    AUDIO:Play('Upgrade', AUDIO.upgrade_volume)
                                    HUD:SetItemState('horn', false)
                                    SetLxSirenStateForVeh(veh, UTIL:GetNextSirenTone(state_lxsiren[veh], veh, true))
                                    count_bcast_timer = delay_bcast_timer
                                elseif IsDisabledControlPressed(0, 80) then
                                    HUD:SetItemState('horn', true)
                                end
                            end

                            -- MANU
                            if state_lxsiren[veh] < 1 then
                                if IsDisabledControlPressed(0, 80) then
                                    AUDIO:ResetActivityTimer()
                                    actv_manu = true
                                    HUD:SetItemState('siren', true)
                                else
                                    if actv_manu then HUD:SetItemState('siren', false) end
                                    actv_manu = false
                                end
                            else
                                if actv_manu then HUD:SetItemState('siren', false) end
                                actv_manu = false
                            end

                            -- HORN
                            if IsDisabledControlPressed(0, 86) then
                                actv_horn = true
                                AUDIO:ResetActivityTimer()
                                HUD:SetItemState('horn', true)
                            else
                                if actv_horn or actv_manu then HUD:SetItemState('horn', false) end
                                actv_horn = false
                            end

                            -- BUTTON SFX
                            if AUDIO.airhorn_button_SFX then
                                if IsDisabledControlJustPressed(0, 86) then AUDIO:Play('Press', AUDIO.upgrade_volume) end
                                if IsDisabledControlJustReleased(0, 86) then AUDIO:Play('Release', AUDIO.upgrade_volume) end
                            end
                            if AUDIO.manu_button_SFX and state_lxsiren[veh] == 0 then
                                if IsDisabledControlJustPressed(0, 80) then AUDIO:Play('Press', AUDIO.upgrade_volume) end
                                if IsDisabledControlJustReleased(0, 80) then AUDIO:Play('Release', AUDIO.upgrade_volume) end
                            end

                        else
                            if (IsDisabledControlJustReleased(0, 86) or
                                IsDisabledControlJustReleased(0, 172) or
                                IsDisabledControlJustReleased(0, 19) or
                                IsDisabledControlJustReleased(0, 85)) then
                                    if locked_press_count % reminder_rate == 0 then
                                        AUDIO:Play('Locked_Press', AUDIO.lock_reminder_volume, true)
                                        HUD:ShowNotification('~y~~h~Reminder:~h~ ~s~Your siren control box is ~r~locked~s~.', true)
                                    end
                                    locked_press_count = locked_press_count + 1
                            end
                        end
                    end

                    -- HORN / MANU STATE
                    local hmanu_state_new = 0
                    if actv_horn == true and actv_manu == false then
                        hmanu_state_new = UTIL:GetToneID('ARHRN')
                    elseif actv_horn == false and actv_manu == true then
                        hmanu_state_new = UTIL:GetToneID('PMANU')
                    elseif actv_horn == true and actv_manu == true then
                        hmanu_state_new = UTIL:GetToneID('SMANU')
                    end
                    if tone_airhorn_intrp then
                        if hmanu_state_new == UTIL:GetToneID('ARHRN') then
                            if state_lxsiren[veh] > 0 and actv_lxsrnmute_temp == false then
                                srntone_temp = state_lxsiren[veh]
                                SetLxSirenStateForVeh(veh, 0)
                                actv_lxsrnmute_temp = true
                            end
                        else
                            if actv_lxsrnmute_temp == true then
                                SetLxSirenStateForVeh(veh, srntone_temp)
                                actv_lxsrnmute_temp = false
                            end
                        end
                    end

                    if state_airmanu[veh] ~= hmanu_state_new then
                        SetAirManuStateForVeh(veh, hmanu_state_new)
                        count_bcast_timer = delay_bcast_timer
                    end
                end

            else
                TogMuteDfltSrnForVeh(veh, true)
            end

            -- LAND VEHICLE INDICATORS + BROADCAST
            if GetVehicleClass(veh) ~= 14 and GetVehicleClass(veh) ~= 15 and GetVehicleClass(veh) ~= 16 and GetVehicleClass(veh) ~= 21 then
                if not IsPauseMenuActive() then
                    if IsDisabledControlJustReleased(0, left_signal_key) then
                        local cstate = state_indic[veh]
                        if cstate == ind_state_l then
                            state_indic[veh] = ind_state_o
                            actv_ind_timer = false
                        else
                            state_indic[veh] = ind_state_l
                            actv_ind_timer = true
                        end
                        TogIndicStateForVeh(veh, state_indic[veh])
                        count_ind_timer = 0
                        count_bcast_timer = delay_bcast_timer
                    elseif IsDisabledControlJustReleased(0, right_signal_key) then
                        local cstate = state_indic[veh]
                        if cstate == ind_state_r then
                            state_indic[veh] = ind_state_o
                            actv_ind_timer = false
                        else
                            state_indic[veh] = ind_state_r
                            actv_ind_timer = true
                        end
                        TogIndicStateForVeh(veh, state_indic[veh])
                        count_ind_timer = 0
                        count_bcast_timer = delay_bcast_timer
                    elseif IsControlPressed(0, hazard_key) then
                        if GetLastInputMethod(0) then
                            Wait(hazard_hold_duration)
                            if IsControlPressed(0, hazard_key) then
                                local cstate = state_indic[veh]
                                if cstate == ind_state_h then
                                    state_indic[veh] = ind_state_o
                                    AUDIO:Play('Hazards_Off', AUDIO.hazards_volume, true)
                                else
                                    state_indic[veh] = ind_state_h
                                    AUDIO:Play('Hazards_On', AUDIO.hazards_volume, true)
                                end
                                TogIndicStateForVeh(veh, state_indic[veh])
                                actv_ind_timer = false
                                count_ind_timer = 0
                                count_bcast_timer = delay_bcast_timer
                                Wait(300)
                            end
                        end
                    end
                end

                if count_bcast_timer > delay_bcast_timer then
                    count_bcast_timer = 0
                    if GetVehicleClass(veh) == 18 then
                        TriggerServerEvent('lvc:TogDfltSrnMuted_s')
                        TriggerServerEvent('lvc:SetLxSirenState_s', state_lxsiren[veh])
                        TriggerServerEvent('lvc:SetPwrcallState_s', state_pwrcall[veh])
                        TriggerServerEvent('lvc:SetAirManuState_s', state_airmanu[veh])
                    end
                    TriggerServerEvent('lvc:TogIndicState_s', state_indic[veh])
                else
                    count_bcast_timer = count_bcast_timer + 1
                end
            end
        end
        Wait(0)
    end
end)