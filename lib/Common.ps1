# HexSec Windows — shared helpers (winget + pip fallback, idempotent, dry-run aware)
#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$script:HexSecWinRoot = Split-Path -Parent (Split-Path -Parent $PSCommandPath)
if (-not (Test-Path (Join-Path $script:HexSecWinRoot "configs"))) {
    $script:HexSecWinRoot = Split-Path -Parent $PSCommandPath
    if (-not (Test-Path (Join-Path $script:HexSecWinRoot "configs"))) {
        $script:HexSecWinRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    }
}

$script:HexSecWinVersion = "1.2.1"
$script:HexSecWinDryRun = $false

# Apps that must install into the interactive user profile (not elevated / not machine-wide).
$script:HexSecUserScopeWingetIds = @(
    "Anthropic.ClaudeCode",
    "OpenAI.Codex",
    "Spotify.Spotify",
    "Yaak.app"
)

# Do not pass --scope machine — forces reinstall/uninstall when an existing
# user-scope copy is present (notably Microsoft.PowerShell).
$script:HexSecNoMachineScopeWingetIds = @(
    "Microsoft.PowerShell",
    "Microsoft.WindowsApp",
    "Spotify.Spotify",
    "Yaak.app"
)

function Write-HexSecInfo {
    param([string]$Message)
    Write-Host "[hexsec-windows] $Message" -ForegroundColor Cyan
}

function Write-HexSecWarn {
    param([string]$Message)
    Write-Host "[hexsec-windows] WARN: $Message" -ForegroundColor Yellow
}

function Write-HexSecOk {
    param([string]$Message)
    Write-Host "[hexsec-windows] OK: $Message" -ForegroundColor Green
}

function Set-HexSecDryRun {
    param([bool]$Enabled)
    $script:HexSecWinDryRun = $Enabled
}

function Get-HexSecPackagesDir {
    Join-Path $script:HexSecWinRoot "configs\packages"
}

function Get-HexSecProfilesDir {
    Join-Path $script:HexSecWinRoot "configs\profiles"
}

function Test-HexSecAdmin {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $p = New-Object Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Assert-HexSecAdmin {
    if (-not (Test-HexSecAdmin)) {
        throw "Administrator privileges are required. Re-run PowerShell as Administrator."
    }
}

function Assert-HexSecWinget {
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        throw "winget was not found. Install App Installer from the Microsoft Store, then retry."
    }
}

function Read-HexSecPackageList {
    <#
    .SYNOPSIS
      Reads configs/packages/<name>.txt — one winget ID (or pip:pkg) per line.
      Lines starting with # and blank lines are ignored.
    #>
    param(
        [Parameter(Mandatory)][string]$Name
    )
    $path = Join-Path (Get-HexSecPackagesDir) "$Name.txt"
    if (-not (Test-Path $path)) {
        throw "Package list not found: $path"
    }
    Get-Content -Path $path -Encoding UTF8 |
        ForEach-Object { ($_ -split '#', 2)[0].Trim() } |
        Where-Object { $_ -ne "" }
}

function Test-HexSecWingetPackageInstalled {
    <#
    .SYNOPSIS
      Returns $true when winget already has the exact package ID installed.
      Also treats Microsoft.PowerShell as installed when pwsh is on PATH.
    #>
    param([Parameter(Mandatory)][string]$Id)

    if ($Id -eq "Microsoft.PowerShell") {
        if (Get-Command pwsh -ErrorAction SilentlyContinue) {
            return $true
        }
    }

    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        return $false
    }

    $prev = $ErrorActionPreference
    $ErrorActionPreference = "Continue"
    try {
        $raw = & winget list --id $Id -e --disable-interactivity --accept-source-agreements 2>&1 | Out-String
        $code = $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $prev
    }

    if ($raw -match '(?i)No installed package found') {
        return $false
    }
    # winget list prints a table; require the exact ID on a data line
    if ($code -eq 0 -and ($raw -match ("(?m)^\s*" + [regex]::Escape($Id) + "\b") -or $raw -match ("\s" + [regex]::Escape($Id) + "\s"))) {
        return $true
    }
    return $false
}

function Test-HexSecWingetSuccess {
    param([int]$Code)
    # 0 success
    # -1978335189 (0x8A15002B) already installed
    # -1978335135 (0x8A150061) no applicable upgrade / no newer version
    # -1978335212 (0x8A150014) no packages found matching (treat via list check separately)
    return ($Code -eq 0 -or $Code -eq -1978335189 -or $Code -eq -1978335135)
}

