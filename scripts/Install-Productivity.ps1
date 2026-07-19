#Requires -Version 5.1
param([switch]$DryRun)
& "$PSScriptRoot\..\install.ps1" -Module productivity -DryRun:$DryRun @args
