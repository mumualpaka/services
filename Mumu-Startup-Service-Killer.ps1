# --- Mumu's Kill-Services Startup Script ---
# This targets services that tend to ignore standard disable commands

Start-Sleep -Seconds 10 # Gives the registry/services a moment to breathe, then start the killing

$targets = @(


    # --- Existing Targets ---
    "WlanSvc",               # WLAN AutoConfig (Only kill if using Ethernet/LAN)
    "LanmanServer",          # Workstation (Safe to kill if not using Network Sharing/NAS)
    "LanmanWorkstation",     # Workstation (Safe to kill if not using Network Sharing/NAS)
    "WpnUserService",        # Push Notifications (The "die-hard" one)
    "WbioSrvc",              # Biometric Service (Fingerprint/Face unlock)
    "NcbService",            # Network Connection Broker (Handles UWP app internet)
    "Wcmsvc",                # Windows Connection Manager
    "SharedAccess",          # Internet Connection Sharing
    "wuauserv",              # Windows Update
    "SENS",                  # System Event Notification
    "ShellHWDetection",      # Auto-play
    "iphlpsvc",              # IP Helper
    "NgcCtnrSvc",            # Microsoft Passport Container
    "NgcSvc"                 # Microsoft Passport
    "CamSvc"                 # Capability Access Manager Service
    "UdkUserSvc",            # User Data Kiddie Service (Universal Device Kit)
    "DispBrokerDesktopSvc",  # Display Policy Service


    # --- Additional New Findings can be Put Here ---
    "xusb22",           # Xbox 360 Controller Driver (Kill if not using old controllers)
    "xmlprov",          # Network Provisioning Service (Redundant on home/gaming PCs)
    "XblAuthManager",   # Xbox Live Auth (Kill if you don't use Xbox App/GamePass)
    "XblGameSave",      # Xbox Live Game Save (Kill if you don't use Xbox App/GamePass)
    "XboxNetApiSvc",    # Xbox Live Networking (Kill if you don't use Xbox App/GamePass)
    "XboxGipSvc",       # Xbox Accessory Management Service
    "RasMan",           # Remote Access Connection Manager (VPN infrastructure)
    "EapHost",          # Extensible Authentication Protocol (Often used for Enterprise Wi-Fi)
    "NetTcpPortSharing" # .NET TCP Port Sharing (Rarely used by games/local AI)
)

foreach ($service in $targets) {
    # Force Registry to Disabled (4)
    Reg add "HKLM\SYSTEM\CurrentControlSet\Services\$service" /v "Start" /t REG_DWORD /d 4 /f
    
    # Attempt to stop it immediately if it's already running
    Stop-Service -Name $service -Force -ErrorAction SilentlyContinue


}

foreach ($service in $targets) {
    # Force Registry to Disabled (4) for the base name and any suffixed clones
    Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\*" | Where-Object { $_.PSChildName -match "^$service(_[a-z0-9]+)?$" } | ForEach-Object {
        Reg add $_.Name /v "Start" /t REG_DWORD /d 4 /f
    }
}

Write-EventLog -LogName "Windows PowerShell" -Source "PowerShell" -EventID 101 -EntryType Information -Message "Aggressive Startup Service Kill Completed."