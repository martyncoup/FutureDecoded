Import-Module AzureRm

# Login to Microsoft Azure
Login-AzureRmAccount

# Select subscription
Select-AzureRmSubscription -SubscriptionName "inframon - future decoded"

# Deploy SQL Server
New-AzureRmResourceGroupDeployment -ResourceGroupName "RG-EUN-FutureDecoded" `
    -Name "InstallSQLServer2016" `
    -TemplateUri "https://saeunfdartifacts.blob.core.windows.net/scripts/DeploySQLServer2016.json" `
    -VMName "FDDEMSQL01" `
    -Verbose

# Deploy ConfigMgr
New-AzureRmResourceGroupDeployment -ResourceGroupName "RG-EUN-FutureDecoded" `
    -Name "InstallConfigMgr1606" `
    -TemplateUri "https://saeunfdartifacts.blob.core.windows.net/scripts/DeployConfigMgr1606.json" `
    -VMName "FDDEMCM01" `
    -Verbose