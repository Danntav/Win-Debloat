# ==============================================================================
#  Script de Limpeza do Windows 11 - PT-BR
#  Descrição: Remove bloatware, desativa telemetria/rastreadores, Copilot,
#             OneDrive e aplica ajustes de privacidade e desempenho.
#  COMO EXECUTAR:
#    1. Clique com botão direito no arquivo > "Executar com PowerShell"
#    OU abra o PowerShell como Administrador e execute:
#       Set-ExecutionPolicy Bypass -Scope Process -Force; .\dbt_Win11_PTBR.ps1
# ==============================================================================

# --- Exige Administrador ---
If (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]"Administrator")) {
    Write-Warning "Execute este script como Administrador!"
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

$ErrorActionPreference = "SilentlyContinue"

function Write-Secao($titulo) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Cyan
    Write-Host "  $titulo" -ForegroundColor Cyan
    Write-Host "======================================" -ForegroundColor Cyan
}

function Remove-AppxSafe($nome) {
    $pkg = Get-AppxPackage -AllUsers -Name "*$nome*"
    if ($pkg) {
        Write-Host "  [-] Removendo: $($pkg.Name)" -ForegroundColor Yellow
        $pkg | Remove-AppxPackage -AllUsers
    }
    $prov = Get-AppxProvisionedPackage -Online | Where-Object { $_.PackageName -like "*$nome*" }
    if ($prov) {
        $prov | Remove-AppxProvisionedPackage -Online | Out-Null
    }
}

# ==============================================================================
Write-Secao "REMOVENDO APLICATIVOS DESNECESSÁRIOS (BLOATWARE)"
# ==============================================================================

$appsParaRemover = @(
    # Lixo da Microsoft
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
    "Microsoft.MicrosoftStickyNotes",       # Notas Autoadesivas
    "Microsoft.MixedReality.Portal",
    "Microsoft.NetworkSpeedTest",
    "Microsoft.News",
    "Microsoft.Office.OneNote",
    "Microsoft.Office.Sway",
    "Microsoft.OneConnect",
    "Microsoft.People",                     # Pessoas
    "Microsoft.PowerAutomateDesktop",
    "Microsoft.Print3D",
    "Microsoft.SkypeApp",
    "Microsoft.StorePurchaseApp",
    "Microsoft.Todos",
    "Microsoft.Wallet",
    "Microsoft.WebMediaExtensions",
    "Microsoft.WebpImageExtension",
    #"Microsoft.Windows.Photos",             # Fotos (substitua por um visualizador melhor)
    #"Microsoft.WindowsAlarms",              # Alarmes e Relógio
    #"Microsoft.WindowsCamera",              # Câmera
    "Microsoft.WindowsFeedbackHub",         # Hub de Feedback
    #"Microsoft.WindowsMaps",                # Mapas
    "Microsoft.WindowsPhone",
    "Microsoft.WindowsSoundRecorder",       # Gravador de Som
    "Microsoft.YourPhone",                  # Vincular ao Telefone / Vincular Celular
    #"Microsoft.ZuneMusic",                  # Groove Música
    "Microsoft.ZuneVideo",                  # Filmes e TV
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
    # Lixo de terceiros pré-instalado
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
    "Wunderlist",
    "Microsoft.OutlookForWindows",
    "MicrosoftTeams",
    "MSTeams",
    "Microsoft.Teams",
    # Painel de Widgets / Feed de notícias
    "MicrosoftWindows.Client.WebExperience",   # Painel de Widgets
    # Realidade Mista / Holográfico
    "Microsoft.Holographic.FirstRun",
    # Windows Store
    #"Microsoft.WindowsStore"                   # OPCIONAL
)

foreach ($app in $appsParaRemover) {
    Remove-AppxSafe $app
}

# ==============================================================================
Write-Secao "REMOVENDO ONEDRIVE"
# ==============================================================================

Write-Host "  [-] Encerrando processo do OneDrive..." -ForegroundColor Yellow
taskkill /f /im OneDrive.exe 2>$null

Write-Host "  [-] Executando desinstalador do OneDrive..." -ForegroundColor Yellow
$onedrive32 = "$env:SystemRoot\System32\OneDriveSetup.exe"
$onedrive64 = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $onedrive64) { Start-Process $onedrive64 -ArgumentList "/uninstall" -Wait }
elseif (Test-Path $onedrive32) { Start-Process $onedrive32 -ArgumentList "/uninstall" -Wait }

Write-Host "  [-] Limpando pastas residuais..." -ForegroundColor Yellow
Remove-Item "$env:UserProfile\OneDrive" -Force -Recurse
Remove-Item "$env:LocalAppData\Microsoft\OneDrive" -Force -Recurse
Remove-Item "$env:ProgramData\Microsoft OneDrive" -Force -Recurse
Remove-Item "C:\OneDriveTemp" -Force -Recurse

Write-Host "  [-] Removendo OneDrive da barra lateral do Explorer..." -ForegroundColor Yellow
reg delete "HKEY_CLASSES_ROOT\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null
reg delete "HKEY_CLASSES_ROOT\Wow6432Node\CLSID\{018D5C66-4533-4307-9B53-224DE2ED1FE6}" /f 2>$null

# ==============================================================================
Write-Secao "DESATIVANDO TELEMETRIA E RASTREADORES"
# ==============================================================================

Write-Host "  [-] Desativando serviço de Telemetria..." -ForegroundColor Yellow
Stop-Service "DiagTrack" -Force
Set-Service "DiagTrack" -StartupType Disabled
Stop-Service "dmwappushservice" -Force
Set-Service "dmwappushservice" -StartupType Disabled

