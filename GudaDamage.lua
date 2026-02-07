local addonName, ns = ...

-- Apply at file load — engine reads DAMAGE_TEXT_FONT early
DAMAGE_TEXT_FONT = GudaDamageDB and GudaDamageDB.fontPath or ns.DEFAULT_FONT

-- Slash commands
SLASH_GUDADAMAGE1 = "/gudadamage"
SLASH_GUDADAMAGE2 = "/gd"
SlashCmdList["GUDADAMAGE"] = function() ns:ToggleSettings() end

-- Initialization
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, event, addon)
    if addon == addonName then
        GudaDamageDB = GudaDamageDB or { fontPath = ns.DEFAULT_FONT }
        if GudaDamageDB.minimapPos == nil then GudaDamageDB.minimapPos = 225 end
        if GudaDamageDB.minimapHide == nil then GudaDamageDB.minimapHide = false end
        DAMAGE_TEXT_FONT = GudaDamageDB.fontPath
        if GudaDamageDB.fontScale then
            SetCVar(ns.WORLD_TEXT_SCALE_CVAR, GudaDamageDB.fontScale)
        end
        if GudaDamageDB.fontGravity then
            SetCVar(ns.WORLD_TEXT_GRAVITY_CVAR, GudaDamageDB.fontGravity)
        end
        if GudaDamageDB.fontDuration then
            SetCVar(ns.WORLD_TEXT_RAMP_DURATION_CVAR, GudaDamageDB.fontDuration)
        end
        local btn = ns:CreateMinimapButton()
        if GudaDamageDB.minimapHide then
            btn:Hide()
        end
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffGudaDamage|r loaded — type |cffffd200/gd|r to pick a damage font")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ccffGudaDamage|r active font: |cffffd200" .. ns.GetFontInfo(GudaDamageDB.fontPath).name .. "|r")
    end
    -- Re-apply on every ADDON_LOADED to override other font addons
    DAMAGE_TEXT_FONT = (GudaDamageDB and GudaDamageDB.fontPath) or ns.DEFAULT_FONT
end)
