#Requires -Version 5.1
# Thin wrappers — same behaviour as: .\install.ps1 -Module <name>
param([switch]$DryRun)
& "$PSScriptRoot\..\install.ps1" -Module base -DryRun:$DryRun @args
