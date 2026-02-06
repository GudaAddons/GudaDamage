local _, ns = ...

local FONTS = ns.FONTS
local DEFAULT_FONT = ns.DEFAULT_FONT

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
local pendingScale
local previewTex
local scaleSlider
local scaleRow

local function UpdatePreview(path)
    local preview = ns.GetFontInfo(path).preview
    if preview then
        previewTex:SetTexture(preview)
        previewTex:Show()
    else
        previewTex:Hide()
    end
end

local function CreateSettingsFrame()
    if settingsFrame then return settingsFrame end

    local f = CreateFrame("Frame", "GudaDamageSettings", UIParent, "ButtonFrameTemplate")
    f:SetSize(320, 380)
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
        local currentPath = pendingFont or GudaDamageDB.fontPath
        for _, fontInfo in ipairs(FONTS) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = fontInfo.name
            info.value = fontInfo.path
            info.checked = (fontInfo.path == currentPath)
            info.func = function(self)
                pendingFont = self.value
                UIDropDownMenu_SetText(dropdown, fontInfo.name)
                UpdatePreview(fontInfo.path)
                CloseDropDownMenus()
            end
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dropdown, InitializeDropdown)

    local savedPath = GudaDamageDB.fontPath
    UIDropDownMenu_SetText(dropdown, ns.GetFontInfo(savedPath).name)
    pendingFont = savedPath

    -- Scale slider
    scaleRow = CreateFrame("Frame", nil, f)
    scaleRow:SetHeight(26)
    scaleRow:SetPoint("LEFT", f, "LEFT", 10, 0)
    scaleRow:SetPoint("RIGHT", f, "RIGHT", -10, 0)
    scaleRow:SetPoint("TOP", dropdown, "BOTTOM", 0, -2)

    local scaleLabel = scaleRow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    scaleLabel:SetPoint("LEFT", scaleRow, "LEFT", 0, 0)
    scaleLabel:SetPoint("RIGHT", scaleRow, "CENTER", -60, 0)
    scaleLabel:SetJustifyH("RIGHT")
    scaleLabel:SetText("Scale")

    local savedScale = GudaDamageDB.fontScale or tonumber(GetCVar(ns.WORLD_TEXT_SCALE_CVAR)) or 1.0
    pendingScale = savedScale

    local useModernSlider = DoesTemplateExist and DoesTemplateExist("MinimalSliderWithSteppersTemplate")

    if useModernSlider then
        scaleSlider = CreateFrame("Slider", nil, scaleRow, "MinimalSliderWithSteppersTemplate")
        scaleSlider:SetPoint("LEFT", scaleRow, "CENTER", -50, 0)
        scaleSlider:SetPoint("RIGHT", scaleRow, "RIGHT", -50, 0)
        scaleSlider:SetHeight(20)

        local steps = (3.0 - 0.5) / 0.1
        scaleSlider:Init(savedScale, 0.5, 3.0, steps, {
            [MinimalSliderWithSteppersMixin.Label.Right] = CreateMinimalSliderFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value)
                return WHITE_FONT_COLOR:WrapTextInColorCode(string.format("%.1f", value))
            end)
        })

        scaleSlider:RegisterCallback("OnValueChanged", function(_, value)
            pendingScale = math.floor(value * 10 + 0.5) / 10
        end)

        scaleRow.SetValue = function(_, v) scaleSlider:SetValue(v) end
        scaleRow.GetValue = function() return scaleSlider.Slider:GetValue() end
    else
        scaleSlider = CreateFrame("Slider", nil, scaleRow, "OptionsSliderTemplate")
        scaleSlider:SetPoint("LEFT", scaleRow, "CENTER", -50, 0)
        scaleSlider:SetPoint("RIGHT", scaleRow, "RIGHT", -55, 0)
        scaleSlider:SetMinMaxValues(0.5, 3.0)
        scaleSlider:SetValueStep(0.1)
        scaleSlider:SetObeyStepOnDrag(true)
        scaleSlider.Text:SetText("")
        scaleSlider.Low:SetText("")
        scaleSlider.High:SetText("")
        scaleSlider:SetValue(savedScale)

        local scaleValue = scaleRow:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        scaleValue:SetPoint("LEFT", scaleSlider, "RIGHT", 5, 0)
        scaleValue:SetWidth(40)
        scaleValue:SetJustifyH("LEFT")
        scaleValue:SetFormattedText("%.1f", savedScale)

        scaleSlider:SetScript("OnValueChanged", function(self, value)
            value = math.floor(value * 10 + 0.5) / 10
            pendingScale = value
            scaleValue:SetFormattedText("%.1f", value)
        end)

        scaleRow.SetValue = function(_, v)
            scaleSlider:SetValue(v)
            scaleValue:SetFormattedText("%.1f", v)
        end
        scaleRow.GetValue = function() return scaleSlider:GetValue() end
    end

    scaleRow:EnableMouseWheel(true)
    scaleRow:SetScript("OnMouseWheel", function(self, delta)
        local current = scaleRow.GetValue()
        local val = current + (delta * 0.1)
        val = math.max(0.5, math.min(3.0, val))
        scaleRow:SetValue(val)
        pendingScale = math.floor(val * 10 + 0.5) / 10
    end)

    -- Preview texture
    previewTex = f:CreateTexture(nil, "ARTWORK")
    previewTex:SetSize(260, 130)
    previewTex:SetPoint("TOP", scaleRow, "BOTTOM", 0, -6)
    UpdatePreview(savedPath)

    -- Hint text
    local hint = f:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    hint:SetPoint("TOP", previewTex, "BOTTOM", 0, -4)
    hint:SetTextColor(1, 0.82, 0)
    hint:SetText("After saving, log out to character select\nfor the new font to take effect.")

    -- Hide minimap button checkbox
    local hideCheck = CreateFrame("CheckButton", nil, f, "UICheckButtonTemplate")
    hideCheck:SetPoint("BOTTOM", f, "BOTTOM", -60, 33)
    hideCheck.text = hideCheck.text or hideCheck:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    hideCheck.text:SetPoint("LEFT", hideCheck, "RIGHT", 2, 0)
    hideCheck.text:SetText("Hide minimap button")
    hideCheck:SetScript("OnClick", function(self)
        GudaDamageDB.minimapHide = self:GetChecked() and true or false
        if ns.minimapButton then
            ns.minimapButton:SetShown(not GudaDamageDB.minimapHide)
        end
    end)
    f.hideCheck = hideCheck

    -- Save button
    local saveBtn = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
    saveBtn:SetSize(100, 26)
    saveBtn:SetPoint("BOTTOM", f, "BOTTOM", 0, 7)
    saveBtn:SetText("Save")
    saveBtn:SetScript("OnClick", function()
        GudaDamageDB.fontPath = pendingFont or DEFAULT_FONT
        GudaDamageDB.fontScale = pendingScale or 1.0
        DAMAGE_TEXT_FONT = GudaDamageDB.fontPath
        SetCVar(ns.WORLD_TEXT_SCALE_CVAR, GudaDamageDB.fontScale)
        f:Hide()

        local fontName = ns.GetFontInfo(GudaDamageDB.fontPath).name
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

function ns:ToggleSettings()
    local f = CreateSettingsFrame()
    if f:IsShown() then
        f:Hide()
    else
        if f.hideCheck then
            f.hideCheck:SetChecked(GudaDamageDB.minimapHide or false)
        end
        local savedPath = GudaDamageDB.fontPath
        pendingFont = savedPath
        UIDropDownMenu_SetText(dropdown, ns.GetFontInfo(savedPath).name)
        local savedScale = GudaDamageDB.fontScale or tonumber(GetCVar(ns.WORLD_TEXT_SCALE_CVAR)) or 1.0
        pendingScale = savedScale
        scaleRow:SetValue(savedScale)
        UpdatePreview(savedPath)
        f:Show()
    end
end
