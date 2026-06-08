# ==============================================================================
#  Windows 11 Debloat Script - EN-US
#  Description: Removes bloatware, disables telemetry/trackers, Copilot,
#               OneDrive, and applies privacy/performance tweaks.
#  HOW TO RUN:
#    1. Right-click the file > "Run with PowerShell"
#    OR open PowerShell as Administrator and run:
#       Set-ExecutionPolicy Bypass -Scope Process -Force; .\dbt_Win11_ENUS.ps1
# ==============================================================================

# --- Require Administrator ---
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Warning "Run this script as Administrator!"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

$ErrorActionPreference = "SilentlyContinue"

function Write-Section($title) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "  $title" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
}

function Remove-AppxSafe($name) {
    $pkg = Get-AppxPackage -AllUsers -Name "*$name*"
    if ($pkg) {
        Write-Host "  [-] Removing: $($pkg.Name)" -ForegroundColor Yellow
        $pkg | Remove-AppxPackage -AllUsers
    }
    $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$name*" }
    if ($prov) {
        $prov | Remove-AppxProvisionedPackage -Online | Out-Null
    }
}

# ==============================================================================
Write-Section "REMOVING BLOATWARE APPS"
# ==============================================================================

$appsToRemove = @(
    # Microsoft Bloat
    "Microsoft.3DBuilder",
    "Microsoft.BingFinance",
    "Microsoft.BingFoodAndDrink",
    "Microsoft.BingHealthAndFitness",
    "Microsoft.BingMaps",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingTranslator",
    "Microsoft.BingTravel",
    "Microsoft.BingWeather",
    "Microsoft.GetHelp",
    #"Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.Microsoft3DViewer",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftPowerBIForWindows",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.MicrosoftStickyNotes",
    "Microsoft.MixedReality.Portal",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.News",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway",
    "Microsoft.OneConnect",
    "Microsoft.People",
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.WebMediaExtensions",
    "Microsoft.WebpImageExtension",
    #"Microsoft.Windows.Photos",             
    #"Microsoft.WindowsAlarms",
    #"Microsoft.WindowsCamera",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.WindowsMaps",
    "Microsoft.WindowsPhone",
    "Microsoft.WindowsSoundRecorder",
    "Microsoft.YourPhone",                  # Phone Link / "Vincular Celular"
    #"Microsoft.ZuneMusic",                  # Media Player (legacy)
    "Microsoft.ZuneVideo",
    # Xbox
    "Microsoft.GamingApp",
    "Microsoft.XboxApp",
    "Microsoft.XboxGameCallableUI",
    "Microsoft.XboxGameOverlay",
    "Microsoft.XboxGamingOverlay",
    "Microsoft.XboxIdentityProvider",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.Xbox.TCUI",
    # Copilot
    "Microsoft.Windows.Ai.Copilot.Provider",
    "Microsoft.Copilot",
    "MicrosoftWindows.Client.AI",
    # Third-party bundled
    "ACGMediaPlayer",
    "ActiproSoftwareLLC",
    "AdobeSystemsIncorporated.AdobePhotoshopExpress",
    "Amazon.com.Amazon",
    "AmazonVideo.PrimeVideo",
    "Clipchamp.Clipchamp",
    "Disney.37853D22215E2",
    "Dolby",
    "Duolingo-LearnLanguagesforFree",
    "EclipseManager",
    "Facebook",
    "Flipboard",
    "HULULLC.HULUPLUS",
    "king.com.BubbleWitch3Saga",
    "king.com.CandyCrushFriends",
    "king.com.CandyCrushSaga",
    "king.com.CandyCrushSodaSaga",
    "LinkedInforWindows",
    "MarchofEmpires",
    "Netflix",
    "PandoraMediaInc",
    "Plex",
    "Microsoft.OutlookForWindows",
    "MicrosoftTeams",
    "MSTeams",
    "Microsoft.Teams",
    "PricelinePartnerNetwork",
    "Shazam",
    "Spotify",
    "SpotifyAB.SpotifyMusic",
    "TheNewYorkTimes",
    "TikTok",
    "TuneIn",
    "Twitter",
    "Wunderlist",
    # Widgets / News feed
    "MicrosoftWindows.Client.WebExperience",   # Widgets panel
    # Mixed Reality / Holographic
    "Microsoft.Holographic.FirstRun",
    # Windows Store
    #"Microsoft.WindowsStore"                   # OPTIONAL: comment out if you use Store
)

foreach ($app in $appsToRemove) {
    Remove-AppxSafe $app
}

# ==============================================================================
Write-Section "REMOVING ONEDRIVE"
# ==============================================================================

Write-Host "  [-] Stopping OneDrive process..." -ForegroundColor Yellow
taskkill /f /im OneDrive.exe 2>$null

Write-Host "  [-] Running OneDrive uninstaller..." -ForegroundColor Yellow
$onedrive32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
$onedrive64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $onedrive64) { Start-Process $onedrive64 -ArgumentList "/uninstall" -Wait }
elseif (Test-Path $onedrive32) { Start-Process $onedrive32 -ArgumentList "/uninstall" -Wait }

