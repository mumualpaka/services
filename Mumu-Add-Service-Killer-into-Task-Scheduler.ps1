# --- Mumu-Service-Killer Installer (One-Time Startup Version) ---
# This registers the task to run only once when the system boots up.

# 1. Detect the current folder
$PSScriptRoot = Get-Location
$ScriptFile = "Mumu-Startup-Service-Killer.ps1"
$FullScriptPath = Join-Path -Path $PSScriptRoot -ChildPath $ScriptFile

# Check if the logic script exists
if (-not (Test-Path $FullScriptPath)) {
    Write-Host "Error: $ScriptFile not found in $PSScriptRoot" -ForegroundColor Red
    return
}

# 2. Define the Action
$Action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File '$FullScriptPath'"

# 3. Define the Trigger: Run at System Startup only
$Trigger = New-ScheduledTaskTrigger -AtStartup

# 4. Define the Settings
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -ExecutionTimeLimit (New-TimeSpan -Hours 0)

# 5. Register the Task
Register-ScheduledTask -TaskName "Mumu-Service-Killer" `
    -Action $Action `
    -Trigger $Trigger `
    -Settings $Settings `
    -User "System" `
    -RunLevel Highest `
    -Force

Write-Host "Task 'Mumu-Service-Killer' successfully registered." -ForegroundColor Green
Write-Host "The script will run once every time the computer starts." -ForegroundColor Cyan