# Modules reference

See the root [README.md](../README.md) for the full package tables.

## Core (`developer-platform`)

| Module | Script | Package list |
|--------|--------|----------------|
| privacy | `scripts/Set-Privacy.ps1` | `lib/Privacy.ps1` · [PRIVACY.md](PRIVACY.md) |
| base | `scripts/Install-Base.ps1` | `configs/packages/base.txt` |
| vcredist | `scripts/Install-VCRedist.ps1` | `configs/packages/vcredist.txt` |
| shell | `scripts/Install-Shell.ps1` | `configs/packages/shell.txt` |
| fonts | (via `install.ps1`) | `configs/packages/fonts.txt` |
| browsers | `scripts/Install-Browsers.ps1` | `configs/packages/browsers.txt` |
| languages | `scripts/Install-Languages.ps1` | `configs/packages/languages.txt` |
| databases | `scripts/Install-Databases.ps1` | `configs/packages/databases.txt` |
| ides | `scripts/Install-Ides.ps1` | `configs/packages/ides.txt` |
| containers | `scripts/Install-Containers.ps1` | `configs/packages/containers.txt` |
| cloud-iac | `scripts/Install-CloudIac.ps1` | `configs/packages/cloud-iac.txt` |
| cyber | `scripts/Install-Cyber.ps1` | `configs/packages/cyber.txt` |
| productivity | `scripts/Install-Productivity.ps1` | `configs/packages/productivity.txt` |
| media | `scripts/Install-Media.ps1` | `configs/packages/media.txt` |
| virt | `scripts/Install-Virt.ps1` | `configs/packages/virt.txt` |
| gaming | `scripts/Install-Gaming.ps1` | `configs/packages/gaming.txt` |
| dotfiles | `scripts/Install-Dotfiles.ps1` | `configs/dotfiles/` · [dotfiles docs](dotfiles/README.md) |

## Opt-in

| Module | Flag | List |
|--------|------|------|
| cloud-gcp | `-WithGcp` | `configs/packages/cloud-gcp.txt` |
| iac-terraform | `-WithTerraform` | `configs/packages/iac-terraform.txt` |

## Full profile

```powershell
# Administrator PowerShell — install everything
.\install.ps1
# equivalent
.\scripts\Install-All.ps1
```
