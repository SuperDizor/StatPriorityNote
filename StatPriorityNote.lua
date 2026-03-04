-- Stat priorities by specID
local PRIORITIES = {
    -- DEATH KNIGHT
    [250] = {
        "Deathbringer: Strength > Critical Strike > Mastery = Versatility > Haste",
        "San'layn: Strength > Haste > Mastery = Critical Strike = Versatility",
    },                                                                                                  -- Blood
    [251] = "Strength > Critical Strike > Mastery > Haste > Versatility",                               -- Frost
    [252] = "Strength > Mastery > Critical Strike > Haste > Versatility",                               -- Unholy

    -- DEMON HUNTER
    [577]  = "Agility > Critical Strike > Mastery > Haste > Versatility",                               -- Havoc
    [581]  = "Item Level / Agility / Stamina > Haste > Critical Strike > Versatility > Mastery",        -- Vengeance
    [1480] = {
        "Annihilator: Intellect > Haste > Mastery > Critical Strike > Versatility",
        "Void-Scarred: Intellect > Mastery > Haste > Critical Strike > Versatility"
    },                                                                                                  -- Devourer

    -- DRUID
    [102] = "Intellect > Mastery > Haste > Versatility > Critical Strike",                              -- Balance
    [103] = {
        "Druid of the Claw: Agility > Mastery > Haste > Critical Strike > Versatility",
        "Wildstalker: Agility > Mastery > Critical Strike > Haste > Versatility"
    },                                                                                                  -- Feral
    [104] = "Agility > Haste > Versatility > Critical Strike > Mastery",                                -- Guardian
    [105] = "Haste > Mastery > Versatility > Intellect > Critical Strike",                              -- Restoration

    -- EVOKER
    [1467] = "Intellect > Critical Strike > Haste > Mastery > Versatility",                             -- Devastation
    [1468] = "Mastery > Haste > Versatility > Critical Strike > Intellect",                             -- Preservation
    [1473] = "Intellect > Critical Strike > Haste > Mastery > Versatility",                             -- Augmentation

    -- HUNTER
    [253] = {
        "Pack Leader (Mythic+): Weapon Damage > Agility > Mastery > Critical Strike > Versatility > Haste",
        "Pack Leader (Raid): Weapon Damage > Agility > Mastery > Haste > Critical Strike > Versatility",
        "Dark Ranger (Mythic+): Weapon Damage > Agility > Mastery > Critical Strike > Haste = Versatility",
        "Dark Ranger (Raid): Weapon Damage > Agility > Mastery > Haste > Critical Strike > Versatility"
    },                                                                                                  -- Beast Mastery
    [254] = "Agility > Critical Strike > Mastery > Haste > Versatility",                                -- Marksmanship
    [255] = {
        "Pack Leader: Agility > Mastery > Critical Strike = Haste > Versatility",
        "Sentinel: Agility > Mastery > Critical Strike > Haste > Versatility"
    },                                                                                                  -- Survival

    -- MAGE
    [62] = "Intellect > Mastery > Haste > Critical Strike > Versatility",                               -- Arcane
    [63] = "Intellect > Haste > Mastery > Versatility > Critical Strike",                               -- Fire
    [64] = "Intellect > Mastery > Critical Strike > Haste > Versatility",                               -- Frost

    -- MONK
    [268] = {
        "Defensive: Item Level / Agility / Armor / Stamina > Versatility = Critical Strike = Mastery > Haste",
        "Offensive: Item Level / Agility > Critical Strike > Mastery > Versatility > Haste"
    },                                                                                                  -- Brewmaster
    [269] = {
        "Shado-pan: Agility > Haste > Critical Strike > Mastery > Versatility",
        "Conduit of the Celestials: Agility > Haste > Mastery > Critical Strike > Versatility"
    },                                                                                                  -- Windwalker
    [270] = {
        "Raid: Intellect > Haste > Critical Strike > Versatility > Mastery",
        "Mythic+: Intellect > Haste > Versatility > Critical Strike > Mastery"
    },                                                                                                  -- Mistweaver

    -- PALADIN
    [65] = "Intellect > Mastery > Haste = Critical Strike > Versatility",                               -- Holy
    [66] = {
        "Survivability: Strength > Haste > Versatility > Mastery > Critical Strike",
        "DPS: Strength > Haste > Versatility > Critical Strike > Mastery"
    },                                                                                                  -- Protection
    [70] = "Strength > Mastery > Haste > Critical Strike > Versatility",                                -- Retribution

    -- PRIEST
    [256] = {
        "Raid: Intellect > Haste > Critical Strike > Mastery > Versatility",
        "Mythic+: Intellect > Haste > Critical Strike > Versatility > Mastery"
    },                                                                                                  -- Discipline
    [257] = {
        "Raid: Intellect > Critical Strike > Mastery > Versatility > Haste",
        "Mythic+: Intellect > Critical Strike > Haste > Versatility > Mastery"
    },                                                                                                  -- Holy
    [258] = "Intellect > Haste > Mastery > Critical Strike > Versatility",                              -- Shadow

    -- ROGUE
    [259] = "Agility > Critical Strike > Haste > Mastery > Versatility",                                -- Assassination
    [260] = "Agility > Haste > Critical Strike > Versatility > Mastery",                                -- Outlaw
    [261] = "Agility > Mastery > Haste  > Critical Strike > Versatility",                               -- Subtlety

    -- SHAMAN
    [262] = "Mastery > Critical Strike = Haste > Versatility > Intellect",                              -- Elemental
    [263] = {
        "Stormbringer: Agility > Haste > Mastery = Critical Strike > Versatility",
        "Totemic: Agility > Mastery > Haste > Critical Strike > Versatility"
    },                                                                                                  -- Enhancement
    [264] = "Intellect > Critical Strike = Haste > Versatility > Mastery",                              -- Restoration

    -- WARLOCK
    [265] = "Intellect > Mastery = Critical Strike > Haste > Versatility",                              -- Affliction
    [266] = "Intellect > Haste = Critical Strike > Mastery > Versatility",                              -- Demonology
    [267] = "Intellect > Haste > Mastery >= Critical Strike > Versatility",                             -- Destruction

    -- WARRIOR
    [71] = "Strength > Critical Strike > Haste > Mastery > Versatility",                                -- Arms
    [72] = "Strength > Haste > Mastery > Critical Strike > Versatility",                                -- Fury
    [73] = "Strength > Haste > Critical Strike > Versatility > Mastery",                                -- Protection
}

