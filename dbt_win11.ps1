# ==============================================================================
#  Windows 11 Debloat Tool
#
#  HOW TO RUN:
#    Open PowerShell as Administrator and run:
#    irm https://gist.githubusercontent.com/Danntav/89c987fa4f38316d2ad1c35134075970/raw/036ce0eabebd750e0edbe0e8faf05f58585b8203/dbt_win11.ps1 | iex
#    irm https://tinyurl.com/4smufznz | iex
#
#  OR right-click this file > "Run with PowerShell"
# ==============================================================================

If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Warning "Administrator privileges required. Relaunching..."
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

$ErrorActionPreference = "SilentlyContinue"
$host.UI.RawUI.WindowTitle = "Windows 11 Debloat Tool"

# ==============================================================================
#  HELPER FUNCTIONS
# ==============================================================================

function Write-Section($title) {
    Write-Host ""
    Write-Host "  +----------------------------------+" -ForegroundColor DarkCyan
    Write-Host "  |  $title" -ForegroundColor Cyan
    Write-Host "  +----------------------------------+" -ForegroundColor DarkCyan
}

function Write-Step($msg) {
    Write-Host "    [-] $msg" -ForegroundColor Yellow
}

function Write-OK($msg) {
    Write-Host "    [+] $msg" -ForegroundColor Green
}

function Show-Menu {
    Clear-Host
    Write-Host ""
    Write-Host "  ############################################" -ForegroundColor Cyan
    Write-Host "  #                                          #" -ForegroundColor Cyan
    Write-Host "  #       WINDOWS 11 DEBLOAT TOOL           #" -ForegroundColor Cyan
    Write-Host "  #                                          #" -ForegroundColor Cyan
    Write-Host "  ############################################" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "  What do you want to do?" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1]  Full Debloat" -ForegroundColor Green
    Write-Host "       Removes all bloatware, OneDrive, Copilot," -ForegroundColor DarkGray
    Write-Host "       Teams, Outlook + disables all trackers/telemetry" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [2]  Remove Edge" -ForegroundColor Green
    Write-Host "       Run this AFTER installing Chrome or Firefox" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [3]  Full Debloat + Remove Edge" -ForegroundColor Green
    Write-Host "       Runs both at once — only use if Chrome/Firefox" -ForegroundColor DarkGray
    Write-Host "       is already installed before running this" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  [Q]  Quit" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  ############################################" -ForegroundColor Cyan
    Write-Host ""
}

# ==============================================================================
#  FUNCTION: FULL DEBLOAT
# ==============================================================================

