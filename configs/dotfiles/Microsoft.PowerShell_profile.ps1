# HexSec Windows — PowerShell 7 profile (0xH3xS3C / Night City)
# Deployed to: Documents\PowerShell\Microsoft.PowerShell_profile.ps1
# Requires: PowerShell 7, Oh My Posh, JetBrains Mono Nerd Font

# ---------------------------------------------------------------------------
# Identity
# ---------------------------------------------------------------------------
$env:HEXSEC_IDENTITY = '0xH3xS3C'
$env:HEXSEC_DISTRO = '0xH3xS3C Windows'
$env:HEXSEC_CODENAME = '0xZ3r0VO1D'
$env:HEXSEC_ROOT = if ($env:HEXSEC_ROOT) { $env:HEXSEC_ROOT } else {
    Join-Path $env:USERPROFILE '.config\hexsec'
}

# ---------------------------------------------------------------------------
# Oh My Posh — Night City
# ---------------------------------------------------------------------------
$HexSecPoshTheme = Join-Path $env:HEXSEC_ROOT 'oh-my-posh\night-city.omp.json'
if (-not (Test-Path -LiteralPath $HexSecPoshTheme)) {
    $HexSecPoshTheme = Join-Path $PSScriptRoot 'Themes\night-city.omp.json'
}

if (Get-Command oh-my-posh -ErrorAction SilentlyContinue) {
    if (Test-Path -LiteralPath $HexSecPoshTheme) {
        oh-my-posh init pwsh --config $HexSecPoshTheme | Invoke-Expression
    }
    elseif ($env:POSH_THEMES_PATH -and (Test-Path (Join-Path $env:POSH_THEMES_PATH 'paradox.omp.json'))) {
        oh-my-posh init pwsh --config (Join-Path $env:POSH_THEMES_PATH 'paradox.omp.json') | Invoke-Expression
    }
}

# ---------------------------------------------------------------------------
# PSReadLine / editor defaults
# ---------------------------------------------------------------------------
if (Get-Module -ListAvailable PSReadLine) {
    Import-Module PSReadLine -ErrorAction SilentlyContinue
    Set-PSReadLineOption -EditMode Windows -ErrorAction SilentlyContinue
    Set-PSReadLineOption -PredictionSource History -ErrorAction SilentlyContinue
}

$env:EDITOR = if ($env:EDITOR) { $env:EDITOR } else { 'nvim' }
$env:VISUAL = $env:EDITOR

# ---------------------------------------------------------------------------
# Optional Python venv (Documents\scripts\python\0xH3xS3C)
# ---------------------------------------------------------------------------
$HexSecDocs = [Environment]::GetFolderPath('MyDocuments')
$HexSecVenv = Join-Path $HexSecDocs 'scripts\python\0xH3xS3C'
$HexSecActivate = Join-Path $HexSecVenv 'Scripts\Activate.ps1'
if (Test-Path -LiteralPath $HexSecActivate) {
    . $HexSecActivate
}

# ---------------------------------------------------------------------------
# Aliases / functions (workstation)
# ---------------------------------------------------------------------------
function gs { git status @args }
function gp { git push @args }
function ga { git add . @args }
Set-Alias -Name c -Value Clear-Host -ErrorAction SilentlyContinue
Set-Alias -Name g -Value git -ErrorAction SilentlyContinue

function which ($command) {
    Get-Command -Name $command -ErrorAction SilentlyContinue |
        Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue
}

function myip {
    try { (Invoke-RestMethod -Uri 'https://ipinfo.io/ip' -TimeoutSec 5).Trim() }
    catch { (Invoke-RestMethod -Uri 'https://ifconfig.me' -TimeoutSec 5).Trim() }
}

function public-ip { myip }

function ports {
    Get-NetTCPConnection -State Listen -ErrorAction SilentlyContinue |
        Select-Object LocalAddress, LocalPort, OwningProcess |
        Sort-Object LocalPort
}

function check-port {
    param([Parameter(Mandatory)][int]$Port)
    Get-NetTCPConnection -LocalPort $Port -ErrorAction SilentlyContinue
}

# Docker (Windows profile uses Docker Desktop)
if (Get-Command docker -ErrorAction SilentlyContinue) {
    function d { docker @args }
    function dps { docker ps @args }
    function dclean {
        $r = Read-Host 'Clean all Docker resources? [y/N]'
        if ($r -notmatch '^[yY]') { return }
        docker ps -aq | ForEach-Object { docker rm -f $_ 2>$null }
        docker volume prune -f
        docker system prune -af
    }
}

# Kubernetes
if (Get-Command kubectl -ErrorAction SilentlyContinue) {
    Set-Alias -Name k -Value kubectl -ErrorAction SilentlyContinue
    function kgp { kubectl get pods @args }
    function kgs { kubectl get svc @args }
    function kgn { kubectl get nodes @args }
    function kcc { kubectl config current-context @args }
    function kl { kubectl logs -f @args }
}

if (Get-Command helm -ErrorAction SilentlyContinue) {
    Set-Alias -Name hlm -Value helm -ErrorAction SilentlyContinue
}

# IaC / cloud
if (Get-Command terraform -ErrorAction SilentlyContinue) {
    Set-Alias -Name tff -Value terraform -ErrorAction SilentlyContinue
}
if (Get-Command tofu -ErrorAction SilentlyContinue) {
    Set-Alias -Name tfu -Value tofu -ErrorAction SilentlyContinue
}
if (Get-Command aws -ErrorAction SilentlyContinue) {
    function aws_me { aws sts get-caller-identity @args }
}
if (Get-Command az -ErrorAction SilentlyContinue) {
    function azwho { az account show @args }
}
if (Get-Command gcloud -ErrorAction SilentlyContinue) {
    function gcinfo { gcloud config list account @args }
}

# Security / AI
if (Get-Command trivy -ErrorAction SilentlyContinue) {
    function trivy_dir { trivy fs . @args }
}
if (Get-Command claude -ErrorAction SilentlyContinue) {
    Set-Alias -Name cc -Value claude -ErrorAction SilentlyContinue
}

# ---------------------------------------------------------------------------
# Banner (interactive)
# ---------------------------------------------------------------------------
if ($Host.Name -eq 'ConsoleHost' -or $Host.Name -eq 'Visual Studio Code Host' -or $env:WT_SESSION) {
    if (-not $env:HEXSEC_BANNER_SHOWN) {
        $env:HEXSEC_BANNER_SHOWN = '1'
        Write-Host ''
        Write-Host '  ░▒▓█ 0xH3xS3C Windows // 0xZ3r0VO1D // Oh My Posh █▓▒░' -ForegroundColor Cyan
        Write-Host '  ─────────────────────────────────────────────────────' -ForegroundColor DarkGray
        Write-Host ("  {0}@{1} · PowerShell {2}" -f $env:USERNAME, $env:COMPUTERNAME, $PSVersionTable.PSVersion) -ForegroundColor Yellow
        Write-Host '  [net] ready  [gitops] ready  [ai] ready  [docker] desktop' -ForegroundColor DarkCyan
        Write-Host ''
    }
}
