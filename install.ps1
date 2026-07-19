#Requires -Version 5.1
<#
.SYNOPSIS
  HexSec Windows installer — full profile or modular modules.

.DESCRIPTION
  Entrypoint for Windows 11 Pro (HexSec Windows 1.1.1).
  Installs curated development tooling via winget (primary), with pip/uv only
  when a package has no suitable winget ID. pip:* and user-scope CLIs (Claude Code,
  Codex) always run unelevated. Docker Desktop is Windows-only (Hyper-V) — WSL is not used.
  Full run: .\install.ps1  (or .\scripts\Install-All.ps1).
  Dotfiles: PowerShell 7 + Oh My Posh + Windows Terminal Night City (Ghostty-aligned).
#>
[CmdletBinding()]
param(
    [ValidateSet(
        "privacy", "base", "vcredist", "shell", "fonts", "browsers", "languages", "databases", "ides",
        "containers", "cloud-iac", "cloud-gcp", "iac-terraform",
        "cyber", "productivity", "media", "virt", "gaming", "dotfiles", "all"
    )]
    [string[]]$Module = @(),

    [string]$Profile = "developer-platform",

    [switch]$List,
    [switch]$DryRun,
    [switch]$SkipAdminCheck,
    [switch]$WithGcp,
    [switch]$WithTerraform
)

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\lib\Common.ps1"
. "$PSScriptRoot\lib\Privacy.ps1"
. "$PSScriptRoot\lib\Dotfiles.ps1"

$CoreOrder = @(
    "privacy", "base", "vcredist", "shell", "fonts", "browsers", "languages", "databases", "ides",
    "containers", "cloud-iac", "cyber", "productivity", "media", "virt", "gaming", "dotfiles"
)

function Show-HexSecModules {
    Write-Host @"

HexSec Windows v$script:HexSecWinVersion — modules

  CORE (developer-platform):
    privacy       Telemetry ↓ · Sticky Keys off · Explorer Recents off · Copilot uninstall
    base          Git, GitHub CLI, 7-Zip, WinRAR, Windows Terminal, PowerShell 7, Oh My Posh, Bitwarden
    vcredist      VC++ Redistributables x64+x86 (2008, 2010, 2012, 2013, 2015+/2017 MFC·ATL)
    shell         ripgrep, fd, jq, yq, lazygit, FFmpeg
    fonts         JetBrains Mono Nerd + Meslo Nerd
    browsers      Brave, Chrome, Firefox, Vivaldi
    languages     Node LTS, pnpm, Python, uv, Go, Rust, .NET 10, JDK 25 LTS, R, CMake/Ninja/LLVM
    databases     WampServer, MongoDB + Shell + Compass, PostgreSQL 16, SQLite
    ides          Cursor, VS Code, Neovim, Notepad++, Code::Blocks, RStudio, Claude Code, Codex
    containers    Docker Desktop (Windows-only / Hyper-V — no WSL), kubectl, helm, k9s, kind, OpenLens, …
    cloud-iac     AWS CLI, Azure CLI, doctl, cloudflared, OpenTofu, Packer, checkov, Ansible (pip)
    cyber         Wireshark, nmap, Trivy, gitleaks, Burp Community, mitmproxy
    productivity  Obsidian, draw.io, DBeaver, Discord, AnyDesk, Proton Pass, Proton VPN, Lightshot
    media         OBS Studio, Spotify, Audacity, OpenShot
    virt          VirtualBox
    gaming        Steam, RetroArch
    dotfiles      PowerShell 7 + Oh My Posh + Windows Terminal Night City (0xH3xS3C)

  OPT-IN:
    cloud-gcp       Google Cloud SDK (large)
    iac-terraform   HashiCorp Terraform (OpenTofu is default)

  FULL:
    all             every CORE module in order

Examples:
  .\install.ps1 -DryRun
  .\install.ps1 -Module base,shell,fonts,dotfiles
  .\install.ps1 -WithGcp -WithTerraform

"@
}
if ($List) {
    Show-HexSecModules
    exit 0
}

if ($DryRun) { Set-HexSecDryRun -Enabled $true }

if (-not $SkipAdminCheck) {
    Assert-HexSecAdmin
}

$toInstall = [System.Collections.Generic.List[string]]::new()

if ($Module.Count -eq 0 -or ($Module.Count -eq 1 -and $Module[0] -eq "all")) {
    foreach ($m in $CoreOrder) { [void]$toInstall.Add($m) }
}
elseif ($Module -contains "all") {
    foreach ($m in $CoreOrder) { [void]$toInstall.Add($m) }
}
else {
    foreach ($m in $Module) {
        if ($m -eq "all") { continue }
        [void]$toInstall.Add($m)
    }
}

if ($WithGcp -and -not $toInstall.Contains("cloud-gcp")) {
    [void]$toInstall.Add("cloud-gcp")
}
if ($WithTerraform -and -not $toInstall.Contains("iac-terraform")) {
    [void]$toInstall.Add("iac-terraform")
}

$needsWinget = @($toInstall | Where-Object { $_ -notin @('privacy', 'dotfiles') }).Count -gt 0
if ($needsWinget) {
    Assert-HexSecWinget
}

Write-HexSecInfo "Profile: $Profile"
Write-HexSecInfo "Modules: $($toInstall -join ', ')"
if ($DryRun) { Write-HexSecWarn "DRY-RUN — no changes will be applied" }

foreach ($m in $toInstall) {
    if ($m -eq "privacy") {
        Invoke-HexSecPrivacyHardening
    }
    elseif ($m -eq "dotfiles") {
        Install-HexSecDotfiles
    }
    else {
        Install-HexSecPackageList -Name $m
    }
}

Write-HexSecOk "Done. Open a new pwsh session for Oh My Posh. See README.md / docs/dotfiles/."
