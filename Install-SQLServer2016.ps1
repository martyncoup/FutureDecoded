# Initialise and format disks
Initialize-Disk -Number 2
New-Partition -DiskNumber 2 -UseMaximumSize -DriveLetter G
Format-Volume -DriveLetter G

# Create local directories
New-Item -Path "D:\SQLTemp" -ItemType Directory -Force
New-Item -Path "D:\Download" -ItemType Directory -Force

# Download and extract the installer binaries
$Web = New-Object System.Net.WebClient
$Web.DownloadFile("https://saeunfdartifacts.blob.core.windows.net/sql/SQLServer2016.iso", "D:\Download\SQLServer2016.iso")
$Web.DownloadFile("https://saeunfdartifacts.blob.core.windows.net/scripts/ConfigurationFile.ini", "D:\Download\ConfigurationFile.ini")
$Web.DownloadFile("https://saeunfdartifacts.blob.core.windows.net/scripts/SQLCredentials.auth.json", "D:\Download\SQLCredentials.auth.json")

# Load credentials
$Creds = Get-ChildItem "D:\Download\*.auth.json" | Get-Content | ConvertFrom-Json

# Install Windows Features
Install-WindowsFeature "NET-Framework-Core", "NET-Framework-45-Core"

# Add Local Admin
$Group = [ADSI]"WinNT://./Administrators,group"
$Computer = [ADSI]"WinNT://FD.DEMO/FDDEMCM01$"
$Group.Add($Computer.Path)

# Mount SQL Server ISO and get the drive letter
$DriveLetter = (Mount-DiskImage -ImagePath "D:\Download\SQLServer2016.iso" -PassThru | Get-Volume).DriveLetter + ":"

# Install SQL Server
Invoke-Expression "$($DriveLetter)\Setup.exe /ConfigurationFile=D:\Download\ConfigurationFile.ini /SQLSVCPASSWORD=$($Creds.SQLServicePassword) /AGTSVCPASSWORD=$($Creds.AgentServicePassword)"

# Unmount the SQL Server ISO and cleanup
Dismount-DiskImage -ImagePath "D:\Download\SQLServer2016.iso"
Remove-Item "D:\Download" -Force -Recurse