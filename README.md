# GudaDamage

A World of Warcraft addon that lets you customize the floating combat damage font.

## Features

- **14 built-in fonts**: Default (Blizzard), NiceDamage, Bungee, Diablo, Friz Quadrata, Nosifer, Butcherman, Manufacturing, Frijole, Rubic Glitch, Monoton, Han Sans Heavy, Han Serif Heavy, Unifont
- **Live preview**: see how each font looks before saving
- **Scale, gravity and duration sliders** for the floating damage numbers
- **Draggable minimap button**: quick access to settings, can be hidden
- **Multi-version support**: Retail, MoP Classic, TBC Anniversary, Classic Era and WoW: Forever

## Fonts and game languages

Damage numbers show in every font. Words such as Dodge, Parry, Immune and Resist need letters for your game language. Fonts without them are shown in grey in the font list.

| Font | English, German, French, Spanish, Italian, Portuguese | Russian | Korean | Chinese |
|------|:---:|:---:|:---:|:---:|
| Default (Blizzard) | ✓ | ✓ | ✓ | ✓ |
| Han Sans Heavy, Han Serif Heavy, Unifont | ✓ | ✓ | ✓ | ✓ |
| Rubic Glitch | ✓ | ✓ | | |
| All other fonts | ✓ | | | |

On Russian, Korean and Chinese clients the default font is Han Sans Heavy.

Han Sans Heavy and Han Serif Heavy are cut-down versions of Adobe's Source Han Sans and Source Han Serif. Unifont is GNU Unifont. All three use the SIL Open Font License (see `Fonts/LICENSE-*.txt`). They keep only the letters damage text needs, so each file is about 100 KB. To rebuild them, see `tools/subset-fonts.py`.

## Usage

- `/gd` or `/gudadamage` opens the settings panel
- Click the minimap button to toggle settings
- Drag the minimap button around the minimap to reposition it

## Note

After changing the damage font, you must **log out to the character select screen** for the new font to take effect. A simple `/reload` is not enough, because the game reads the damage font at login.

### WoW: Forever

The WoW: Forever client can lose addon settings between sessions. The scale, gravity and duration settings are kept by the game itself, but the chosen font may go back to the default. Tools that fix saved addon settings on Forever, such as Forever Data Protect, ForeverSVFix or SVShim, also fix this.

## Author

Vati
