local addonName, ns = ...

local FONTS = ns.FONTS
local DEFAULT_FONT = ns.DEFAULT_FONT

local function GetFontName(path)
    for _, f in ipairs(FONTS) do
        if f.path == path then return f.name end
    end
    return FONTS[1].name
end

local function GetFontPreview(path)
    for _, f in ipairs(FONTS) do
        if f.path == path then return f.preview end
    end
    return nil
end

---------------------------------------------------------------
-- Apply at file load — engine reads DAMAGE_TEXT_FONT early
---------------------------------------------------------------
DAMAGE_TEXT_FONT = GudaDamageDB and GudaDamageDB.fontPath or DEFAULT_FONT

---------------------------------------------------------------
-- Logout confirmation popup
---------------------------------------------------------------
local logoutPopup = CreateFrame("Frame", "GudaDamageLogoutPopup", UIParent, "BackdropTemplate")
logoutPopup:SetSize(320, 130)
logoutPopup:SetPoint("CENTER")
logoutPopup:SetFrameStrata("FULLSCREEN_DIALOG")
logoutPopup:SetBackdrop({
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true, tileSize = 32, edgeSize = 24,
    insets = { left = 5, right = 5, top = 5, bottom = 5 },
})
logoutPopup:EnableMouse(true)
logoutPopup:Hide()

local popupText = logoutPopup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
popupText:SetPoint("TOP", 0, -16)
popupText:SetWidth(260)
popupText:SetJustifyH("CENTER")
popupText:SetSpacing(3)

local logoutBtn = CreateFrame("Button", "GudaDamageLogoutBtn", logoutPopup, "SecureActionButtonTemplate, GameMenuButtonTemplate")
logoutBtn:SetSize(110, 28)
logoutBtn:SetPoint("BOTTOMLEFT", logoutPopup, "BOTTOM", -115, 14)
logoutBtn:RegisterForClicks("AnyDown")
logoutBtn:SetAttribute("type", "macro")
logoutBtn:SetAttribute("macrotext", "/logout")
logoutBtn:SetNormalFontObject("GameFontNormal")
logoutBtn:SetHighlightFontObject("GameFontHighlight")
logoutBtn:SetText("Logout")

local laterBtn = CreateFrame("Button", nil, logoutPopup, "GameMenuButtonTemplate")
laterBtn:SetSize(110, 28)
laterBtn:SetPoint("BOTTOMRIGHT", logoutPopup, "BOTTOM", 115, 14)
laterBtn:SetNormalFontObject("GameFontNormal")
laterBtn:SetHighlightFontObject("GameFontHighlight")
laterBtn:SetText("Cancel")
laterBtn:SetScript("OnClick", function() logoutPopup:Hide() end)

---------------------------------------------------------------
-- Settings frame
---------------------------------------------------------------
local settingsFrame
local dropdown
local pendingFont
local previewTex