function Install-HexSecWingetPackage {
    param(
        [Parameter(Mandatory)][string]$Id,
        [string]$Source = "winget"
    )

    if ($Id -like "pip:*") {
        $pipPkg = $Id.Substring(4)
        Install-HexSecPipPackage -Name $pipPkg
        return
    }

    if ($script:HexSecUserScopeWingetIds -contains $Id) {
        Install-HexSecUserScopeCli -Id $Id
        return
    }

    if ($script:HexSecWinDryRun) {
        if (Test-HexSecWingetPackageInstalled -Id $Id) {
            Write-HexSecInfo "[dry-run] skip $Id (already installed)"
        }
        else {
            Write-HexSecInfo "[dry-run] winget install --id $Id -e --accept-package-agreements --accept-source-agreements"
        }
        return
    }

    # Idempotent: never reinstall / never force scope changes that uninstall existing copies
    if (Test-HexSecWingetPackageInstalled -Id $Id) {
        Write-HexSecOk "$Id (already installed — skipped)"
        return
    }

    Write-HexSecInfo "Installing $Id …"
    $args = @(
        "install", "--id", $Id, "-e", "--accept-package-agreements",
        "--accept-source-agreements", "--disable-interactivity"
    )
    # Avoid --scope machine for packages that uninstall/reinstall when scope differs
    # (notably Microsoft.PowerShell). Let winget use the package default.
    if ((Test-HexSecAdmin) -and ($script:HexSecNoMachineScopeWingetIds -notcontains $Id)) {
        $args += @("--scope", "machine")
    }
    if ($Source) {
        $args += @("--source", $Source)
    }

    & winget @args
    $code = $LASTEXITCODE
    if (Test-HexSecWingetSuccess -Code $code) {
        Write-HexSecOk "$Id"
        return
    }
    # Race: installed between list and install
    if (Test-HexSecWingetPackageInstalled -Id $Id) {
        Write-HexSecOk "$Id (already installed — skipped)"
        return
    }
    Write-HexSecWarn "winget exit $code for $Id (continuing)"
}