Write-Host "  [-] Cleaning leftover folders..." -ForegroundColor Yellow
Remove-Item "$env:UserProfile\OneDrive" -Force -Recurse
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Force -Recurse
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Force -Recurse
Remove-Item "C:\OneDriveTemp" -Force -Recurse

Write-Host "  [-] Removing OneDrive from Explorer sidebar..." -ForegroundColor Yellow
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null
reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null

# ==============================================================================
Write-Section "DISABLING TELEMETRY & TRACKERS"
# ==============================================================================

Write-Host "  [-] Disabling Telemetry service..." -ForegroundColor Yellow
Stop-Service "DiagTrack" -Force
Set-Service "DiagTrack" -StartupType Disabled
Stop-Service "dmwappushservice" -Force
Set-Service "dmwappushservice" -StartupType Disabled

Write-Host "  [-] Disabling WAP Push service..." -ForegroundColor Yellow
Stop-Service "WMPNetworkSvc" -Force
Set-Service "WMPNetworkSvc" -StartupType Disabled

Write-Host "  [-] Setting telemetry level to 0 (Security)..." -ForegroundColor Yellow
$telPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
If (!(Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord

Write-Host "  [-] Disabling advertising ID..." -ForegroundColor Yellow
$adPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord

Write-Host "  [-] Disabling app launch tracking..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

Write-Host "  [-] Disabling activity history..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord

Write-Host "  [-] Disabling location tracking..." -ForegroundColor Yellow
$locPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
If (!(Test-Path $locPath)) { New-Item -Path $locPath -Force | Out-Null }
Set-ItemProperty -Path $locPath -Name "Value" -Value "Deny" -Type String

Write-Host "  [-] Disabling feedback frequency..." -ForegroundColor Yellow
$fbPath = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
If (!(Test-Path $fbPath)) { New-Item -Path $fbPath -Force | Out-Null }
Set-ItemProperty -Path $fbPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord

Write-Host "  [-] Disabling Cortana web search in taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord

Write-Host "  [-] Disabling tailored experiences..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord

Write-Host "  [-] Disabling Wi-Fi Sense..." -ForegroundColor Yellow
$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $wifiPath)) { New-Item -Path $wifiPath -Force | Out-Null }
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord

# ==============================================================================
Write-Section "DISABLING COPILOT"
# ==============================================================================

Write-Host "  [-] Disabling Copilot via Group Policy..." -ForegroundColor Yellow
$copilotPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
If (!(Test-Path $copilotPath)) { New-Item -Path $copilotPath -Force | Out-Null }
Set-ItemProperty -Path $copilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

$copilotUserPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
If (!(Test-Path $copilotUserPath)) { New-Item -Path $copilotUserPath -Force | Out-Null }
Set-ItemProperty -Path $copilotUserPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

Write-Host "  [-] Removing Copilot from taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Type DWord

# ==============================================================================
Write-Section "PRIVACY & PERFORMANCE TWEAKS"
# ==============================================================================

Write-Host "  [-] Hiding Search box from taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

Write-Host "  [-] Disabling Task View button on taskbar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord

Write-Host "  [-] Disabling News and Interests (Widgets)..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Dsh" -Name "AllowNewsAndInterests" -Value 0 -Type DWord -ErrorAction SilentlyContinue
$dshPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
If (!(Test-Path $dshPath)) { New-Item -Path $dshPath -Force | Out-Null }
Set-ItemProperty -Path $dshPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord

Write-Host "  [-] Disabling automatic Windows Tips..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord

Write-Host "  [-] Disabling Start Menu suggested content..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord

Write-Host "  [-] Disabling lock screen ads..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord

Write-Host "  [-] Disabling 'Get even more out of Windows' nag screen..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

Write-Host "  [-] Disabling scheduled tasks related to telemetry..." -ForegroundColor Yellow
$tasksToDisable = @(
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "\Microsoft\Windows\Autochk\Proxy",
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "\Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "\Microsoft\Windows\Feedback\Siuf\DmClient",
    "\Microsoft\Windows\Feedback\Siuf\DmClientOnScenarioDownload",
    "\Microsoft\Windows\Maps\MapsToastTask",
    "\Microsoft\Windows\Maps\MapsUpdateTask",
    "\Microsoft\Windows\NetTrace\GatherNetworkInfo",
    "\Microsoft\Windows\Windows Error Reporting\QueueReporting",
    "\Microsoft\Windows\WindowsUpdate\Automatic App Update"
)
foreach ($task in $tasksToDisable) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
}

# ==============================================================================
Write-Section "OPTIONAL: DISABLE HIBERNATION (saves disk space)"
# ==============================================================================
# Uncomment the line below if you want to disable hibernate (frees up GBs):
# powercfg /h off

# ==============================================================================
Write-Section "CLEANING UP"
# ==============================================================================

Write-Host "  [-] Running Disk Cleanup..." -ForegroundColor Yellow
cleanmgr /sagerun:1 2>$null

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  ALL DONE! Restart recommended." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
