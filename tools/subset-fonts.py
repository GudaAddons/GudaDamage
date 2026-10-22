"""Builds the pan-locale damage fonts in Fonts/ from the full upstream fonts.

Damage text only needs digits and a few combat words, so each upstream CJK font
(15-25 MB) is cut down to Latin, Cyrillic and the koKR/zhCN/zhTW combat words
listed in tools/subset-chars.txt. The CFF outlines are then converted to
TrueType, because .ttf is the format WoW is known to load for DAMAGE_TEXT_FONT.

Usage (WSL, fontTools installed), from the addon folder:
    python3 tools/subset-fonts.py

Upstream files go in tmp/fonts-src/ (ignored by git):
    SourceHanSansSC-Heavy.otf   github.com/adobe-fonts/source-han-sans  (release/OTF/SimplifiedChinese)
    SourceHanSerifSC-Heavy.otf  github.com/adobe-fonts/source-han-serif (release/OTF/SimplifiedChinese)
    unifont.otf                 unifoundry.com/unifont (font-builds/unifont-<version>.otf)
"""

from pathlib import Path

from fontTools import subset
from fontTools.pens.cu2quPen import Cu2QuPen
from fontTools.pens.ttGlyphPen import TTGlyphPen
from fontTools.ttLib import TTFont, newTable

ROOT = Path(__file__).resolve().parent.parent
SOURCE_DIR = ROOT / "tmp" / "fonts-src"
FONTS_DIR = ROOT / "Fonts"
CHARS_FILE = ROOT / "tools" / "subset-chars.txt"

# source file -> (output file, new family name or None to keep the original).
# Source Han reserves the font name "Source" under the OFL, and a subset is a
# modified version, so those builds must be renamed.
BUILDS = {
    "SourceHanSansSC-Heavy.otf": ("han-sans.ttf", "GudaDamage Han Sans Heavy"),
    "SourceHanSerifSC-Heavy.otf": ("han-serif.ttf", "GudaDamage Han Serif Heavy"),
    "unifont.otf": ("unifont.ttf", None),
}

# name table IDs holding the family, full name, PostScript name and unique ID
RENAMED_NAME_IDS = (1, 3, 4, 6, 16, 17, 21, 22)

# Basic Latin, Latin-1, Latin Extended-A, Cyrillic, General Punctuation, CJK punctuation, fullwidth forms.
UNICODE_RANGES = [
    (0x0020, 0x007E),
    (0x00A0, 0x00FF),
    (0x0100, 0x017F),
    (0x0400, 0x04FF),
    (0x2000, 0x206F),
    (0x3000, 0x3003),
    (0xFF01, 0xFF5E),
]

# Largest distance in font units between a cubic curve and its quadratic replacement.
MAX_CURVE_ERROR = 1.0


def wanted_codepoints():
    codepoints = {cp for first, last in UNICODE_RANGES for cp in range(first, last + 1)}
    codepoints.update(ord(c) for c in CHARS_FILE.read_text(encoding="utf-8") if not c.isspace())
    return codepoints


def subset_font(font, codepoints):
    options = subset.Options()
    options.layout_features = ["kern"]
    options.hinting = False
    options.name_IDs = ["*"]
    options.name_languages = ["*"]
    options.notdef_outline = True
    options.prune_unicode_ranges = False
    subsetter = subset.Subsetter(options)
    subsetter.populate(unicodes=codepoints)
    subsetter.subset(font)


def cff_to_truetype(font):
    """Redraws every CFF glyph as quadratic TrueType outlines (the fontTools otf2ttf recipe)."""
    glyph_order = font.getGlyphOrder()
    glyph_set = font.getGlyphSet()
    glyphs = {}
    for name in glyph_order:
        tt_pen = TTGlyphPen(glyph_set)
        glyph_set[name].draw(Cu2QuPen(tt_pen, MAX_CURVE_ERROR, reverse_direction=True))
        glyphs[name] = tt_pen.glyph()

    font["loca"] = newTable("loca")
    font["glyf"] = glyf = newTable("glyf")
    glyf.glyphOrder = glyph_order
    glyf.glyphs = glyphs
    for tag in ("CFF ", "VORG"):
        if tag in font:
            del font[tag]

    font["maxp"] = maxp = newTable("maxp")
    maxp.tableVersion = 0x00010000
    for field in ("maxTwilightPoints", "maxStorage", "maxFunctionDefs",
                  "maxInstructionDefs", "maxStackElements", "maxSizeOfInstructions",
                  "maxComponentElements"):
        setattr(maxp, field, 0)
    maxp.maxZones = 1
    font["head"].glyphDataFormat = 0
    font["post"].formatType = 2.0
    font["post"].extraNames = []
    font["post"].mapping = {}
    font.sfntVersion = "\x00\x01\x00\x00"


def rename(font, family):
    name = font["name"]
    name.names = [record for record in name.names if record.nameID not in RENAMED_NAME_IDS]
    name.setName(family, 1, 3, 1, 0x409)
    name.setName("Regular", 2, 3, 1, 0x409)
    name.setName(family, 3, 3, 1, 0x409)
    name.setName(family, 4, 3, 1, 0x409)
    name.setName(family.replace(" ", ""), 6, 3, 1, 0x409)


def build(source_name, target_name, family, codepoints):
    font = TTFont(SOURCE_DIR / source_name)
    subset_font(font, codepoints)
    if "CFF " in font:
        cff_to_truetype(font)
    if family:
        rename(font, family)
    target = FONTS_DIR / target_name
    font.save(target)
    print(f"{target_name}: {len(font.getGlyphOrder())} glyphs, {target.stat().st_size // 1024} KB")


def main():
    codepoints = wanted_codepoints()
    for source_name, (target_name, family) in BUILDS.items():
        build(source_name, target_name, family, codepoints)


if __name__ == "__main__":
    main()
