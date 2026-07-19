# Windows Terminal — Night City

# Overview

Windows Terminal color scheme and profile defaults aligned with HexSec macOS **Ghostty** Night City.

| Source | Destination |
|--------|-------------|
| `configs/dotfiles/windows-terminal-night-city.json` | `%USERPROFILE%\.config\hexsec\windows-terminal\night-city.json` |
| `configs/dotfiles/windows-terminal-fragment.json` | `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\HexSec\night-city.json` |
| (merged) | Windows Terminal `settings.json` → scheme + `profiles.defaults` |

# Features

| Setting | Value (Ghostty equivalent) |
|---------|----------------------------|
| Background | `#1E1E22` |
| Foreground | `#E8E0FF` |
| Cursor | `#00F0FF` |
| Selection | `#45454E` |
| Opacity | `86` (`background-opacity = 0.86`) |
| Acrylic | enabled (blur-like) |
| Font | JetBrainsMono Nerd Font, size 13 |
| Ligatures | disabled (`calt` / `liga` / `dlig` = -1) |

ANSI palette matches Ghostty `palette = 0..15`.

# Requirements

- Module `base` (Windows Terminal)
- Module `fonts` (JetBrains Mono Nerd)
- Module `dotfiles`

# Installation

```powershell
.\install.ps1 -Module base,fonts,dotfiles
```

Restart Windows Terminal after install. The scheme **Night City** is applied to `profiles.defaults`.

# Manual selection

Settings → Color schemes → **Night City**, or in `settings.json`:

```json
"profiles": {
  "defaults": {
    "colorScheme": "Night City",
    "opacity": 86,
    "useAcrylic": true,
    "font": { "face": "JetBrainsMono Nerd Font", "size": 13 }
  }
}
```

# Troubleshooting

| Issue | Fix |
|-------|-----|
| Font missing / tofu glyphs | Install module `fonts`; confirm family in Settings → Appearance |
| Scheme not listed | Re-run `.\install.ps1 -Module dotfiles`; check Fragments path |
| Opacity ignored | Ensure Windows 11; acrylic may need transparency effects enabled |
| settings.json parse warning | Fragment still loads the scheme; set **Night City** manually |

# References

- [Windows Terminal color schemes](https://learn.microsoft.com/windows/terminal/customize-settings/color-schemes)
- Ghostty counterpart: HexSec macOS `config.ghostty`
- [Oh My Posh](oh-my-posh.md) · [profile](profile.md)
