# ==========================================
#      Razer Razor Cleanup Script v1.1
# ==========================================

# This PowerShell script will safely remove all Razer, Inc. software from a Windows 10 or 11 PC.

# Check to ensure we are running as Admin...
if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "Admin privileges required. Please right-click this script and select 'Run as Administrator'."
    Start-Sleep -Seconds 5
    Break
}

# Create logfile and begin logging...
$logFile = "$env:USERPROFILE\Desktop\RazerCleanup_Log.txt"
Start-Transcript -Path $logFile -Force
Write-Host "Log file created at: $logFile" -ForegroundColor Gray

function Ask-User ($prompt) {
    $confirmation = Read-Host "$prompt [Y/N]"
    return ($confirmation -eq 'Y' -or $confirmation -eq 'y')
}

Write-Host "`n=== RAZER DEEP CLEANUP UTILITY ===" -ForegroundColor Cyan
Write-Host "This script will remove Razer software, drivers, files, and registry keys."
Write-Host "Ensure your mouse/keyboard are plugged in; they will revert to basic Windows drivers."

# Now, safety first! Offer a Restore Point...
if (Ask-User "Do you want to create a System Restore Point before continuing? (Recommended)") {
    Write-Host "Creating Restore Point (this may take a moment)..." -ForegroundColor Yellow
    try {
        Checkpoint-Computer -Description "Pre-Razer Cleanup" -RestorePointType "MODIFY_SETTINGS" -ErrorAction Stop
        Write-Host "Restore point created successfully." -ForegroundColor Green
    }
    catch {
        Write-Warning "Error creating restore point: $($_.Exception.Message)"
        if (Ask-User "System Restore might be disabled.  Do you want to proceed anyway?") {
            # User chose to proceed without restore point
        }
        else {
            Stop-Transcript
            exit
        }
    }
}

# Main Execution
# Phase 1 - Stopping processes and services...
Write-Host "`n[PHASE 1] Processes and Services" -ForegroundColor Magenta
if (Ask-User "Stop all Razer processes and services?") {
    # Services
    $services = Get-Service | Where-Object { $_.DisplayName -like "*Razer*" -or $_.Name -like "*Razer*" }
    if ($services) {
        foreach ($s in $services) {
            Write-Host "Stopping Service: $($s.Name)..."
            Stop-Service -Name $s.Name -Force -ErrorAction SilentlyContinue
            Write-Host "Disabling Service: $($s.Name)..."
            Set-Service -Name $s.Name -StartupType Disabled -ErrorAction SilentlyContinue
        }
    } else { Write-Host "No active Razer services found." -ForegroundColor Gray }

    # Processes
    $procs = Get-Process | Where-Object { $_.ProcessName -like "Razer*" }
    if ($procs) {
        $procs | ForEach-Object { 
            Write-Host "Killing Process: $($_.ProcessName)..."
            Stop-Process -Id $_.Id -Force -ErrorAction SilentlyContinue 
        }
    } else { Write-Host "No active Razer processes found." -ForegroundColor Gray }
}

# Phase 2 - Removing scheduled tasks...
Write-Host "`n[PHASE 2] Scheduled Tasks" -ForegroundColor Magenta
$tasks = Get-ScheduledTask | Where-Object { $_.TaskName -like "*Razer*" -or $_.TaskPath -like "*Razer*" }
if ($tasks) {
    Write-Host "Found $($tasks.Count) Razer scheduled tasks."
    if (Ask-User "Remove these tasks?") {
        foreach ($t in $tasks) {
            Write-Host "Removing Task: $($t.TaskName)..."
            Unregister-ScheduledTask -TaskName $t.TaskName -Confirm:$false -ErrorAction SilentlyContinue
        }
    }
} else { Write-Host "No Razer scheduled tasks found." -ForegroundColor Gray }

# Phase 3 - Uninstalling any apps...
Write-Host "`n[PHASE 3] Application Uninstallation" -ForegroundColor Magenta
$apps = Get-Package -Name "*Razer*" -ErrorAction SilentlyContinue
if ($apps) {
    Write-Host "Found installed applications: $($apps.Name -join ', ')"
    if (Ask-User "Attempt to uninstall these applications via Windows?") {
        foreach ($app in $apps) {
            Write-Host "Uninstalling $($app.Name)..."
            Uninstall-Package -InputObject $app -Force -ErrorAction SilentlyContinue
        }
    }
} else { Write-Host "No installed Razer applications found via Package Manager." -ForegroundColor Gray }

# Phase 4 - Driver removal...
Write-Host "`n[PHASE 4] Driver Store Cleanup (Deep Clean)" -ForegroundColor Magenta
# Get all OEM drivers that list "Razer" as the provider
$drivers = Get-WindowsDriver -Online -All | Where-Object { $_.ProviderName -like "*Razer*" -or $_.OriginalFileName -like "*raz*" }
if ($drivers) {
    Write-Host "Found $($drivers.Count) Razer drivers in the Windows Driver Store."
    $drivers | Select-Object Driver, ProviderName, Date, Version | Format-Table -AutoSize | Out-String | Write-Host
    
    if (Ask-User "Attempt to remove these drivers from the Driver Store?") {
        foreach ($d in $drivers) {
            Write-Host "Removing driver $($d.Driver) ($($d.ProviderName))..."
            # pnputil is the native tool for this
            & pnputil /delete-driver $d.Driver /uninstall /force | Out-Null
        }
    }
} else { Write-Host "No Razer drivers found in Driver Store." -ForegroundColor Gray }

# Phase 5 - File system cleanup...
Write-Host "`n[PHASE 5] File System" -ForegroundColor Magenta
$paths = @(
    "$env:ProgramFiles\Razer",
    "${env:ProgramFiles(x86)}\Razer",
    "$env:ProgramData\Razer",
    "$env:AppData\Razer",
    "$env:LocalAppData\Razer",
    "C:\ProgramData\Razer"
)
$foundPaths = $paths | Where-Object { Test-Path $_ }

if ($foundPaths) {
    Write-Host "Found residual folders:"
    $foundPaths | ForEach-Object { Write-Host " - $_" }
    if (Ask-User "Delete these folders permanently?") {
        foreach ($p in $foundPaths) {
            Write-Host "Deleting $p..."
            Remove-Item -Recurse -Force $p -ErrorAction SilentlyContinue
        }
    }
} else { Write-Host "No residual folders found." -ForegroundColor Gray }

# Phase 6 - Registry Cleanup...
Write-Host "`n[PHASE 6] Registry" -ForegroundColor Magenta
$regKeys = @(
    "HKLM:\SOFTWARE\Razer",
    "HKLM:\SOFTWARE\WOW6432Node\Razer",
    "HKCU:\Software\Razer"
)
$foundKeys = $regKeys | Where-Object { Test-Path $_ }

if ($foundKeys) {
    Write-Host "Found registry keys:"
    $foundKeys | ForEach-Object { Write-Host " - $_" }
    if (Ask-User "Delete these registry keys?") {
        foreach ($k in $foundKeys) {
            Write-Host "Deleting $k..."
            Remove-Item -Recurse -Force $k -ErrorAction SilentlyContinue
        }
    }
} else { Write-Host "No registry keys found." -ForegroundColor Gray }

# Complete log and prompt for restart
Stop-Transcript
Write-Host "`n=== CLEANUP COMPLETE ===" -ForegroundColor Green
Write-Host "A log of this session has been saved to your Desktop."
if (Ask-User "Would you like to restart the computer now to finalize changes?") {
    Restart-Computer -Force
}