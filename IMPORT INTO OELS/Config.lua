Config = {}

Config.Debug = false

Config.VersionCheck = true

Config.UIEnabled = true
Config.UIDefaultOn = false
Config.UICommand = "toggleELSUI"

Config.DefaultKeybinds = {} -- Intentionally left empty, edit tables below.

Config.DefaultKeybinds.Keyboard = {
    PrimaryLights = "Q",
    SecondaryLights = "K",
    WarningLights = "L",
    SirensToggle = "LAlt",
    SirensSwitch = "R",
    Bullhorn = "U",
    LeftAlleyLight = "7",
    RightAlleyLight = "8",
    IndicatorsLeft = "LEFT",
    IndicatorsRight = "RIGHT",
    Hazards = "BACK",
    SecondSirenToggle = "",
    SecondSirenSwitch = ""
}

Config.DefaultKeybinds.Controller = {
    PrimaryLights = "LLEFT_INDEX",
    SirensToggle = "LDOWN_INDEX",
    SirensSwitch = "RRIGHT_INDEX",
    SecondSirenToggle = "",
    SecondSirenSwitch = "",
    Bullhorn = "RDOWN_INDEX",
    IndicatorsLeft = "",
    IndicatorsRight = "",
    Hazards = ""
}

Config.Soundpacks = {
     "DLC_LGMODS\\sirenpack_one",
     "DLC_LGMODS\\sirenpack_two",
     "DLC_LGMODS\\sirenpack_three"
}

Config.Optilink = {
    Enabled = true,
    Use999Sound = {
        -- `Vehicle Spawn Code` (ENSURE YOU ARE USING `` AROUND THE SPAWN CODE AND NOT "")
    }
}

Config.NonELS = {
    -- `Vehicle Spawn Code` (ENSURE YOU ARE USING `` AROUND THE SPAWN CODE AND NOT "")
    [`NONELS`] = {
        PrimaryLights = {1},
        SecondaryLights = {3},
        WarningLights = {4},
        OnSceneLights = {2}
    }
}

Config.WigWags = true
Config.PrimaryPatterns = {
    ["leds"] = {{{1, 2}, 250}, {{3, 4}, 250}},
    ["matrix"] = {{{1, 2}, 250}, {{3, 4}, 250}},
    ["leds2"] = {{{1, 2}, 250}, {{3, 4}, 250}},
    ["leds3"] = {{{1, 2}, 250}, {{3, 4}, 250}},

    ["high"] = {{{1, 5}, 250}, {{4, 6}, 250}},
    ["bike"] = {{{1, 2}, 250}, {{4}, 250}},
    ["benebox"] = {{{1, 3}, 250}, {{4, 2}, 250}},
    ["carautil"] = {{{1}, 250}, {{4}, 250}},
    ["muletow"] = {{{1}, 250}, {{4}, 250}},
    ["landhigh"] = {{{1, 2}, 250}, {{3, 4}, 250}},
    ["rhinehh"] = {{{3, 4}, 250}, {{1, 2}, 250}},
    ["highrebla"] = {{{3, 4}, 250}, {{1, 2}, 250}},
    ["btp"] = {{{1, 2}, 150}, {{}, 150}, {{1, 2}, 150}, {{3, 4}, 150}, {{}, 150}, {{3, 4}, 150}},
    ["rotator"] = {{{1}, 250}, {{2}, 250}, {{3}, 250}, {{4}, 250}},
}

Config.OnScenePatterns = {
    ["leds"] = {{{2, 4}, 1200}, {{3, 1}, 1200}},
    ["matrix"] = {{{1, 2}, 1200}, {{3, 4}, 1200}},
    ["leds2"] = {{{2, 4}, 1200}, {{3, 1}, 1200}},
    ["leds3"] = {{{2, 4}, 1200}, {{3, 1}, 1200}},

    ["high"] = {{{1, 5}, 1200}, {{4, 6}, 1200}},
    ["bike"] = {{{1}, 1200}, {{4}, 1200}},
    ["benebox"] = {{{1, 2}, 1200}, {{3, 4}, 1200}},
    ["carautil"] = {{{1}, 1200}, {{4}, 1200}},
    ["muletow"] = {{{1, 8}, 1200}, {{4, 7}, 1200}},
    ["landhigh"] = {{{1, 2}, 1200}, {{3, 4}, 1200}},
    ["rhinehh"] = {{{3, 4}, 1200}, {{1, 2}, 1200}},
    ["highrebla"] = {{{1, 9, 11}, 1200}, {{4, 7, 12}, 1200}},
    ["btp"] = {{{1,9}, 300}, {{}, 0}, {{1,9}, 300}, {{4,7}, 300}, {{}, 0}, {{4,7}, 300}},
    ["rotator"] = {{{}, 300}},
}

Config.SecondaryPatterns = {
    ["leds"] = {{{9, 6}, 1200}, {{7, 5}, 1200}},
    ["matrix"] = {{{9}, 1200}, {{7}, 1200}},
    ["leds2"] = {{{9}, 1200}, {{7}, 1200}},
    ["leds3"] = {{{7}, 1200}, {{9}, 1200}},

    ["high"] = {{{2}, 1200}, {{}, 1200}},
    ["bike"] = {{{}, 1200}, {{}, 1200}},
    ["benebox"] = {{{}, 1200}, {{}, 1200}},
    ["carautil"] = {{{1}, 1200}, {{4}, 1200}},
    ["landhigh"] = {{{7, 8}, 1200}, {{9, 11}, 1200}},
    ["muletow"] = {{{8}, 1200}, {{7}, 1200}},
    ["rhinehh"] = {{{7, 12}, 1200}, {{9, 11}, 1200}},
    ["highrebla"]  = {{{11, 9}, 1200}, {{12, 7}, 1200}},
    ["btp"] = {{{9}, 1200}, {{}, 1200}, {{7}, 1200}, {{}, 1200}},
    ["rotator"] = {{{9}, 1200}, {{}, 1200}, {{7}, 1200}, {{}, 1200}}
}

Config.WarningPatterns = {
    ["leds"] = {{{5}, 250}, {{6}, 250}},
    ["matrix"] = {{{5}, 250}, {{6}, 250}},
    ["leds2"] = {{{5, 6}, 5000}},
    ["leds3"] = {{{5}, 250}, {{6}, 250}},

    ["high"] = {{{3}, 700}, {{}, 700}},
    ["bike"] = {{{}, 700}, {{}, 700}},
    ["benebox"] = {{{2}, 700}, {{4}, 700}},
    ["carautil"] = {{{11}, 5000}},
    ["muletow"] = {{{8}, 250}, {{7}, 500}},
    ["landhigh"] = {{{5}, 1000}, {{6}, 1000}},
    ["rhinehh"] = {{{5}, 1000}, {{6}, 1000}},
    ["highrebla"] = {{{5}, 1000}, {{6}, 1000}},
    ["btp"] = {{{6}, 280}, {{}, 160}, {{5}, 280}, {{}, 160}},
    ["rotator"] = {{{6}, 280}, {{}, 160}, {{5}, 280}, {{}, 160}}
}