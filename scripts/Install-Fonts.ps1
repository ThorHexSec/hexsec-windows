#Requires -Version 5.1
param([switch]$DryRun)
& "$PSScriptRoot\..\install.ps1" -Module fonts -DryRun:$DryRun @args