-- ---------- Helpers (class + spec) ----------

local function ColorizeClassName()
    local className, classFile = UnitClass("player")
    local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[classFile]
    if not c then return className end
    return ("|cFF%02X%02X%02X%s|r"):format(c.r * 255, c.g * 255, c.b * 255, className)
end

local function GetSpecInfoSafe()
    local specIndex = GetSpecialization()
    if not specIndex then return nil, nil end
    local specID, specName = GetSpecializationInfo(specIndex)
    return specID, specName
end

-- ---------- ElvUI skin (optional) ----------

local function TryApplyElvUISkin(panel, headerFS, statsFS)
    if not _G.ElvUI then return false end

    local E = unpack(_G.ElvUI)
    if not E then return false end

    if panel.SetTemplate then
        panel:SetTemplate("Transparent") -- or "Default"
    elseif E.CreateBackdrop then
        E:CreateBackdrop(panel, "Transparent")
    else
        return false
    end

    local font = (E.media and E.media.normFont) or "Fonts\\FRIZQT__.TTF"
    if headerFS and headerFS.SetFont then
        headerFS:SetFont(font, 13, "OUTLINE")
    end
    if statsFS and statsFS.SetFont then
        statsFS:SetFont(font, 12, "OUTLINE")
    end

    if statsFS and statsFS.SetTextColor and E.media and E.media.rgbvaluecolor then
        local r, g, b = E.media.rgbvaluecolor.r, E.media.rgbvaluecolor.g, E.media.rgbvaluecolor.b
        statsFS:SetTextColor(r, g, b)
    end

    return true