local function CreateSettingsFrame()
    if settingsFrame then return settingsFrame end

    local f = CreateFrame("Frame", "GudaDamageSettings", UIParent, "ButtonFrameTemplate")
    f:SetSize(320, 330)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:SetFrameStrata("DIALOG")
    f:SetFrameLevel(200)
    f:EnableMouse(true)

    ButtonFrameTemplate_HidePortrait(f)
    ButtonFrameTemplate_HideButtonBar(f)
    if f.Inset then f.Inset:Hide() end

    f:SetTitle("GudaDamage")
    if f.CloseButton then
        f.CloseButton:SetScript("OnClick", function() f:Hide() end)
    end

    -- Draggable title bar
    local dragRegion = CreateFrame("Frame", nil, f)
    dragRegion:SetPoint("TOPLEFT", 0, 0)
    dragRegion:SetPoint("TOPRIGHT", -28, 0)
    dragRegion:SetHeight(24)
    dragRegion:EnableMouse(true)
    dragRegion:RegisterForDrag("LeftButton")
    dragRegion:SetScript("OnDragStart", function()
        f:StartMoving()
        f:SetUserPlaced(false)
    end)
    dragRegion:SetScript("OnDragStop", function()
        f:StopMovingOrSizing()
        f:SetUserPlaced(false)
    end)

    -- Label
    local label = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    label:SetPoint("TOP", f, "TOP", 0, -30)
    label:SetText("Damage Font")

    -- Dropdown
    dropdown = CreateFrame("Frame", "GudaDamageDropdown", f, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOP", label, "BOTTOM", 0, -2)
    UIDropDownMenu_SetWidth(dropdown, 140)

    local function InitializeDropdown()
        local currentPath = pendingFont or (GudaDamageDB and GudaDamageDB.fontPath) or DEFAULT_FONT
        for _, fontInfo in ipairs(FONTS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = fontInfo.name
            info.value = fontInfo.path
            info.checked = (fontInfo.path == currentPath)
            info.func = function(self)
                pendingFont = self.value
                UIDropDownMenu_SetText(dropdown, fontInfo.name)
                if fontInfo.preview then
                    previewTex:SetTexture(fontInfo.preview)
                    previewTex:Show()
                else
                    previewTex:Hide()
                end
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)

    local savedPath = (GudaDamageDB and GudaDamageDB.fontPath) or DEFAULT_FONT
    UIDropDownMenu_SetText(dropdown, GetFontName(savedPath))
    pendingFont = savedPath

    -- Preview texture
    previewTex = f:CreateTexture(nil, "ARTWORK")
    previewTex:SetSize(260, 130)
    previewTex:SetPoint("TOP", dropdown, "BOTTOM", 0, 0)
    local previewPath = GetFontPreview(savedPath)
    if previewPath then
        previewTex:SetTexture(previewPath)
        previewTex:Show()
    else
        previewTex:Hide()
    end

    -- Hint text
    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOP", previewTex, "BOTTOM", 0, -4)
    hint:SetTextColor(1, 0.82, 0)
    hint:SetText("After saving, log out to character select\nfor the new font to take effect.")

    -- Save button
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 26)
    saveBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 7)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        GudaDamageDB.fontPath = pendingFont or DEFAULT_FONT
        DAMAGE_TEXT_FONT = GudaDamageDB.fontPath
        f:Hide()

        local fontName = GetFontName(GudaDamageDB.fontPath)
        popupText:SetText(
            "Font changed to |cffffd200" .. fontName .. "|r\n\n" ..
            "A logout is required for the\nnew damage font to take effect."
        )
        logoutPopup:Show()
    end)

    f:Hide()
    settingsFrame = f
    return f
end

local function ToggleSettings()
    local f = CreateSettingsFrame()
    if f:IsShown() then
        f:Hide()
    else
        local savedPath = (GudaDamageDB and GudaDamageDB.fontPath) or DEFAULT_FONT
        pendingFont = savedPath
        UIDropDownMenu_SetText(dropdown, GetFontName(savedPath))
        local previewPath = GetFontPreview(savedPath)
        if previewPath then
            previewTex:SetTexture(previewPath)
            previewTex:Show()
        else
            previewTex:Hide()
        end
        f:Show()
    end
end

---------------------------------------------------------------
-- Slash commands
---------------------------------------------------------------
SLASH_GUDADAMAGE1 = "/gudadamage"
SLASH_GUDADAMAGE2 = "/gd"
SlashCmdList["GUDADAMAGE"] = function()
    ToggleSettings()
end

---------------------------------------------------------------
-- Initialization
---------------------------------------------------------------
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon == addonName then
        GudaDamageDB = GudaDamageDB or { fontPath = DEFAULT_FONT }
        DAMAGE_TEXT_FONT = GudaDamageDB.fontPath
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffGudaDamage|r loaded — type |cffffd200/gd|r to pick a damage font")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffGudaDamage|r active font: |cffffd200" .. GetFontName(GudaDamageDB.fontPath) .. "|r")
    end
    -- Re-apply on every ADDON_LOADED to override other font addons
    DAMAGE_TEXT_FONT = (GudaDamageDB and GudaDamageDB.fontPath) or DEFAULT_FONT
end)
