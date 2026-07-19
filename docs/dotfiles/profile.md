# PowerShell 7 profile

# Overview

Source: `configs/dotfiles/Microsoft.PowerShell_profile.ps1`  
Destination: `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`

# Features

- Identity: `HEXSEC_IDENTITY`, `HEXSEC_DISTRO`, `HEXSEC_CODENAME`, `HEXSEC_ROOT`
- Oh My Posh init with Night City theme
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
| Oh My Posh missing | Install module `base`, then reopen the terminal |
