local _, ns = ...

ns.FONTS = {
    { name = "Default (Blizzard)", path = "Fonts\\FRIZQT__.TTF",                                    preview = "Interface\\AddOns\\GudaDamage\\Assets\\default.png" },
    { name = "NiceDamage",         path = "Interface\\AddOns\\GudaDamage\\Fonts\\nice-damage.ttf",    preview = "Interface\\AddOns\\GudaDamage\\Assets\\nice-damage.png" },
    { name = "Bungee",             path = "Interface\\AddOns\\GudaDamage\\Fonts\\bungee.ttf",         preview = "Interface\\AddOns\\GudaDamage\\Assets\\bungee.png" },
    { name = "Diablo",             path = "Interface\\AddOns\\GudaDamage\\Fonts\\diablo.ttf",         preview = "Interface\\AddOns\\GudaDamage\\Assets\\diablo.png" },
    { name = "Friz Quadrata",      path = "Interface\\AddOns\\GudaDamage\\Fonts\\friz-quadrata.ttf",  preview = "Interface\\AddOns\\GudaDamage\\Assets\\friz-quadrata.png" },
    { name = "Nosifer",            path = "Interface\\AddOns\\GudaDamage\\Fonts\\nosifer.ttf",        preview = "Interface\\AddOns\\GudaDamage\\Assets\\nosifer.png" },
    { name = "Butcherman",         path = "Interface\\AddOns\\GudaDamage\\Fonts\\butcherman.ttf",     preview = "Interface\\AddOns\\GudaDamage\\Assets\\butcherman.png" },
    { name = "Manufacturing",      path = "Interface\\AddOns\\GudaDamage\\Fonts\\manufacturing-consent.ttf",  preview = "Interface\\AddOns\\GudaDamage\\Assets\\manufacturing.png" },
    { name = "Frijole",            path = "Interface\\AddOns\\GudaDamage\\Fonts\\frijole.ttf",        preview = "Interface\\AddOns\\GudaDamage\\Assets\\frijole.png" },
    { name = "Rubic Glitch",            path = "Interface\\AddOns\\GudaDamage\\Fonts\\rubic-glitch.ttf",        preview = "Interface\\AddOns\\GudaDamage\\Assets\\rubic-glitch.png" },
    { name = "Monoton",            path = "Interface\\AddOns\\GudaDamage\\Fonts\\monoton.ttf",        preview = "Interface\\AddOns\\GudaDamage\\Assets\\monoton.png" },
}

ns.DEFAULT_FONT = ns.FONTS[1].path

local isRetail = (WOW_PROJECT_ID == WOW_PROJECT_MAINLINE)
ns.WORLD_TEXT_SCALE_CVAR = isRetail and "WorldTextScale_v2" or "WorldTextScale"

function ns.GetFontInfo(path)
    for _, f in ipairs(ns.FONTS) do
        if f.path == path then return f end
    end
    return ns.FONTS[1]
end
