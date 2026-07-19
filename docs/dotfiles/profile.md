# PowerShell 7 profile

# Overview

Source: `configs/dotfiles/Microsoft.PowerShell_profile.ps1`  
Destination: `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

# Features

- Identity: `HEXSEC_IDENTITY`, `HEXSEC_DISTRO`, `HEXSEC_CODENAME`, `HEXSEC_ROOT`
- **Starship** init with Night City theme (`STARSHIP_CONFIG`)
- Oh My Posh Night City as fallback if Starship is missing
- PSReadLine (when available)
- Optional venv: `Documents\scripts\python\0xH3xS3C`
- Aliases for git, Docker, Kubernetes, IaC, and cloud CLIs
- Interactive banner

# Installation

```powershell
.\scripts\Install-Dotfiles.ps1
```

# Usage

```powershell
pwsh
# or open Windows Terminal → PowerShell
```

# Troubleshooting

| Issue | Fix |
|-------|-----|
| Profile not loading | Confirm path under Documents\PowerShell; run `echo $PROFILE` in pwsh |
| Execution policy | `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Starship missing | Install module `base` (`Starship.Starship`), then reopen the terminal |
| Glyphs broken | Set Windows Terminal font to JetBrainsMono Nerd Font |
