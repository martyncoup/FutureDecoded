# Set permissions for non system account
psexec.exe -i -s powershell.exe
Import-Module $Env:SMS_ADMIN_UI_PATH.Substring(0, $Env:SMS_ADMIN_UI_PATH.Length - 5) + "\ConfigurationManager.psd1"
Set-Location 'FD1:'
New-CMAdministrativeUser -Name "FD\adm-martync" -CollectionName "All Systems" -RoleName "Full Administrator"