# ==============================================================================
#  Windows 11 - Remove Microsoft Edge - EN-US
#  PHASE 2 SCRIPT — Run AFTER installing Chrome or Firefox.
#
#  HOW TO RUN:
#    Right-click > "Run with PowerShell"
#    OR in PowerShell as Administrator:
#       Set-ExecutionPolicy Bypass -Scope Process -Force; .\Remove_Edge_EN.ps1
# ==============================================================================

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

# ==============================================================================
Write-Section "CLOSING EDGE PROCESSES"
# ==============================================================================

Write-Host "  [-] Killing Edge processes..." -ForegroundColor Yellow
Get-Process -Name "msedge", "MicrosoftEdge", "MicrosoftEdgeUpdate" | Stop-Process -Force

Start-Sleep -Seconds 2

# ==============================================================================
Write-Section "REMOVING EDGE VIA SETUP.EXE (Main method)"
# ==============================================================================

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
                Write-Host "  [-] Found Edge version: $($ver.Name)" -ForegroundColor Yellow
                Write-Host "  [-] Running uninstaller..." -ForegroundColor Yellow
                Start-Process -FilePath $installer -ArgumentList "--uninstall --system-level --verbose-logging --force-uninstall" -Wait
                $removed = $true
            }
        }
    }
}

if (-not $removed) {
    Write-Host "  [!] setup.exe not found. Trying winget..." -ForegroundColor Magenta
    winget uninstall --id Microsoft.Edge --silent --accept-source-agreements
}

# ==============================================================================
Write-Section "REMOVING EDGE WEBVIEW2 (optional but recommended)"
# ==============================================================================
# WebView2 is used by some apps, but safe to remove on a clean machine.
# Comment out this section if you want to keep it.

Write-Host "  [-] Removing Edge WebView2 Runtime..." -ForegroundColor Yellow
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

# ==============================================================================
Write-Section "BLOCKING EDGE FROM REINSTALLING ITSELF"
# ==============================================================================

Write-Host "  [-] Disabling Edge update tasks..." -ForegroundColor Yellow
$edgeTasks = @(
    "\Microsoft\MicrosoftEdge\MicrosoftEdgeUpdateTaskMachineCore",
    "\Microsoft\MicrosoftEdge\MicrosoftEdgeUpdateTaskMachineUA",
    "\Microsoft\MicrosoftEdge\BrowserUpdateDaemonCore",
    "\Microsoft\MicrosoftEdge\BrowserUpdateDaemonUA"
)
foreach ($task in $edgeTasks) {
    Disable-ScheduledTask -TaskName $task -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "  [-] Disabling Edge Update service..." -ForegroundColor Yellow
Stop-Service "edgeupdate" -Force
Set-Service "edgeupdate" -StartupType Disabled
Stop-Service "edgeupdatem" -Force
Set-Service "edgeupdatem" -StartupType Disabled

Write-Host "  [-] Blocking Edge auto-reinstall via registry..." -ForegroundColor Yellow
$edgeBlockPath = "HKLM:\SOFTWARE\Microsoft\EdgeUpdate"
If (!(Test-Path $edgeBlockPath)) { New-Item -Path $edgeBlockPath -Force | Out-Null }
Set-ItemProperty -Path $edgeBlockPath -Name "DoNotUpdateToEdgeWithChromium" -Value 1 -Type DWord

# Prevent Windows Update from silently pushing Edge back
$auPath = "HKLM:\SOFTWARE\Policies\Microsoft\EdgeUpdate"
If (!(Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
Set-ItemProperty -Path $auPath -Name "InstallDefault" -Value 0 -Type DWord

Write-Host "  [-] Removing Edge from startup..." -ForegroundColor Yellow
Remove-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue
Remove-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run" -Name "MicrosoftEdgeAutoLaunch*" -ErrorAction SilentlyContinue

# ==============================================================================
Write-Section "CLEANING UP LEFTOVER FOLDERS"
# ==============================================================================

Write-Host "  [-] Removing Edge leftover data..." -ForegroundColor Yellow
Remove-Item "$env:LocalAppData\Microsoft\Edge" -Force -Recurse
Remove-Item "$env:ProgramData\Microsoft\EdgeUpdate" -Force -Recurse
Remove-Item "$env:ProgramFiles\Microsoft\Edge" -Force -Recurse
Remove-Item "${env:ProgramFiles(x86)}\Microsoft\Edge" -Force -Recurse
Remove-Item "${env:ProgramFiles(x86)}\Microsoft\EdgeUpdate" -Force -Recurse

Write-Host ""
Write-Host "======================================" -ForegroundColor Green
Write-Host "  Edge removed! Restart recommended." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Green
Write-Host ""
