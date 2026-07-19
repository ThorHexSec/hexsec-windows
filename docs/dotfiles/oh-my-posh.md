# Oh My Posh — Night City (fallback)

# Overview

Optional prompt theme used when **Starship** is not on PATH.  
Primary prompt is Starship — see [starship.md](starship.md).

Theme source: `configs/dotfiles/night-city.omp.json`

| Destination | Path |
|-------------|------|
| Primary | `%USERPROFILE%\.config\hexsec\oh-my-posh\night-city.omp.json` |
| Copy | `Documents\PowerShell\Themes\night-city.omp.json` |

Palette matches HexSec macOS Starship: chrome `#FCEE0A`, cyan `#00F0FF`, magenta `#FF2A6D`, night `#1e1e22`.

# Segments

NIGHT CITY header, session, path, git, kubectl, docker, AWS, Azure, GCP, Terraform, Node, Python, Go, Rust, execution time, status.

# Requirements

- `JanDeDobbeleer.OhMyPosh` (module `base`)
- JetBrains Mono Nerd Font (module `fonts`) — set as Windows Terminal face

# Installation

```powershell
.\install.ps1 -Module base,fonts,dotfiles
```

# Manual init (if needed)

```powershell
oh-my-posh init pwsh --config "$env:USERPROFILE\.config\hexsec\oh-my-posh\night-city.omp.json" | Invoke-Expression
```

# Troubleshooting

| Issue | Fix |
|-------|-----|
| Broken icons | Set Windows Terminal font to JetBrainsMono Nerd Font |
| Theme not found | Re-run `.\scripts\Install-Dotfiles.ps1` |
| Fallback paradox theme | Profile falls back if Night City file is missing |
