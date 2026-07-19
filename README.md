# HexSec Windows

**HexSec Windows** is Infrastructure as Code for **Windows 11 Pro**.  
It provisions a reproducible **developer / SRE workstation** — full profile or selected modules — using **winget** as the primary package manager.

| | |
|---|---|
| **Version** | **1.2.0** |
| **Target OS** | Windows 11 Pro |
| **Package managers** | winget (primary) · pip (only when winget has no suitable package) |
| **Automation** | PowerShell (primary) · Ansible adapter (optional) |
| **Profile** | `developer-platform` |
| **Containers** | Docker Desktop **Windows-only** (Hyper-V — **no WSL**) |
| **License** | MIT · Copyright © ThorHexSec |

---

## Install everything

Open **PowerShell as Administrator**, then run:

```powershell
cd hexsec-windows
Set-ExecutionPolicy -Scope Process Bypass -Force
.\install.ps1
```

That single command applies the full `developer-platform` profile: privacy hardening, runtimes, IDEs, databases, containers, cloud/IaC CLIs, media, VirtualBox, Steam, RetroArch, and the remaining core modules in order.

Equivalent:

```powershell
.\scripts\Install-All.ps1
```

**Recommended first** — preview without changing the system:

```powershell
.\install.ps1 -DryRun
```

Optional flags on the full install:

```powershell
.\install.ps1 -WithGcp -WithTerraform
```

| Flag | Effect |
|------|--------|
| `-WithGcp` | Also install Google Cloud SDK |
| `-WithTerraform` | Also install HashiCorp Terraform (OpenTofu remains the default IaC engine) |

