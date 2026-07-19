# Dotfiles (PowerShell 7 · Starship · Windows Terminal)

# Overview

Deploys the **0xH3xS3C / Night City** shell experience for PowerShell 7 and Windows Terminal (aligned with HexSec macOS Ghostty + Starship):

| Source | Destination |
|--------|-------------|
| `configs/dotfiles/starship.toml` | `%USERPROFILE%\.config\starship.toml` |
| `configs/dotfiles/night-city.omp.json` | `%USERPROFILE%\.config\hexsec\oh-my-posh\night-city.omp.json` (fallback) |
| `configs/dotfiles/Microsoft.PowerShell_profile.ps1` | `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| `configs/dotfiles/windows-terminal-night-city.json` | Merged into Windows Terminal `settings.json` + HexSec config copy |
| `configs/dotfiles/windows-terminal-fragment.json` | `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\HexSec\` |

# Requirements

- Modules `base` (PowerShell 7, **Starship**, Oh My Posh, Windows Terminal) and `fonts` (JetBrains Mono Nerd)

# Installation

```powershell
.\install.ps1 -Module base,shell,fonts,dotfiles
.\scripts\Install-Dotfiles.ps1
```

Included in full `.\install.ps1`.

# Features

- **Starship** Night City prompt (parity with HexSec macOS)
- Oh My Posh Night City as fallback if Starship is missing
- Windows Terminal Night City scheme (Ghostty palette, opacity 86%, acrylic, JetBrainsMono Nerd 13)
- Console title / banner: `0xH3xS3C Windows // Starship Night City`
- Work aliases: git, Docker, kubectl, terraform/tofu, AWS/Azure/GCP, trivy, Claude
- Optional activation of `Documents\scripts\python\0xH3xS3C` if present
- Sets `ExecutionPolicy` RemoteSigned for CurrentUser when possible

# Documentation

- [docs/dotfiles/README.md](../dotfiles/README.md)
- [starship.md](../dotfiles/starship.md)
- [profile.md](../dotfiles/profile.md)
- [oh-my-posh.md](../dotfiles/oh-my-posh.md)
- [windows-terminal.md](../dotfiles/windows-terminal.md)