function Invoke-Debloat {

    function Remove-AppxSafe($name) {
        $pkg = Get-AppxPackage -AllUsers -Name "*$name*"
        if ($pkg) {
            Write-Host "    [-] Removing: $($pkg.Name)" -ForegroundColor Yellow
            $pkg | Remove-AppxPackage -AllUsers
        }
        $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$name*" }
        if ($prov) {
            $prov | Remove-AppxProvisionedPackage -Online | Out-Null
        }
    }

    # --------------------------------------------------------------------------
    Write-Section "REMOVING BLOATWARE APPS"
    # --------------------------------------------------------------------------

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
        "Microsoft.Getstarted",
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
        "Microsoft.OutlookForWindows",
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
        "Microsoft.YourPhone",
        #"Microsoft.ZuneMusic",
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
        # Teams
        "MicrosoftTeams",
        "MSTeams",
        "Microsoft.Teams",
        # Copilot
        "Microsoft.Windows.Ai.Copilot.Provider",
        "Microsoft.Copilot",
        "MicrosoftWindows.Client.AI",
        # Widgets
        "MicrosoftWindows.Client.WebExperience",
        # Mixed Reality
        "Microsoft.Holographic.FirstRun",
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
        "PricelinePartnerNetwork",
        "Shazam",
        "Spotify",
        "SpotifyAB.SpotifyMusic",
        "TheNewYorkTimes",
        "TikTok",
        "TuneIn",
        "Twitter",
        "Wunderlist"
        # Windows Store (comment out if you need it)
        #"Microsoft.WindowsStore"
    )

    foreach ($app in $appsToRemove) { Remove-AppxSafe $app }

    # --------------------------------------------------------------------------
    Write-Section "REMOVING ONEDRIVE"
    # --------------------------------------------------------------------------

    Write-Step "Stopping OneDrive process..."
    taskkill /f /im OneDrive.exe 2>$null

    Write-Step "Running OneDrive uninstaller..."
    $onedrive32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
    $onedrive64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
    if (Test-Path $onedrive64) { Start-Process $onedrive64 -ArgumentList "/uninstall" -Wait }
    elseif (Test-Path $onedrive32) { Start-Process $onedrive32 -ArgumentList "/uninstall" -Wait }

    Write-Step "Cleaning leftover folders..."
    Remove-Item "$env:UserProfile\OneDrive" -Force -Recurse
    Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Force -Recurse
    Remove-Item "$env:ProgramData\Microsoft OneDrive" -Force -Recurse
    Remove-Item "C:\OneDriveTemp" -Force -Recurse

    Write-Step "Removing OneDrive from Explorer sidebar..."
    reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null
    reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null

    # --------------------------------------------------------------------------
    Write-Section "DISABLING TELEMETRY & TRACKERS"
    # --------------------------------------------------------------------------

    Write-Step "Disabling Telemetry services..."
    Stop-Service "DiagTrack" -Force
    Set-Service "DiagTrack" -StartupType Disabled
    Stop-Service "dmwappushservice" -Force
    Set-Service "dmwappushservice" -StartupType Disabled
    Stop-Service "WMPNetworkSvc" -Force
    Set-Service "WMPNetworkSvc" -StartupType Disabled

    Write-Step "Setting telemetry level to 0 (Security)..."
    $telPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    If (!(Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
    Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord
    Set-ItemProperty -Path $telPath -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord

    Write-Step "Disabling Advertising ID..."
    $adPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
    If (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
    Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord

    Write-Step "Disabling app launch tracking..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

    Write-Step "Disabling activity history..."
    $sysPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System"
    If (!(Test-Path $sysPath)) { New-Item -Path $sysPath -Force | Out-Null }
    Set-ItemProperty -Path $sysPath -Name "EnableActivityFeed" -Value 0 -Type DWord
    Set-ItemProperty -Path $sysPath -Name "PublishUserActivities" -Value 0 -Type DWord
    Set-ItemProperty -Path $sysPath -Name "UploadUserActivities" -Value 0 -Type DWord

    Write-Step "Disabling location tracking..."
    $locPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
    If (!(Test-Path $locPath)) { New-Item -Path $locPath -Force | Out-Null }
    Set-ItemProperty -Path $locPath -Name "Value" -Value "Deny" -Type String

    Write-Step "Disabling feedback prompts..."
    $fbPath = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
    If (!(Test-Path $fbPath)) { New-Item -Path $fbPath -Force | Out-Null }
    Set-ItemProperty -Path $fbPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord

    Write-Step "Disabling Bing/Cortana search in taskbar..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord

    Write-Step "Disabling tailored experiences..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord

    Write-Step "Disabling Wi-Fi Sense..."
    $wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
    If (!(Test-Path $wifiPath)) { New-Item -Path $wifiPath -Force | Out-Null }
    Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord

    Write-Step "Disabling telemetry scheduled tasks..."
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

    # --------------------------------------------------------------------------
    Write-Section "DISABLING COPILOT"
    # --------------------------------------------------------------------------

    Write-Step "Disabling Copilot via Group Policy..."
    $copilotPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    If (!(Test-Path $copilotPath)) { New-Item -Path $copilotPath -Force | Out-Null }
    Set-ItemProperty -Path $copilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

    $copilotUserPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
    If (!(Test-Path $copilotUserPath)) { New-Item -Path $copilotUserPath -Force | Out-Null }
    Set-ItemProperty -Path $copilotUserPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

    Write-Step "Removing Copilot from taskbar..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Type DWord

    # --------------------------------------------------------------------------
    Write-Section "PRIVACY & UI TWEAKS"
    # --------------------------------------------------------------------------

    Write-Step "Hiding Search box from taskbar..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

    Write-Step "Disabling Task View button..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord

    Write-Step "Disabling Widgets panel..."
    $dshPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
    If (!(Test-Path $dshPath)) { New-Item -Path $dshPath -Force | Out-Null }
    Set-ItemProperty -Path $dshPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord

    Write-Step "Disabling Windows Tips and suggested content..."
    $cdm = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
    Set-ItemProperty -Path $cdm -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord
    Set-ItemProperty -Path $cdm -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord

    Write-Step "Disabling 'Get even more out of Windows' nag screen..."
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0 -Type DWord

    # --------------------------------------------------------------------------
    Write-Section "FINAL CLEANUP"
    # --------------------------------------------------------------------------

    Write-Step "Running Disk Cleanup..."
    cleanmgr /sagerun:1 2>$null

    Write-OK "Full Debloat complete!"
}

# ==============================================================================
#  FUNCTION: REMOVE EDGE
# ==============================================================================

function Invoke-RemoveEdge {

    Write-Section "CLOSING EDGE PROCESSES"
    Write-Step "Killing Edge processes..."
    Get-Process -Name "msedge", "MicrosoftEdge", "MicrosoftEdgeUpdate" -ErrorAction SilentlyContinue | Stop-Process -Force
    Start-Sleep -Seconds 2

    Write-Section "UNINSTALLING EDGE"
    $edgePaths = @(
        "$env:ProgramFiles\Microsoft\Edge\Application",
        "${env:ProgramFiles(x86)}\Microsoft\Edge\Application"
    )

    $removed = $false
    foreach ($basePath in $edgePaths) {
        if (Test-Path $basePath) {
            $versions = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -match "^\d+" }
            foreach ($ver in $versions) {
                $installer = Join-Path $ver.FullName "Installer\setup.exe"
                if (Test-Path $installer) {
                    Write-Step "Found Edge $($ver.Name) — uninstalling..."
                    Start-Process -FilePath $installer -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
                    $removed = $true
                }
            }
        }
    }

    if (-not $removed) {
        Write-Host "    [!] setup.exe not found. Trying winget..." -ForegroundColor Magenta
        winget uninstall --id Microsoft.Edge --silent --accept-source-agreements
    }

    Write-Section "REMOVING EDGE WEBVIEW2"
    Write-Step "Removing Edge WebView2 Runtime..."
    $webview2Paths = @(
        "$env:ProgramFiles\Microsoft\EdgeWebView\Application",
        "${env:ProgramFiles(x86)}\Microsoft\EdgeWebView\Application"
    )
    foreach ($basePath in $webview2Paths) {
        if (Test-Path $basePath) {
            $versions = Get-ChildItem -Path $basePath -Directory | Where-Object { $_.Name -match "^\d+" }
            foreach ($ver in $versions) {
                $installer = Join-Path $ver.FullName "Installer\setup.exe"
                if (Test-Path $installer) {
                    Start-Process -FilePath $installer -ArgumentList "--uninstall --msedgewebview --system-level --verbose-logging --force-uninstall" -Wait
                }
            }
        }
    }

    Write-Section "BLOCKING EDGE FROM REINSTALLING"
    Write-Step "Disabling Edge update tasks..."
    $edgeTasks = @(
        "\Microsoft\MicrosoftEdge\MicrosoftEdgeUpdateTaskMachineCore",
        "\Microsoft\MicrosoftEdge\MicrosoftEdgeUpdateTaskMachineUA",
        "\Microsoft\MicrosoftEdge\BrowserUpdateDaemonCore",
        "\Microsoft\MicrosoftEdge\BrowserUpdateDaemonUA"
    )
    foreach ($task in $edgeTasks) {
        Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
    }

    Write-Step "Disabling Edge Update services..."
    Stop-Service "edgeupdate" -Force
    Set-Service "edgeupdate" -StartupType Disabled
    Stop-Service "edgeupdatem" -Force
    Set-Service "edgeupdatem" -StartupType Disabled

    Write-Step "Blocking Edge auto-reinstall via registry..."
    $edgeBlockPath = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
    If (!(Test-Path $edgeBlockPath)) { New-Item -Path $edgeBlockPath -Force | Out-Null }
    Set-ItemProperty -Path $edgeBlockPath -Name "DoNotUpdateToEdgeWithChromium" -Value 1 -Type DWord

    $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
    If (!(Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
    Set-ItemProperty -Path $auPath -Name "InstallDefault" -Value 0 -Type DWord

    Write-Step "Removing Edge from startup..."
    Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue

    Write-Section "CLEANING LEFTOVER FOLDERS"
    Write-Step "Removing Edge leftover data..."
    Remove-Item "$env:LocalAppData\Microsoft\Edge" -Force -Recurse
    Remove-Item "$env:ProgramData\Microsoft\EdgeUpdate" -Force -Recurse
    Remove-Item "$env:ProgramFiles\Microsoft\Edge" -Force -Recurse
    Remove-Item "${env:ProgramFiles(x86)}\Microsoft\Edge" -Force -Recurse
    Remove-Item "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate" -Force -Recurse

    Write-OK "Edge removal complete!"
}

# ==============================================================================
#  MAIN MENU LOOP
# ==============================================================================

do {
    Show-Menu
    Write-Host "  Press a key: " -NoNewline -ForegroundColor White
    $key = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    $choice = $key.Character.ToString().ToUpper()
    Write-Host $choice

    switch ($choice) {

        "1" {
            Write-Host ""
            Write-Host "  Starting Full Debloat..." -ForegroundColor Cyan
            Invoke-Debloat
            Write-Host ""
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host "  #   DONE! A restart is recommended.       #" -ForegroundColor Green
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }

        "2" {
            Write-Host ""
            Write-Host "  WARNING: Make sure Chrome or Firefox is already installed!" -ForegroundColor Red
            Write-Host "  Press any key to continue or CTRL+C to cancel..." -ForegroundColor Yellow
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
            Invoke-RemoveEdge
            Write-Host ""
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host "  #   DONE! A restart is recommended.       #" -ForegroundColor Green
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }

        "3" {
            Write-Host ""
            Write-Host "  WARNING: Make sure Chrome or Firefox is already installed!" -ForegroundColor Red
            Write-Host "  Press any key to continue or CTRL+C to cancel..." -ForegroundColor Yellow
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
            Invoke-Debloat
            Invoke-RemoveEdge
            Write-Host ""
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host "  #   ALL DONE! A restart is recommended.   #" -ForegroundColor Green
            Write-Host "  ############################################" -ForegroundColor Green
            Write-Host ""
            Write-Host "  Press any key to return to menu..." -ForegroundColor DarkGray
            $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
        }

        "Q" {
            Write-Host ""
            Write-Host "  Exiting. Goodbye!" -ForegroundColor DarkGray
            Write-Host ""
            Exit
        }

        default {
            Write-Host ""
            Write-Host "  Invalid option. Try again..." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }

} while ($true)