end

-- ---------- Auto size panel ----------

local function ResizePanelToContent()
    if not CharacterFrame or not CharacterFrame.StatPriorityNotePanel then return end

    local panel  = CharacterFrame.StatPriorityNotePanel
    local header = CharacterFrame.StatPriorityNoteHeader
    local stats  = CharacterFrame.StatPriorityNoteStats
    if not panel or not header or not stats then return end

    local paddingX = 24
    local minWidth = 220
    local maxWidth = 620

    header:SetWidth(0)
    stats:SetWidth(0)

    local headerW = header:GetStringWidth() or 0
    local statsW  = stats:GetStringWidth() or 0

    local width = math.max(headerW, statsW) + paddingX
    width = math.max(width, minWidth)
    width = math.min(width, maxWidth)

    panel:SetWidth(width)

    local textAreaW = width - paddingX
    stats:SetWidth(textAreaW)
    stats:SetWordWrap(true)

    local baseH  = 46
    local extraH = math.max(0, (stats:GetStringHeight() or 0) - 12)
    panel:SetHeight(baseH + extraH)
end

-- ---------- UI creation / update ----------

local function CreateNote()
    if not CharacterFrame then return end
    if CharacterFrame.StatPriorityNotePanel then return end

    local panel = CreateFrame("Frame", nil, CharacterFrame, "BackdropTemplate")
    panel:SetSize(420, 46)

    panel:ClearAllPoints()
    panel:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", 0, 6)

    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(CharacterFrame:GetFrameLevel() + 200)

    panel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0, 0, 0, 0.75)

    local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -8)
    header:SetJustifyH("LEFT")

    local stats = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stats:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    stats:SetJustifyH("LEFT")
    stats:SetTextColor(1, 0.82, 0)
    stats:SetShadowColor(0, 0, 0, 1)
    stats:SetShadowOffset(1, -1)

    local skinned = TryApplyElvUISkin(panel, header, stats)
    if skinned then
        stats:SetShadowOffset(0, 0)
    end

    CharacterFrame.StatPriorityNotePanel  = panel
    CharacterFrame.StatPriorityNoteHeader = header
    CharacterFrame.StatPriorityNoteStats  = stats
end

local function UpdateNote()
    if not CharacterFrame or not CharacterFrame.StatPriorityNotePanel then return end

    local specID, specName = GetSpecInfoSafe()

    local headerText = ColorizeClassName() .. " - " .. (specName or "No Spec")

    local statsText = "Set stat priority for this spec"
    if specID and PRIORITIES[specID] then
        local entry = PRIORITIES[specID]

        if type(entry) == "table" then
            -- Multiple lines support: join with newline
            statsText = table.concat(entry, "\n")
        else
            -- Single line support
            statsText = entry
        end
    end

    CharacterFrame.StatPriorityNoteHeader:SetText(headerText)
    CharacterFrame.StatPriorityNoteStats:SetText(statsText)

    ResizePanelToContent()
end

local function EnsureCharacterUI()
    if _G.CharacterFrame then return end

    if C_AddOns and C_AddOns.IsAddOnLoaded and C_AddOns.IsAddOnLoaded("Blizzard_CharacterUI") then
        return
    end

    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn("Blizzard_CharacterUI")
    elseif LoadAddOn then
        LoadAddOn("Blizzard_CharacterUI")
    end
end

-- ---------- Events ----------

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")

f:SetScript("OnEvent", function(_, event, unit)
    if event == "PLAYER_LOGIN" then
        EnsureCharacterUI()

        hooksecurefunc("ToggleCharacter", function()
            EnsureCharacterUI()
            CreateNote()
            UpdateNote()
        end)

        CreateNote()
        UpdateNote()

    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        if unit == "player" then
            UpdateNote()
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        UpdateNote()
    end
end)