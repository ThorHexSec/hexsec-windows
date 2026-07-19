# Starship — Night City

# Overview

Cross-shell prompt aligned with HexSec macOS Starship Night City.  
Source: `configs/dotfiles/starship.toml`

| Target | Path |
|--------|------|
| Primary | `%USERPROFILE%\.config\starship.toml` |
| Copy | `%USERPROFILE%\.config\hexsec\starship.toml` |

PowerShell init: `starship init powershell` (via `Microsoft.PowerShell_profile.ps1`).

# Features

| Setting | Value |
|---------|--------|
| Palette | chrome `#FCEE0A`, cyan `#00F0FF`, magenta `#FF2A6D`, night `#1e1e22` |
| Header | `NIGHT CITY` |
| Containers | `custom.docker` (Docker Desktop ready/off) |
| Cloud | AWS, Azure, GCP, Terraform modules enabled |

# Requirements

- Module `base` (`Starship.Starship` via winget)
- Module `fonts` (JetBrains Mono Nerd)
- Module `dotfiles`

# Installation

```powershell
.\install.ps1 -Module base,fonts,dotfiles
```

Open a new `pwsh` session. If Starship is missing, the profile falls back to Oh My Posh Night City.

# Troubleshooting

| Issue | Fix |
|-------|-----|
| Squares instead of glyphs | Set Windows Terminal font to JetBrainsMono Nerd Font |
| Wrong theme | Confirm `%USERPROFILE%\.config\starship.toml` exists; re-run `dotfiles` |
| Slow prompt | `starship timings` — disable unused modules |

# References

- [Starship config](https://starship.rs/config/)
- [Oh My Posh fallback](oh-my-posh.md) · [profile](profile.md) · [Windows Terminal](windows-terminal.md)
