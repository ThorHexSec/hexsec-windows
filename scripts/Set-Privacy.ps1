#Requires -Version 5.1
param([switch]$DryRun, [switch]$SkipAdminCheck)
& "$PSScriptRoot\..\install.ps1" -Module privacy -DryRun:$DryRun -SkipAdminCheck:$SkipAdminCheck
