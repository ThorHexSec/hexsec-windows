# Dotfiles (PowerShell 7 · Oh My Posh · Windows Terminal)

# Overview

Deploys the **0xH3xS3C / Night City** shell experience for PowerShell 7 and Windows Terminal (aligned with HexSec macOS Ghostty + Starship):

| Source | Destination |
|--------|-------------|
| `configs/dotfiles/night-city.omp.json` | `%USERPROFILE%\.config\hexsec\oh-my-posh\night-city.omp.json` |
| `configs/dotfiles/Microsoft.PowerShell_profile.ps1` | `Documents\PowerShell\Microsoft.PowerShell_profile.ps1` |
| `configs/dotfiles/windows-terminal-night-city.json` | Merged into Windows Terminal `settings.json` + HexSec config copy |
| `configs/dotfiles/windows-terminal-fragment.json` | `%LOCALAPPDATA%\Microsoft\Windows Terminal\Fragments\HexSec\` |

A copy of the Oh My Posh theme is also placed under `Documents\PowerShell\Themes\`.

# Requirements

- Modules `base` (PowerShell 7, Oh My Posh, Windows Terminal) and `fonts` (JetBrains Mono Nerd)

# Installation

```powershell
.\install.ps1 -Module base,shell,fonts,dotfiles
.\scripts\Install-Dotfiles.ps1
```

Included in full `.\install.ps1`.

# Features

- Oh My Posh Night City theme (aligned with HexSec macOS Starship colors)
- Windows Terminal Night City scheme (Ghostty palette, opacity 86%, acrylic, JetBrainsMono Nerd 13)
- Console title: `Thor@0xH3xS3C // <folder>`
- Work aliases: git, Docker, kubectl, terraform/tofu, AWS/Azure/GCP, trivy, Claude
- Optional activation of `Documents\scripts\python\0xH3xS3C` if present
- Short interactive banner
- Sets `ExecutionPolicy` RemoteSigned for CurrentUser when possible

# Documentation

- [docs/dotfiles/README.md](../dotfiles/README.md)
- [profile.md](../dotfiles/profile.md)
- [oh-my-posh.md](../dotfiles/oh-my-posh.md)
- [windows-terminal.md](../dotfiles/windows-terminal.md)
