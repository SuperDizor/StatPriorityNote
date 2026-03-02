-- Stat priorities by specID
local PRIORITIES = {
    -- DEATH KNIGHT
    [250] = "Str > Vers > Mast > Haste > Crit", -- Blood
    [251] = "Str > Haste > Mast > Crit > Vers", -- Frost
    [252] = "Str > Haste > Mast > Crit > Vers", -- Unholy

    -- DEMON HUNTER
    [577]  = "Agi > Crit > Haste > Mast > Vers", -- Havoc
    [581]  = "Agi > Haste > Vers > Mast > Crit", -- Vengeance
    [1480] = "Int > Mast > Haste > Crit > Vers", -- Devourer (if specID is correct)

    -- DRUID
    [102] = "Int > Mast > Haste > Crit > Vers", -- Balance
    [103] = "Agi > Crit > Mast > Haste > Vers", -- Feral
    [104] = "Agi > Vers > Mast > Haste > Crit", -- Guardian
    [105] = "Int > Haste > Mast > Crit > Vers", -- Restoration

    -- EVOKER
    [1467] = "Int > Mast > Haste > Crit > Vers", -- Devastation
    [1468] = "Int > Haste > Mast > Crit > Vers", -- Preservation
    [1473] = "Int > Mast > Haste > Crit > Vers", -- Augmentation

    -- HUNTER
    [253] = "Agi > Crit > Haste > Mast > Vers", -- Beast Mastery
    [254] = "Agi > Crit > Mast > Haste > Vers", -- Marksmanship
    [255] = "Agi > Haste > Crit > Mast > Vers", -- Survival

    -- MAGE
    [62] = "Int > Mast > Haste > Crit > Vers", -- Arcane
    [63] = "Int > Crit > Haste > Mast > Vers", -- Fire
    [64] = "Int > Mast > Haste > Crit > Vers", -- Frost

    -- MONK
    [268] = "Agi > Vers > Mast > Haste > Crit", -- Brewmaster
    [269] = "Agi > Mast > Crit > Haste > Vers", -- Windwalker
    [270] = "Int > Haste > Crit > Mast > Vers", -- Mistweaver

    -- PALADIN
    [65] = "Int > Haste > Crit > Mast > Vers", -- Holy
    [66] = "Str > Haste > Mast > Vers > Crit", -- Protection
    [70] = "Str > Mast > Haste > Crit > Vers", -- Retribution

    -- PRIEST
    [256] = "Int > Haste > Crit > Mast > Vers", -- Discipline
    [257] = "Int > Mast > Haste > Crit > Vers", -- Holy
    [258] = "Int > Haste > Mast > Crit > Vers", -- Shadow

    -- ROGUE
    [259] = "Agi > Mast > Crit > Haste > Vers", -- Assassination
    [260] = "Agi > Haste > Vers > Crit > Mast", -- Outlaw
    [261] = "Agi > Mast > Crit > Haste > Vers", -- Subtlety

    -- SHAMAN
    [262] = "Int > Mast > Haste > Crit > Vers", -- Elemental
    [263] = "Agi > Mast > Haste > Crit > Vers", -- Enhancement
    [264] = "Int > Haste > Crit > Mast > Vers", -- Restoration

    -- WARLOCK
    [265] = "Int > Haste > Mast > Crit > Vers", -- Affliction
    [266] = "Int > Mast > Haste > Crit > Vers", -- Demonology
    [267] = "Int > Mast > Haste > Crit > Vers", -- Destruction

    -- WARRIOR
    [71] = "Str > Mast > Crit > Haste > Vers", -- Arms
    [72] = "Str > Haste > Mast > Crit > Vers", -- Fury
    [73] = "Str > Haste > Vers > Mast > Crit", -- Protection
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

    -- Use ElvUI templates if available
    if panel.SetTemplate then
        panel:SetTemplate("Transparent") -- or "Default"
    elseif E.CreateBackdrop then
        E:CreateBackdrop(panel, "Transparent")
    else
        return false
    end

    -- ElvUI fonts if available
    local font = (E.media and E.media.normFont) or "Fonts\\FRIZQT__.TTF"
    if headerFS and headerFS.SetFont then
        headerFS:SetFont(font, 13, "OUTLINE")
    end
    if statsFS and statsFS.SetFont then
        statsFS:SetFont(font, 12, "OUTLINE")
    end

    -- ElvUI value color for the stats line
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

    -- Sizing parameters
    local paddingX = 24   -- total horizontal padding
    local minWidth = 220
    local maxWidth = 620  -- keep the panel from becoming too wide

    -- Force text width recalculation
    header:SetWidth(0)
    stats:SetWidth(0)

    local headerW = header:GetStringWidth() or 0
    local statsW  = stats:GetStringWidth() or 0

    local width = math.max(headerW, statsW) + paddingX
    width = math.max(width, minWidth)
    width = math.min(width, maxWidth)

    panel:SetWidth(width)

    -- If we hit maxWidth, wrap the stats line cleanly
    local textAreaW = width - paddingX
    stats:SetWidth(textAreaW)
    stats:SetWordWrap(true)

    -- Adjust height if the stats line wraps
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

    -- Anchor above the Character frame (top-right)
    panel:ClearAllPoints()
    panel:SetPoint("BOTTOMRIGHT", CharacterFrame, "TOPRIGHT", 0, 6)

    panel:SetFrameStrata("DIALOG")
    panel:SetFrameLevel(CharacterFrame:GetFrameLevel() + 200)

    -- Blizzard fallback styling (if ElvUI isn't available)
    panel:SetBackdrop({
        bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 14,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    })
    panel:SetBackdropColor(0, 0, 0, 0.75)

    -- Line 1: Colored class name + spec name (left aligned)
    local header = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -8)
    header:SetJustifyH("LEFT")

    -- Line 2: Stat priority (left aligned)
    local stats = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    stats:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    stats:SetJustifyH("LEFT")
    stats:SetTextColor(1, 0.82, 0)
    stats:SetShadowColor(0, 0, 0, 1)
    stats:SetShadowOffset(1, -1)

    -- Apply ElvUI skin if available
    local skinned = TryApplyElvUISkin(panel, header, stats)
    if skinned then
        -- Optional: remove shadow when using outlined fonts
        stats:SetShadowOffset(0, 0)
    end

    CharacterFrame.StatPriorityNotePanel  = panel
    CharacterFrame.StatPriorityNoteHeader = header
    CharacterFrame.StatPriorityNoteStats  = stats
end

local function UpdateNote()
    if not CharacterFrame or not CharacterFrame.StatPriorityNotePanel then return end

    local specID, specName = GetSpecInfoSafe()

    local headerText = ColorizeClassName()
    if specName then
        headerText = headerText .. " - " .. specName
    else
        headerText = headerText .. " - No Spec"
    end

    local statsText = "Set stat priority for this spec"
    if specID and PRIORITIES[specID] then
        statsText = PRIORITIES[specID]
    end

    CharacterFrame.StatPriorityNoteHeader:SetText(headerText)
    CharacterFrame.StatPriorityNoteStats:SetText(statsText)

    -- Auto-resize based on rendered text width (works with ElvUI fonts too)
    ResizePanelToContent()
end

local function EnsureCharacterUI()
    -- Retail/Midnight safe-load (avoid re-loading if already loaded)
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

        -- In case the frame is already available
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