function Install-HexSecUserScopeCli {
    <#
    .SYNOPSIS
      Install user-scoped apps (Claude Code, Codex, Spotify, Yaak) unelevated.
      Winget as Administrator often skips, fails, or misplaces these packages.
    #>
    param([Parameter(Mandatory)][string]$Id)

    if ($script:HexSecWinDryRun) {
        if (Test-HexSecWingetPackageInstalled -Id $Id) {
            Write-HexSecInfo "[dry-run] skip $Id (already installed)"
        }
        else {
            Write-HexSecInfo "[dry-run] (unelevated, --scope user) winget install --id $Id"
            if ($Id -eq "Anthropic.ClaudeCode") {
                Write-HexSecInfo "[dry-run] fallback: irm https://claude.ai/install.ps1 | iex"
            }
            elseif ($Id -eq "OpenAI.Codex") {
                Write-HexSecInfo "[dry-run] fallback: npm install -g @openai/codex"
            }
        }
        return
    }

    if (Test-HexSecWingetPackageInstalled -Id $Id) {
        Write-HexSecOk "$Id (already installed — skipped)"
        return
    }

    Write-HexSecInfo "$Id — installing for interactive user (unelevated, --scope user) …"

    $wingetSnippet = @"
`$ErrorActionPreference = 'Continue'
winget install --id '$Id' -e --scope user --accept-package-agreements --accept-source-agreements --disable-interactivity --source winget
exit `$LASTEXITCODE
"@
    $code = Invoke-HexSecUnelevatedScript -Content $wingetSnippet
    if (Test-HexSecWingetSuccess -Code $code) {
        Write-HexSecOk "$Id (user scope)"
        return
    }
    if (Test-HexSecWingetPackageInstalled -Id $Id) {
        Write-HexSecOk "$Id (already installed — skipped)"
        return
    }

    Write-HexSecWarn "winget user-scope exit $code for $Id — trying official fallback …"

    if ($Id -eq "Anthropic.ClaudeCode") {
        $fb = @"
`$ErrorActionPreference = 'Stop'
irm https://claude.ai/install.ps1 | iex
exit 0
"@
        $fbCode = Invoke-HexSecUnelevatedScript -Content $fb
        if ($fbCode -eq 0) {
            Write-HexSecOk "Anthropic.ClaudeCode (native installer)"
            return
        }
        Write-HexSecWarn "Claude Code native installer exited $fbCode (continuing)"
        return
    }

    if ($Id -eq "OpenAI.Codex") {
        $fb = @"
`$ErrorActionPreference = 'Stop'
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host 'npm not found — install languages module first'
    exit 1
}
npm install -g '@openai/codex'
exit `$LASTEXITCODE
"@
        $fbCode = Invoke-HexSecUnelevatedScript -Content $fb
        if ($fbCode -eq 0) {
            Write-HexSecOk "OpenAI.Codex (npm @openai/codex)"
            return
        }
        Write-HexSecWarn "Codex npm fallback exited $fbCode (continuing)"
        return
    }

    Write-HexSecWarn "No fallback for $Id (continuing)"
}

function Install-HexSecPackageList {
    param(
        [Parameter(Mandatory)][string]$Name
    )
    Write-HexSecInfo "=== Module: $Name ==="
    $pkgs = Read-HexSecPackageList -Name $Name
    foreach ($pkg in $pkgs) {
        Install-HexSecWingetPackage -Id $pkg
    }
}

function Invoke-HexSecUnelevatedScript {
    <#
    .SYNOPSIS
      Runs a PowerShell snippet at medium integrity (not elevated).
      Full installs run as Administrator for winget/privacy; pip/uv must not.
    #>
    param(
        [Parameter(Mandatory)][string]$Content
    )
    $temp = Join-Path $env:TEMP ("hexsec-unelevated-{0}.ps1" -f [guid]::NewGuid().ToString("N"))
    Set-Content -Path $temp -Value $Content -Encoding UTF8
    try {
        if (-not (Test-HexSecAdmin)) {
            $p = Start-Process -FilePath "powershell.exe" -ArgumentList @(
                "-NoProfile", "-ExecutionPolicy", "Bypass", "-File", $temp
            ) -Wait -PassThru -NoNewWindow
            return $p.ExitCode
        }

        # Same user, drop UAC elevation (medium integrity). Avoids admin pip/site-packages issues.
        $inner = "powershell.exe -NoProfile -ExecutionPolicy Bypass -File `"$temp`""
        $p = Start-Process -FilePath "runas.exe" -ArgumentList @(
            "/trustlevel:0x20000", $inner
        ) -Wait -PassThru -NoNewWindow
        return $p.ExitCode
    }
    finally {
        Remove-Item -LiteralPath $temp -Force -ErrorAction SilentlyContinue
    }
}

function Install-HexSecPipPackage {
    <#
    .SYNOPSIS
      Installs a PyPI CLI tool into the interactive user profile — never as Administrator.
      Prefers `uv tool install` (languages module); falls back to `python -m pip install --user`.
    #>
    param([Parameter(Mandatory)][string]$Name)

    $hasUv = [bool](Get-Command uv -ErrorAction SilentlyContinue)
    $hasPy = [bool](Get-Command python -ErrorAction SilentlyContinue)
    if (-not $hasUv -and -not $hasPy) {
        Write-HexSecWarn "python/uv not found — skip pip:$Name (install languages module first)"
        return
    }

    if ($script:HexSecWinDryRun) {
        if ($hasUv) {
            Write-HexSecInfo "[dry-run] (unelevated) uv tool install $Name"
        }
        else {
            Write-HexSecInfo "[dry-run] (unelevated) python -m pip install --user $Name"
        }
        return
    }

    Write-HexSecInfo "pip:$Name — installing for interactive user (unelevated, not as Administrator) …"

    if ($hasUv) {
        $snippet = @"
`$ErrorActionPreference = 'Stop'
uv tool install --force '$Name'
exit `$LASTEXITCODE
"@
    }
    else {
        $snippet = @"
`$ErrorActionPreference = 'Stop'
python -m pip install --user '$Name'
exit `$LASTEXITCODE
"@
    }

    $code = Invoke-HexSecUnelevatedScript -Content $snippet
    if ($code -eq 0) {
        Write-HexSecOk "pip:$Name (user scope)"
        return
    }
    Write-HexSecWarn "pip:$Name exited $code (continuing)"
}
