# Initialise and format disks
Initialize-Disk -Number 2
New-Partition -DiskNumber 2 -UseMaximumSize -DriveLetter G
Format-Volume -DriveLetter G

# Create local directories
New-Item -Path "G:\ConfigMgr" -ItemType Directory -Force
New-Item -Path "D:\Download" -ItemType Directory -Force
New-Item -Path "D:\PreReq" -ItemType Directory -Force

# Download and extract the installer binaries
$Web = New-Object System.Net.WebClient
$Web.DownloadFile("https://saeunfdartifacts.blob.core.windows.net/configmgr/ConfigMgr1606.iso", "D:\Download\ConfigMgr1606.iso")
$Web.DownloadFile("https://saeunfdartifacts.blob.core.windows.net/scripts/ConfigMgr.ini", "D:\Download\ConfigMgr.ini")
$Web.DownloadFile("https://go.microsoft.com/fwlink/p/?LinkId=526740", "D:\Download\adksetup.exe")

# Install Windows Features
Install-WindowsFeature "NET-Framework-Core","BITS","BITS-IIS-Ext","BITS-Compact-Server","RDC","WAS-Process-Model","WAS-Config-APIs","WAS-Net-Environment","Web-Server","Web-ISAPI-Ext","Web-ISAPI-Filter","Web-Net-Ext","Web-Net-Ext45","Web-ASP-Net","Web-ASP-Net45","Web-ASP","Web-Windows-Auth","Web-Basic-Auth","Web-URL-Auth","Web-IP-Security","Web-Scripting-Tools","Web-Mgmt-Service","Web-Stat-Compression","Web-Dyn-Compression","Web-Metabase","Web-WMI","Web-HTTP-Redirect","Web-Log-Libraries","Web-HTTP-Tracing","UpdateServices-RSAT","UpdateServices-API","UpdateServices-UI"

# Install ADK
$Cmd = "D:\Download\adksetup.exe"
$Arguments = "/norestart /q /ceip off /features OptionId.WindowsPreinstallationEnvironment OptionId.DeploymentTools OptionId.UserStateMigrationTool"
Start-Process $Cmd $Arguments -Wait

# Mount ConfigMgr ISO and get the drive letter
$DriveLetter = (Mount-DiskImage -ImagePath "D:\Download\ConfigMgr1606.iso" -PassThru | Get-Volume).DriveLetter + ":"

# Download Prerequisites
$Cmd = "$($DriveLetter)\SMSSETUP\BIN\X64\setupdl.exe"
$Arguments = "D:\PreReq"
Start-Process $Cmd $Arguments -Wait

# Install Primary Site
$Cmd = "$($DriveLetter)\SMSSETUP\BIN\X64\setup.exe"
$Arguments = "/nouserinput /script D:\Download\ConfigMgr.ini"
Start-Process $Cmd $Arguments -Wait

# Unmount the ConfigMgr ISO and cleanup
Dismount-DiskImage -ImagePath "D:\Download\ConfigMgr1606.iso"
Remove-Item "D:\Download" -Force -Recurse
Remove-Item "D:\PreReq" -Force -Recurse