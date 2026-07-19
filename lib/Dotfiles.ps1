# HexSec Windows — deploy PowerShell 7 profile + Oh My Posh + Windows Terminal Night City
#Requires -Version 5.1
Set-StrictMode -Version Latest

function Get-HexSecDotfilesSourceDir {
    Join-Path $script:HexSecWinRoot "configs\dotfiles"
}

function Get-HexSecPwshDocumentsDir {
    # PowerShell 7 profile lives under Documents\PowerShell for the current user.
    Join-Path ([Environment]::GetFolderPath('MyDocuments')) 'PowerShell'
}

function Backup-HexSecFile {
    param([Parameter(Mandatory)][string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return }
    $stamp = Get-Date -Format 'yyyyMMdd_HHmmss'
    $backup = "$Path.bak_$stamp"
    Copy-Item -LiteralPath $Path -Destination $backup -Force
    Write-HexSecInfo "Backup: $backup"
}

function Install-HexSecFileIfChanged {
    param(
        [Parameter(Mandatory)][string]$Source,
        [Parameter(Mandatory)][string]$Destination
    )
    if (-not (Test-Path -LiteralPath $Source)) {
        Write-HexSecWarn "Missing source: $Source"
        return $false
    }
    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] install $Source → $Destination"
        return $true
    }
    $dir = Split-Path -Parent $Destination
    if (-not (Test-Path -LiteralPath $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if ((Test-Path -LiteralPath $Destination) -and
        ((Get-FileHash -LiteralPath $Source).Hash -eq (Get-FileHash -LiteralPath $Destination).Hash)) {
        Write-HexSecOk "unchanged: $Destination"
        return $true
    }
    Backup-HexSecFile -Path $Destination
    Copy-Item -LiteralPath $Source -Destination $Destination -Force
    Write-HexSecOk "installed: $Destination"
    return $true
}

function Set-HexSecExecutionPolicyCurrentUser {
    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] Set-ExecutionPolicy RemoteSigned -Scope CurrentUser"
        return
    }
    try {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force -ErrorAction Stop
        Write-HexSecOk "ExecutionPolicy CurrentUser = RemoteSigned"
    }
    catch {
        Write-HexSecWarn "Could not set ExecutionPolicy: $($_.Exception.Message)"
    }
}