Write-Host "  [-] Desativando serviço WAP Push..." -ForegroundColor Yellow
Stop-Service "WMPNetworkSvc" -Force
Set-Service "WMPNetworkSvc" -StartupType Disabled

Write-Host "  [-] Definindo nível de telemetria para 0 (Segurança)..." -ForegroundColor Yellow
$telPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
If (!(Test-Path $telPath)) { New-Item -Path $telPath -Force | Out-Null }
Set-ItemProperty -Path $telPath -Name "AllowTelemetry" -Value 0 -Type DWord

Write-Host "  [-] Desativando ID de publicidade..." -ForegroundColor Yellow
$adPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\AdvertisingInfo"
If (!(Test-Path $adPath)) { New-Item -Path $adPath -Force | Out-Null }
Set-ItemProperty -Path $adPath -Name "Enabled" -Value 0 -Type DWord

Write-Host "  [-] Desativando rastreamento de inicialização de aplicativos..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0

Write-Host "  [-] Desativando histórico de atividades..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "EnableActivityFeed" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "PublishUserActivities" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\System" -Name "UploadUserActivities" -Value 0 -Type DWord

Write-Host "  [-] Desativando rastreamento de localização..." -ForegroundColor Yellow
$locPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location"
If (!(Test-Path $locPath)) { New-Item -Path $locPath -Force | Out-Null }
Set-ItemProperty -Path $locPath -Name "Value" -Value "Deny" -Type String

Write-Host "  [-] Desativando frequência de feedback..." -ForegroundColor Yellow
$fbPath = "HKCU:\SOFTWARE\Microsoft\Siuf\Rules"
If (!(Test-Path $fbPath)) { New-Item -Path $fbPath -Force | Out-Null }
Set-ItemProperty -Path $fbPath -Name "NumberOfSIUFInPeriod" -Value 0 -Type DWord
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection" -Name "DoNotShowFeedbackNotifications" -Value 1 -Type DWord

Write-Host "  [-] Desativando pesquisa Bing/Cortana na barra de tarefas..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -Type DWord

Write-Host "  [-] Desativando experiências personalizadas..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0 -Type DWord

Write-Host "  [-] Desativando Wi-Fi Sense..." -ForegroundColor Yellow
$wifiPath = "HKLM:\SOFTWARE\Microsoft\WcmSvc\wifinetworkmanager\config"
If (!(Test-Path $wifiPath)) { New-Item -Path $wifiPath -Force | Out-Null }
Set-ItemProperty -Path $wifiPath -Name "AutoConnectAllowedOEM" -Value 0 -Type DWord

# ==============================================================================
Write-Secao "DESATIVANDO COPILOT"
# ==============================================================================

Write-Host "  [-] Desativando Copilot via Política de Grupo..." -ForegroundColor Yellow
$copilotPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
If (!(Test-Path $copilotPath)) { New-Item -Path $copilotPath -Force | Out-Null }
Set-ItemProperty -Path $copilotPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

$copilotUserPath = "HKCU:\SOFTWARE\Policies\Microsoft\Windows\WindowsCopilot"
If (!(Test-Path $copilotUserPath)) { New-Item -Path $copilotUserPath -Force | Out-Null }
Set-ItemProperty -Path $copilotUserPath -Name "TurnOffWindowsCopilot" -Value 1 -Type DWord

Write-Host "  [-] Removendo Copilot da barra de tarefas..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowCopilotButton" -Value 0 -Type DWord

# ==============================================================================
Write-Secao "AJUSTES DE PRIVACIDADE E DESEMPENHO"
# ==============================================================================

Write-Host "  [-] Ocultando caixa de pesquisa da barra de tarefas..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord

Write-Host "  [-] Desativando botão de Visão de Tarefas na barra de tarefas..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowTaskViewButton" -Value 0 -Type DWord

Write-Host "  [-] Desativando Widgets (Notícias e Interesses)..." -ForegroundColor Yellow
$dshPath = "HKLM:\SOFTWARE\Policies\Microsoft\Dsh"
If (!(Test-Path $dshPath)) { New-Item -Path $dshPath -Force | Out-Null }
Set-ItemProperty -Path $dshPath -Name "AllowNewsAndInterests" -Value 0 -Type DWord

Write-Host "  [-] Desativando dicas automáticas do Windows..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SystemPaneSuggestionsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SilentInstalledAppsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "PreInstalledAppsEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "OemPreInstalledAppsEnabled" -Value 0 -Type DWord

Write-Host "  [-] Desativando sugestões no Menu Iniciar..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord

Write-Host "  [-] Desativando propagandas na tela de bloqueio..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "RotatingLockScreenOverlayEnabled" -Value 0 -Type DWord
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338387Enabled" -Value 0 -Type DWord

Write-Host "  [-] Desativando tela 'Aproveite ainda mais o Windows'..." -ForegroundColor Yellow
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\UserProfileEngagement" -Name "ScoobeSystemSettingEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

Write-Host "  [-] Desativando tarefas agendadas de telemetria..." -ForegroundColor Yellow
$tarefasParaDesativar = @(
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
foreach ($tarefa in $tarefasParaDesativar) {
    Disable-ScheduledTask -TaskName $tarefa -ErrorAction SilentlyContinue | Out-Null
}

# ==============================================================================
Write-Secao "OPCIONAL: DESATIVAR HIBERNAÇÃO (libera espaço em disco)"
# ==============================================================================
# Descomente a linha abaixo se quiser desativar o hibernate (libera vários GBs):
# powercfg /h off

# ==============================================================================
Write-Secao "LIMPEZA FINAL"
# ==============================================================================

Write-Host "  [-] Executando Limpeza de Disco..." -ForegroundColor Yellow
cleanmgr /sagerun:1 2>$null

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  PRONTO! Reinicie o computador." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
