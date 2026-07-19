#Requires -Version 5.1
<#
.SYNOPSIS
  Install the full HexSec Windows developer-platform profile.

.EXAMPLE
  .\scripts\Install-All.ps1
  .\scripts\Install-All.ps1 -DryRun
  .\scripts\Install-All.ps1 -WithGcp -WithTerraform
#>
param(
    [switch]$DryRun,
    [switch]$WithGcp,
    [switch]$WithTerraform
)
& "$PSScriptRoot\..\install.ps1" -Module all `
    -DryRun:$DryRun -WithGcp:$WithGcp -WithTerraform:$WithTerraform
