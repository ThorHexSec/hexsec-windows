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

$script:HexSecWinVersion = "1.0.3"
$script:HexSecWinDryRun = $false

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

    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] winget install --id $Id -e --accept-package-agreements --accept-source-agreements"
        return
    }

    Write-HexSecInfo "Installing $Id …"
    $args = @(
        "install", "--id", $Id, "-e", "--accept-package-agreements",
        "--accept-source-agreements", "--disable-interactivity"
    )
    if ($Source) {
        $args += @("--source", $Source)
    }

    & winget @args
    $code = $LASTEXITCODE
    # 0 = success, -1978335189 (0x8A15002B) = already installed
    if ($code -eq 0 -or $code -eq -1978335189) {
        Write-HexSecOk "$Id"
        return
    }
    Write-HexSecWarn "winget exit $code for $Id (continuing)"
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
