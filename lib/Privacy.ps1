# HexSec Windows — privacy hardening + accessibility hotkeys
# Disables maximum practical Windows telemetry / advertising / feedback,
# turns off Sticky Keys, disables Explorer Recents, and removes Copilot.
#Requires -Version 5.1

function Set-HexSecRegValue {
    param(
        [Parameter(Mandatory)][string]$Path,
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)]$Value,
        [ValidateSet("DWord", "String", "QWord")][string]$Type = "DWord"
    )

    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] Set $Path\$Name = $Value ($Type)"
        return
    }

    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }

    $kind = switch ($Type) {
        "DWord"  { "DWord" }
        "QWord"  { "QWord" }
        "String" { "String" }
    }
    Set-ItemProperty -Path $Path -Name $Name -Value $Value -Type $kind -Force
}

function Disable-HexSecStickyKeys {
    Write-HexSecInfo "=== Accessibility: disable Sticky Keys (and related hotkeys) ==="

    # Flags 506 = Sticky Keys off + hotkey (Shift x5) disabled
    Set-HexSecRegValue -Path "HKCU:\Control Panel\Accessibility\StickyKeys" -Name "Flags" -Value "506" -Type String
    # Filter Keys off
    Set-HexSecRegValue -Path "HKCU:\Control Panel\Accessibility\Keyboard Response" -Name "Flags" -Value "122" -Type String
    # Toggle Keys off
    Set-HexSecRegValue -Path "HKCU:\Control Panel\Accessibility\ToggleKeys" -Name "Flags" -Value "58" -Type String
    # Mouse Keys off
    Set-HexSecRegValue -Path "HKCU:\Control Panel\Accessibility\MouseKeys" -Name "Flags" -Value "58" -Type String

    # Windows 11 Settings path: Accessibility → Keyboard → Sticky keys
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Accessibility" -Name "Configuration" -Value "" -Type String

    Write-HexSecOk "Sticky Keys / Filter Keys / Toggle Keys hotkeys disabled (current user)"
}

function Set-HexSecTelemetryPrivacy {
    Write-HexSecInfo "=== Privacy: reduce Windows telemetry & advertising ==="

    # Diagnostic data — lowest practical level via policy (0=Security on Enterprise;
    # on Pro Windows may enforce a minimum, but policy still reduces collection).
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "AllowTelemetry" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

    # Feedback frequency — never
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Value 0

    # Advertising ID
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" -Name "DisabledByGroupPolicy" -Value 1

    # Tailored experiences / suggested content
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338393Enabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353694Enabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-353696Enabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SoftLandingEnabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0

    # Activity History / Timeline
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0

    # Location
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\LocationAndSensors" -Name "DisableLocation" -Value 1
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny" -Type String

    # Online speech / inking & typing personalization
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\InputPersonalization\TrainedDataStore" -Name "HarvestContacts" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0

    # Find my device
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\FindMyDevice" -Name "AllowFindMyDevice" -Value 0

    # Cortana / Search highlights / cloud search
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "AllowCortana" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "DisableWebSearch" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search" -Name "ConnectedSearchUseWeb" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\SearchSettings" -Name "IsDynamicSearchBoxEnabled" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0

    # App launch tracking / start suggestions
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowSyncProviderNotifications" -Value 0

    # Windows tips / consumer features
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableWindowsConsumerFeatures" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent" -Name "DisableSoftLanding" -Value 1
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0

    # Delivery Optimization (limit P2P uploads — local network only)
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DeliveryOptimization\Config" -Name "DODownloadMode" -Value 1

    # Error reporting
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" -Name "Disabled" -Value 1

    # Optional diagnostic / inventory
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "AITEnable" -Value 0
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\AppCompat" -Name "DisableInventory" -Value 1

    Write-HexSecOk "Privacy / telemetry policies applied (sign out or reboot for full effect)"
}

function Disable-HexSecExplorerRecents {
    Write-HexSecInfo "=== Explorer: disable Recent files / folders ==="

    # File Explorer → Options → Privacy / Home: recently used files & frequent folders
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowRecent" -Value 0
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowFrequent" -Value 0
    # Do not track documents in Jump Lists / Start
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackDocs" -Value 0

    # Policy: do not keep recent docs history
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "NoRecentDocsHistory" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name "ClearRecentDocsOnExit" -Value 1

    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] Would clear %APPDATA%\Microsoft\Windows\Recent"
    }
    else {
        $recent = Join-Path $env:APPDATA "Microsoft\Windows\Recent"
        if (Test-Path $recent) {
            Get-ChildItem -Path $recent -Force -ErrorAction SilentlyContinue |
                Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
        }
        Write-HexSecOk "Explorer Recents disabled and Recent folder cleared"
    }
}

function Remove-HexSecCopilot {
    Write-HexSecInfo "=== Copilot: uninstall and block reinstall ==="

    # Hide / disable Copilot policies
    Set-HexSecRegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot" -Name "TurnOffWindowsCopilot" -Value 1
    # Newer policy (Win11 25H2+): remove Microsoft Copilot app
    Set-HexSecRegValue -Path "HKCU:\Software\Policies\Microsoft\Windows\WindowsAI" -Name "RemoveMicrosoftCopilotApp" -Value 1
    Set-HexSecRegValue -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsAI" -Name "RemoveMicrosoftCopilotApp" -Value 1
    # Taskbar Copilot button (legacy / residual)
    Set-HexSecRegValue -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0

    if ($script:HexSecWinDryRun) {
        Write-HexSecInfo "[dry-run] Would uninstall Microsoft.Copilot via winget / Appx"
        return
    }

    # winget package (Store / desktop Copilot app)
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        Write-HexSecInfo "winget uninstall Microsoft.Copilot …"
        & winget uninstall --id Microsoft.Copilot -e --disable-interactivity --accept-source-agreements 2>$null
        & winget uninstall --id 9NHT9RB2F4HD -e --disable-interactivity --accept-source-agreements 2>$null
    }

    # Appx for current user and all users (when admin)
    try {
        Get-AppxPackage -Name "*Copilot*" -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-HexSecInfo "Remove-AppxPackage $($_.Name)"
                Remove-AppxPackage -Package $_.PackageFullName -ErrorAction SilentlyContinue
            }
        Get-AppxPackage -AllUsers -Name "*Copilot*" -ErrorAction SilentlyContinue |
            ForEach-Object {
                Write-HexSecInfo "Remove-AppxPackage (AllUsers) $($_.Name)"
                Remove-AppxPackage -Package $_.PackageFullName -AllUsers -ErrorAction SilentlyContinue
            }
        Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "*Copilot*" } |
            ForEach-Object {
                Write-HexSecInfo "Remove provisioned $($_.DisplayName)"
                Remove-AppxProvisionedPackage -Online -PackageName $_.PackageName -ErrorAction SilentlyContinue | Out-Null
            }
    }
    catch {
        Write-HexSecWarn "Copilot Appx removal: $($_.Exception.Message)"
    }

    Write-HexSecOk "Copilot uninstalled/blocked (updates may try to restore — policies resist reinstall)"
}

function Invoke-HexSecPrivacyHardening {
    Write-HexSecInfo "=== Module: privacy ==="
    Disable-HexSecStickyKeys
    Set-HexSecTelemetryPrivacy
    Disable-HexSecExplorerRecents
    Remove-HexSecCopilot
}