function Get-HexSecWindowsTerminalSettingsPaths {
    @(
        (Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json')
        (Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json')
    )
}

function ConvertFrom-HexSecJsonc {
    param([Parameter(Mandatory)][string]$Text)
    # Strip /* */ then // line comments (Windows Terminal settings.json is JSONC).
    $noBlock = [regex]::Replace($Text, '/\*[\s\S]*?\*/', '')
    $noLine = [regex]::Replace($noBlock, '(?m)^\s*//.*?$', '')
    $noInline = [regex]::Replace($noLine, '(?<=[,\[\{])\s*//[^\r\n]*', '')
    return ($noInline | ConvertFrom-Json -ErrorAction Stop)
}

function Get-HexSecNightCityProfileDefaults {
    [pscustomobject]@{
        colorScheme = 'Night City'
        opacity     = 86
        useAcrylic  = $true
        cursorColor = '#00F0FF'
        font        = [pscustomobject]@{
            face     = 'JetBrainsMono Nerd Font'
            size     = 13
            features = [pscustomobject]@{
                calt = -1
                liga = -1
                dlig = -1
            }
        }
    }
}

function Install-HexSecWindowsTerminalFragment {
    param([Parameter(Mandatory)][string]$FragmentSource)
    $fragDir = Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\Fragments\HexSec'
    $fragDst = Join-Path $fragDir 'night-city.json'
    Install-HexSecFileIfChanged -Source $FragmentSource -Destination $fragDst | Out-Null
}

function Merge-HexSecWindowsTerminalSettings {
    <#
    .SYNOPSIS
      Upserts Night City color scheme and profile defaults into Windows Terminal settings.json.
      Aligned with HexSec macOS Ghostty (opacity 0.86, JetBrainsMono Nerd, Night City palette).
    #>
    param([Parameter(Mandatory)][string]$SchemeSource)

    if (-not (Test-Path -LiteralPath $SchemeSource)) {
        Write-HexSecWarn "Missing Windows Terminal scheme: $SchemeSource"
        return
    }

    $scheme = Get-Content -LiteralPath $SchemeSource -Raw -Encoding UTF8 | ConvertFrom-Json
    $defaults = Get-HexSecNightCityProfileDefaults
    $paths = Get-HexSecWindowsTerminalSettingsPaths
    $existing = @($paths | Where-Object { Test-Path -LiteralPath $_ })
    if ($existing.Count -eq 0) {
        # Prefer Store package path when present; otherwise unpackaged winget path.
        $pkgDir = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState'
        $target = if (Test-Path -LiteralPath $pkgDir) {
            Join-Path $pkgDir 'settings.json'
        }
        else {
            Join-Path $env:LOCALAPPDATA 'Microsoft\Windows Terminal\settings.json'
        }
        $existing = @($target)
    }

    foreach ($settingsPath in $existing) {
        if ($script:HexSecWinDryRun) {
            Write-HexSecInfo "[dry-run] merge Night City into $settingsPath"
            continue
        }

        $dir = Split-Path -Parent $settingsPath
        if (-not (Test-Path -LiteralPath $dir)) {
            New-Item -ItemType Directory -Path $dir -Force | Out-Null
        }

        $root = $null
        if (Test-Path -LiteralPath $settingsPath) {
            try {
                $raw = Get-Content -LiteralPath $settingsPath -Raw -Encoding UTF8
                if ([string]::IsNullOrWhiteSpace($raw)) {
                    $root = [pscustomobject]@{}
                }
                else {
                    $root = ConvertFrom-HexSecJsonc -Text $raw
                }
            }
            catch {
                Write-HexSecWarn "Could not parse $settingsPath — scheme still available via Fragments. $($_.Exception.Message)"
                continue
            }
            Backup-HexSecFile -Path $settingsPath
        }
        else {
            $root = [pscustomobject]@{
                '$help'   = 'https://aka.ms/terminal-documentation'
                '$schema' = 'https://aka.ms/terminal-profiles-schema'
            }
        }

        # Ensure schemes array and upsert Night City
        if (-not ($root.PSObject.Properties.Name -contains 'schemes') -or $null -eq $root.schemes) {
            $root | Add-Member -NotePropertyName schemes -NotePropertyValue @() -Force
        }
        $schemes = [System.Collections.Generic.List[object]]::new()
        foreach ($s in @($root.schemes)) {
            if ($null -eq $s) { continue }
            if ($s.name -eq 'Night City') { continue }
            $schemes.Add($s)
        }
        $schemes.Add($scheme)
        $root.schemes = $schemes.ToArray()

        # Ensure profiles.defaults
        if (-not ($root.PSObject.Properties.Name -contains 'profiles') -or $null -eq $root.profiles) {
            $root | Add-Member -NotePropertyName profiles -NotePropertyValue ([pscustomobject]@{
                    defaults = $defaults
                    list     = @()
                }) -Force
        }
        else {
            $profiles = $root.profiles
            # profiles may be an array (legacy) — wrap into object
            if ($profiles -is [System.Array]) {
                $root.profiles = [pscustomobject]@{
                    defaults = $defaults
                    list     = $profiles
                }
            }
            else {
                if (-not ($profiles.PSObject.Properties.Name -contains 'defaults') -or $null -eq $profiles.defaults) {
                    $profiles | Add-Member -NotePropertyName defaults -NotePropertyValue $defaults -Force
                }
                else {
                    $d = $profiles.defaults
                    $d | Add-Member -NotePropertyName colorScheme -NotePropertyValue 'Night City' -Force
                    $d | Add-Member -NotePropertyName opacity -NotePropertyValue 86 -Force
                    $d | Add-Member -NotePropertyName useAcrylic -NotePropertyValue $true -Force
                    $d | Add-Member -NotePropertyName cursorColor -NotePropertyValue '#00F0FF' -Force
                    $d | Add-Member -NotePropertyName font -NotePropertyValue $defaults.font -Force
                }
                if (-not ($profiles.PSObject.Properties.Name -contains 'list') -or $null -eq $profiles.list) {
                    $profiles | Add-Member -NotePropertyName list -NotePropertyValue @() -Force
                }
            }
        }

        $json = $root | ConvertTo-Json -Depth 20
        Set-Content -LiteralPath $settingsPath -Value $json -Encoding UTF8
        Write-HexSecOk "Windows Terminal Night City applied: $settingsPath"
    }
}

function Install-HexSecDotfiles {
    <#
    .SYNOPSIS
      Deploys Oh My Posh Night City theme, PowerShell 7 profile, and Windows Terminal colors
      aligned with HexSec macOS Ghostty.
    #>
    Write-HexSecInfo "=== Module: dotfiles ==="

    $src = Get-HexSecDotfilesSourceDir
    $themeSrc = Join-Path $src 'night-city.omp.json'
    $profileSrc = Join-Path $src 'Microsoft.PowerShell_profile.ps1'
    $wtSchemeSrc = Join-Path $src 'windows-terminal-night-city.json'
    $wtFragmentSrc = Join-Path $src 'windows-terminal-fragment.json'

    $hexsecRoot = Join-Path $env:USERPROFILE '.config\hexsec'
    $themeDst = Join-Path $hexsecRoot 'oh-my-posh\night-city.omp.json'
    $wtSchemeDst = Join-Path $hexsecRoot 'windows-terminal\night-city.json'

    $docsPs = Get-HexSecPwshDocumentsDir
    $profileDst = Join-Path $docsPs 'Microsoft.PowerShell_profile.ps1'
    $themeCopyInDocs = Join-Path $docsPs 'Themes\night-city.omp.json'

    Install-HexSecFileIfChanged -Source $themeSrc -Destination $themeDst | Out-Null
    Install-HexSecFileIfChanged -Source $themeSrc -Destination $themeCopyInDocs | Out-Null
    Install-HexSecFileIfChanged -Source $profileSrc -Destination $profileDst | Out-Null
    Install-HexSecFileIfChanged -Source $wtSchemeSrc -Destination $wtSchemeDst | Out-Null

    # Also deploy AllHosts profile path used by some hosts
    $allHosts = Join-Path $docsPs 'Profile.ps1'
    if (-not $script:HexSecWinDryRun) {
        if (-not (Test-Path -LiteralPath $allHosts)) {
            Install-HexSecFileIfChanged -Source $profileSrc -Destination $allHosts | Out-Null
        }
        elseif ((Get-FileHash -LiteralPath $profileSrc).Hash -ne (Get-FileHash -LiteralPath $allHosts).Hash) {
            # Keep AllHosts in sync when it was previously managed by HexSec (contains HEXSEC_IDENTITY)
            $existing = Get-Content -LiteralPath $allHosts -Raw -ErrorAction SilentlyContinue
            if ($existing -match 'HEXSEC_IDENTITY') {
                Install-HexSecFileIfChanged -Source $profileSrc -Destination $allHosts | Out-Null
            }
        }
    }
    else {
        Write-HexSecInfo "[dry-run] would sync Profile.ps1 when HexSec-managed"
    }

    Install-HexSecWindowsTerminalFragment -FragmentSource $wtFragmentSrc
    Merge-HexSecWindowsTerminalSettings -SchemeSource $wtSchemeSrc

    Set-HexSecExecutionPolicyCurrentUser

    if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue) -and -not $script:HexSecWinDryRun) {
        Write-HexSecWarn "oh-my-posh not on PATH yet — install base module and open a new terminal"
    }
    if (-not (Get-Command pwsh -ErrorAction SilentlyContinue) -and -not $script:HexSecWinDryRun) {
        Write-HexSecWarn "pwsh not on PATH yet — install base module (Microsoft.PowerShell)"
    }

    Write-HexSecOk "Dotfiles deployed (PowerShell 7 · Oh My Posh · Windows Terminal Night City)"
    Write-HexSecInfo "Restart Windows Terminal to load the Night City theme (Ghostty-aligned)."
}