After a full run: **sign out or reboot**, then complete the [post-install checklist](#post-install-checklist).

---

## Overview

- **Full install** — every core module in a defined order (`.\install.ps1`).
- **Modular install** — one or more modules only (`-Module …`).
- **Opt-in extras** — Google Cloud SDK, HashiCorp Terraform.
- **Privacy first** — telemetry reduction, Sticky Keys off, Explorer Recents off, Copilot removed.
- **Gaming** — Steam and RetroArch.
- **No WSL** — Docker Desktop uses the Windows / Hyper-V backend only.

Package IDs live in `configs/packages/*.txt` (single source of truth). Ansible playbooks call the same PowerShell installer; they do not duplicate package lists.

---

## Requirements

- Windows 11 Pro
- Administrator PowerShell session
- Network access
- [App Installer / winget](https://learn.microsoft.com/windows/package-manager/winget/)
- Virtualization enabled in firmware (required for Docker Desktop with Hyper-V and for VirtualBox)

---

## Quick start

### Modular install

```powershell
.\install.ps1 -List
.\install.ps1 -Module privacy
.\install.ps1 -Module base,shell,languages,databases,ides
.\install.ps1 -Module containers,cloud-iac
.\install.ps1 -Module gaming
.\scripts\Install-Ides.ps1
.\scripts\Set-Privacy.ps1 -DryRun
```

### Ansible (adapter)

```powershell
cd ansible
ansible-galaxy collection install -r requirements.yml
ansible-playbook -i inventories/localhost.yml playbooks/full.yml -e hexsec_windows_dry_run=true
ansible-playbook -i inventories/localhost.yml playbooks/full.yml
```

---

## Install order

1. `privacy`  
2. `base`  
3. `vcredist`  
4. `shell`  
5. `fonts`  
6. `browsers`  
7. `languages`  
8. `databases`  
9. `ides`  
10. `containers`  
11. `cloud-iac`  
12. `cyber`  
13. `productivity`  
14. `media`  
15. `virt`  
16. `gaming`  

Opt-in after core: `cloud-gcp`, `iac-terraform`.

---

## What gets installed

Unless noted as opt-in or manual, the items below are part of the **developer-platform** profile.

### 1. `privacy` — telemetry, Sticky Keys, Recents & Copilot

Configuration hardening (not winget). Source of truth: [`lib/Privacy.ps1`](lib/Privacy.ps1) · [`docs/PRIVACY.md`](docs/PRIVACY.md).

```powershell
.\install.ps1 -Module privacy
.\scripts\Set-Privacy.ps1
```

| Area | Effect |
|------|--------|
| Diagnostic data | `AllowTelemetry = 0` (lowest practical level) |
| Advertising ID / tailored experiences | Off |
| Activity History / location | Off / denied |
| Sticky Keys (and related hotkeys) | Disabled |
| Explorer Recents / frequent folders | Off; Recent folder cleared |
| Microsoft Copilot | Uninstalled + policies to block reinstall |

Sign out or reboot after applying. On Windows 11 Pro, Microsoft may still enforce a minimum diagnostic floor.

### 2. `base` — foundation

| Package | winget ID | Purpose |
|---------|-----------|---------|
| Git for Windows | `Git.Git` | Source control |
| GitHub CLI | `GitHub.cli` | GitHub from the CLI |
| 7-Zip | `7zip.7zip` | Archives |
| WinRAR | `RARLab.WinRAR` | RAR archives |
| Windows Terminal | `Microsoft.WindowsTerminal` | Preferred terminal |
| PowerShell 7 | `Microsoft.PowerShell` | Modern shell |
| Starship | `Starship.Starship` | Primary prompt (Night City) |
| Oh My Posh | `JanDeDobbeleer.OhMyPosh` | Prompt fallback |
| Bitwarden | `Bitwarden.Bitwarden` | Password manager |

### 3. `vcredist` — Visual C++ Redistributables (x64 + x86)

Both architectures are installed. The 2015+ package covers VC++ 14.x including 2015 and 2017 MFC/ATL runtimes.

| Generation | x64 | x86 |
|------------|-----|-----|
| 2008 | `Microsoft.VCRedist.2008.x64` | `Microsoft.VCRedist.2008.x86` |
| 2010 | `Microsoft.VCRedist.2010.x64` | `Microsoft.VCRedist.2010.x86` |
| 2012 | `Microsoft.VCRedist.2012.x64` | `Microsoft.VCRedist.2012.x86` |
| 2013 | `Microsoft.VCRedist.2013.x64` | `Microsoft.VCRedist.2013.x86` |
| 2015+ | `Microsoft.VCRedist.2015+.x64` | `Microsoft.VCRedist.2015+.x86` |

### 4. `shell` — developer CLIs

Day-to-day shell UX is **PowerShell 7 + Starship Night City** + Windows Terminal (module `dotfiles`).
Docs: [docs/dotfiles/](docs/dotfiles/).

| Package | winget ID | Purpose |
|---------|-----------|---------|
| ripgrep | `BurntSushi.ripgrep.MSVC` | Fast code search |
| fd | `sharkdp.fd` | Fast file find |
| jq | `jqlang.jq` | JSON |
| yq | `MikeFarah.yq` | YAML |
| lazygit | `JesseDuffield.lazygit` | Git TUI |
| FFmpeg | `Gyan.FFmpeg` | Media CLI |

### 5. `fonts`

| Package | winget ID |
|---------|-----------|
| JetBrains Mono Nerd Font | `DEVCOM.JetBrainsMonoNerdFont` |
| Meslo LGS Nerd Font | `DEVCOM.MesloLGSNF` |

### 6. `browsers`

| Browser | winget ID |
|---------|-----------|
| Brave | `Brave.Brave` |
| Google Chrome | `Google.Chrome` |
| Firefox | `Mozilla.Firefox` |
| Vivaldi | `Vivaldi.Vivaldi` |

### 7. `languages` — runtimes & build tools

| Package | winget ID |
|---------|-----------|
| Node.js LTS | `OpenJS.NodeJS.LTS` |
| pnpm | `pnpm.pnpm` |
| Python 3.13 | `Python.Python.3.13` |
| uv | `astral-sh.uv` |
| Go | `GoLang.Go` |
| Rustup | `Rustlang.Rustup` |
| .NET Runtime 10 | `Microsoft.DotNet.Runtime.10` |
| ASP.NET Core Runtime 10 | `Microsoft.DotNet.AspNetCore.10` |
| .NET Desktop Runtime 10 | `Microsoft.DotNet.DesktopRuntime.10` |
| .NET SDK 10 | `Microsoft.DotNet.SDK.10` |
| Temurin JDK 25 LTS | `EclipseAdoptium.Temurin.25.JDK` |
| R | `RProject.R` |
| CMake | `Kitware.CMake` |
| Ninja | `Ninja-build.Ninja` |
| LLVM | `LLVM.LLVM` |

### 8. `databases` — WAMP, MongoDB, PostgreSQL, SQLite

| Package | winget ID | Notes |
|---------|-----------|-------|
| WampServer | `Wampserver.Wampserver` | Apache + MySQL + PHP |
| MongoDB Server | `MongoDB.Server` | Document database |
| MongoDB Shell | `MongoDB.Shell` | `mongosh` |
| MongoDB Compass Community | `MongoDB.Compass.Community` | MongoDB GUI |
| PostgreSQL 16 | `PostgreSQL.PostgreSQL.16` | Relational database |
| SQLite | `SQLite.SQLite` | Embedded SQL |

Use **DBeaver** (productivity) for MySQL/PostgreSQL GUIs.

### 9. `ides` — editors & coding CLIs

| Package | winget ID | Notes |
|---------|-----------|-------|
| Cursor | `Anysphere.Cursor` | |
| Visual Studio Code | `Microsoft.VisualStudioCode` | |
| Neovim | `Neovim.Neovim` | |
| Notepad++ | `Notepad++.Notepad++` | |
| Code::Blocks | `Codeblocks.Codeblocks` | |
| RStudio | `Posit.RStudio` | |
| Claude Code | `Anthropic.ClaudeCode` | User-scope (unelevated); native installer fallback |
| Codex | `OpenAI.Codex` | User-scope (unelevated); `npm i -g @openai/codex` fallback |

Claude Code and Codex are installed for the **interactive user**, not machine-wide as Administrator (official docs: do not require Admin; portable/user CLIs fail or vanish when forced elevated).

### 10. `containers` — Docker & Kubernetes

Docker Desktop on this profile is **Windows-only**: do not enable the WSL2 backend. Use **Hyper-V** / Windows containers as supported by your Docker Desktop edition.

| Package | winget ID |
|---------|-----------|
| Docker Desktop | `Docker.DockerDesktop` |
| kubectl | `Kubernetes.kubectl` |
| Helm | `Helm.Helm` |
| k9s | `Derailed.k9s` |
| kind | `Kubernetes.kind` |
| OpenLens | `MuhammedKalkan.OpenLens` |
| lazydocker | `JesseDuffield.lazydocker` |
| dive | `wagoodman.dive` |

### 11. `cloud-iac` — cloud CLIs & Infrastructure as Code

| Package | ID |
|---------|-----|
| AWS CLI | `Amazon.AWSCLI` |
| Azure CLI | `Microsoft.AzureCLI` |
| DigitalOcean CLI | `DigitalOcean.Doctl` |
| cloudflared | `Cloudflare.cloudflared` |
| OpenTofu | `OpenTofu.Tofu` |
| Packer | `Hashicorp.Packer` |
| terraform-docs | `terraform-docs.terraform-docs` |
| tflint | `tflint.tflint` |
| direnv | `direnv.direnv` |
| checkov | `pip:checkov` |
| pre-commit | `pip:pre-commit` |
| Ansible | `pip:ansible` |
| ansible-lint | `pip:ansible-lint` |
| yamllint | `pip:yamllint` |

`pip:*` entries require the **languages** module first (`uv` preferred, else `python` on `PATH`).
Even when the installer runs **as Administrator**, these tools are installed **unelevated** into the interactive user profile (`uv tool install`, or `pip install --user`) so they do not touch the admin/system Python environment.

#### Opt-in

| Module | Package | Flag |
|--------|---------|------|
| `cloud-gcp` | `Google.CloudSDK` | `-WithGcp` |
| `iac-terraform` | `Hashicorp.Terraform` | `-WithTerraform` |

### 12. `cyber` — AppSec / network tooling

| Package | winget ID |
|---------|-----------|
| Wireshark | `WiresharkFoundation.Wireshark` |
| Nmap | `Insecure.Nmap` |
| Trivy | `AquaSecurity.Trivy` |
| gitleaks | `gitleaks.gitleaks` |
| Burp Suite Community | `PortSwigger.BurpSuiteCommunity` |
| mitmproxy | `mitmproxy.mitmproxy` |

### 13. `productivity`

| Package | winget ID |
|---------|-----------|
| Obsidian | `Obsidian.Obsidian` |
| draw.io | `JGraph.Draw` |
| DBeaver Community | `DBeaver.DBeaver.Community` |
| Discord | `Discord.Discord` |
| AnyDesk | `AnyDeskSoftwareGmbH.AnyDesk` |
| Proton Pass | `Proton.ProtonPass` |
| Proton VPN | `ProtonVPN.ProtonVPN` |
| Lightshot | `Skillbrains.Lightshot` |

**Manual (not automated):**

| Tool | Notes |
|------|-------|
| Microsoft Office / Microsoft 365 | Install with your Microsoft or company license |
| Yaak | Optional API client — [yaak.app](https://yaak.app) |

### 14. `media`

| Package | winget ID |
|---------|-----------|
| VLC | `VideoLAN.VLC` |
| K-Lite Codec Pack Mega | `CodecGuide.K-LiteCodecPack.Mega` |
| OBS Studio | `OBSProject.OBSStudio` |
| Spotify | `Spotify.Spotify` |
| Audacity | `Audacity.Audacity` |
| OpenShot | `OpenShot.OpenShot` |

### 15. `virt`

| Package | winget ID |
|---------|-----------|
| VirtualBox | `Oracle.VirtualBox` |

### 16. `gaming`

| Package | winget ID |
|---------|-----------|
| Steam | `Valve.Steam` |
| RetroArch | `Libretro.RetroArch` |

---

## Directory structure

```
hexsec-windows/
├── install.ps1
├── lib/
│   ├── Common.ps1
│   ├── Privacy.ps1
│   └── Dotfiles.ps1
├── configs/
│   ├── packages/
│   ├── dotfiles/               ← Starship + pwsh profile + Windows Terminal Night City
│   └── profiles/developer-platform.yml
├── scripts/                    ← Install-*.ps1 wrappers (incl. Install-Dotfiles.ps1)
├── ansible/
├── docs/
│   ├── MODULES.md
│   ├── PRIVACY.md
│   ├── modules/dotfiles.md
│   └── dotfiles/
└── tests/test-structure.sh
```

---

## Post-install checklist

1. **Sign out or reboot** after privacy, Docker Desktop, or VirtualBox changes.
2. **Shell** — module `dotfiles` deploys PowerShell 7 + Starship Night City automatically:

   ```powershell
   .\install.ps1 -Module base,fonts,dotfiles
   pwsh
   ```

   Docs: [docs/dotfiles/](docs/dotfiles/). Windows Terminal gets the Night City scheme automatically (Ghostty-aligned).

3. Confirm key tools:

   ```powershell
   git --version; gh --version; node -v; python --version; uv --version
   go version; rustc --version; java -version; dotnet --list-sdks
   docker version; kubectl version --client; tofu version; starship --version
   mongosh --version; psql --version
   ```

4. Start **WampServer** when you need Apache/MySQL/PHP. Confirm MongoDB and PostgreSQL services if applicable.
5. Sign in to Bitwarden, Steam, browsers, and IDEs as needed.
6. Install **Microsoft Office** and **Yaak** manually if you use them.
7. In Docker Desktop settings, keep the **WSL 2 based engine** disabled — this profile is Windows / Hyper-V only.

---

## Customization

- Edit `configs/packages/<module>.txt` to add or remove winget IDs.  
- Prefix `pip:package` only when winget has no suitable package.  
- Lines starting with `#` are comments.  
- Re-run `.\install.ps1 -Module <name>` — already-installed winget packages are treated as success.

---

## Troubleshooting

| Issue | Fix |
|-------|-----|
| `winget` not found | Install/update **App Installer** from the Microsoft Store |
| Access denied | Run PowerShell **as Administrator** |
| Docker engine will not start | Enable virtualization + Hyper-V; do not rely on WSL; reboot |
| `pip:*` skipped | Install `languages` first so `uv` or `python` is on `PATH` |
| Claude Code / Codex missing after full install | Re-run `.\install.ps1 -Module ides` (1.0.4+ installs them unelevated). Open a **new** terminal and run `claude --version` / `codex --version` |
| Package ID not found | Run `winget search <name>` and update the `.txt` file |
| Execution policy | `Set-ExecutionPolicy -Scope Process Bypass -Force` |
| Copilot or Recents return after upgrade | Re-run `.\install.ps1 -Module privacy` |

---

## Versioning

This project follows [Semantic Versioning](https://semver.org/): **MAJOR.MINOR.PATCH**.  
See [CHANGELOG.md](CHANGELOG.md) for release notes.

---

## License

MIT — **Copyright © ThorHexSec** — see [LICENSE](LICENSE) and [AUTHORS](AUTHORS).
