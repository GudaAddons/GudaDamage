local _, ns = ...

-- The client's own damage font, read before GudaDamage.lua overrides it.
-- On koKR, zhCN, zhTW and ruRU clients this is the font made for that language.
ns.BLIZZARD_DAMAGE_FONT = DAMAGE_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

-- Writing systems a font has glyphs for. Damage numbers work in every font, but
-- words like Dodge, Parry and Immune need the client language's letters.
local LATIN = { latin = true }
local LATIN_CYRILLIC = { latin = true, cyrillic = true }
local ALL_SCRIPTS = { latin = true, cyrillic = true, hangul = true, hanzi = true }

local FONT_DIR = "Interface\\AddOns\\GudaDamage\\Fonts\\"
local ASSET_DIR = "Interface\\AddOns\\GudaDamage\\Assets\\"

ns.FONTS = {
    { name = "Default (Blizzard)", path = ns.BLIZZARD_DAMAGE_FONT,                  preview = ASSET_DIR .. "default.png",       scripts = ALL_SCRIPTS },
    { name = "NiceDamage",         path = FONT_DIR .. "nice-damage.ttf",            preview = ASSET_DIR .. "nice-damage.png",   scripts = LATIN },
    { name = "Bungee",             path = FONT_DIR .. "bungee.ttf",                 preview = ASSET_DIR .. "bungee.png",        scripts = LATIN },
    { name = "Diablo",             path = FONT_DIR .. "diablo.ttf",                 preview = ASSET_DIR .. "diablo.png",        scripts = LATIN },
    { name = "Friz Quadrata",      path = FONT_DIR .. "friz-quadrata.ttf",          preview = ASSET_DIR .. "friz-quadrata.png", scripts = LATIN },
    { name = "Nosifer",            path = FONT_DIR .. "nosifer.ttf",                preview = ASSET_DIR .. "nosifer.png",       scripts = LATIN },
    { name = "Butcherman",         path = FONT_DIR .. "butcherman.ttf",             preview = ASSET_DIR .. "butcherman.png",    scripts = LATIN },
    { name = "Manufacturing",      path = FONT_DIR .. "manufacturing-consent.ttf",  preview = ASSET_DIR .. "manufacturing.png", scripts = LATIN },
    { name = "Frijole",            path = FONT_DIR .. "frijole.ttf",                preview = ASSET_DIR .. "frijole.png",       scripts = LATIN },
    { name = "Rubic Glitch",       path = FONT_DIR .. "rubic-glitch.ttf",           preview = ASSET_DIR .. "rubic-glitch.png",  scripts = LATIN_CYRILLIC },
    { name = "Monoton",            path = FONT_DIR .. "monoton.ttf",                preview = ASSET_DIR .. "monoton.png",       scripts = LATIN },
    { name = "Han Sans Heavy",     path = FONT_DIR .. "han-sans.ttf",               preview = ASSET_DIR .. "han-sans.png",      scripts = ALL_SCRIPTS },
    { name = "Han Serif Heavy",    path = FONT_DIR .. "han-serif.ttf",              preview = ASSET_DIR .. "han-serif.png",     scripts = ALL_SCRIPTS },
    { name = "Unifont",            path = FONT_DIR .. "unifont.ttf",                preview = ASSET_DIR .. "unifont.png",       scripts = ALL_SCRIPTS },
}

local LOCALE_SCRIPTS = {
    ruRU = "cyrillic",
    koKR = "hangul",
    zhCN = "hanzi",
    zhTW = "hanzi",
}
ns.CLIENT_SCRIPT = LOCALE_SCRIPTS[GetLocale()] or "latin"

function ns.FontSupportsClient(fontInfo)
    return fontInfo.scripts[ns.CLIENT_SCRIPT] == true
end

-- Bungee on Latin clients; Han Sans Heavy where Bungee has no letters for the language
ns.DEFAULT_FONT = (ns.CLIENT_SCRIPT == "latin") and (FONT_DIR .. "bungee.ttf") or (FONT_DIR .. "han-sans.ttf")

-- Every current client (Era, Anniversary, MoP Classic, Retail, WoW: Forever) only has
-- the _v2 world text CVars. Detect them instead of trusting WOW_PROJECT_ID, which
-- Forever does not have; fall back to the old names for older clients.
local WORLD_TEXT_SUFFIX = GetCVar("WorldTextScale_v2") and "_v2" or ""
ns.WORLD_TEXT_SCALE_CVAR = "WorldTextScale" .. WORLD_TEXT_SUFFIX
ns.WORLD_TEXT_GRAVITY_CVAR = "WorldTextGravity" .. WORLD_TEXT_SUFFIX
ns.WORLD_TEXT_RAMP_DURATION_CVAR = "WorldTextRampDuration" .. WORLD_TEXT_SUFFIX

function ns.GetFontInfo(path)
    for _, f in ipairs(ns.FONTS) do
        if f.path == path then return f end
    end
    return ns.FONTS[1]
end
