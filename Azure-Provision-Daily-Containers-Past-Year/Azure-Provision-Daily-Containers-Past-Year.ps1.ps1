<#
.SYNOPSIS
Creates a storage account with system-assigned managed identity and a container for each day in the last year from today.

.DESCRIPTION
This script creates a storage account with system-assigned managed identity in the specified resource group and location.
It then iterates through the last year and creates a container named in YYYYMMDD format for each day.

.NOTES
Requires Az.Accounts and Az.Storage modules for Azure cmdlets.

Name: Azure-Provision-Daily-Containers-Past-Year
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.EXAMPLE
Applying the script
1. Update variables like resource group name, location, and storage account name.
2. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
3. Then, execute the script by typing the following command:
.\Azure-Provision-Daily-Containers-Past-Year.ps1
#>

# Connect to Azure (if not already connected)
Connect-AzAccount

# Resource group and location (Replace placeholders)
$resourceGroup = "Your-Resource-Group"
$location = "East US"

# Storage account name
$storageAccountName = "storageaccount-$(Get-Random -String A-Za-z0-9 -Count 10)"

# Get start and end dates for the last year
$startDate = (Get-Date).AddYears(-1)
$endDate = Get-Date

# Create resource group (if it doesn't exist)
New-AzResourceGroup -Name $resourceGroup -Location $location -ErrorAction SilentlyContinue

# Create storage account with system-assigned managed identity
New-AzStorageAccount -Name $storageAccountName -ResourceGroupName $resourceGroup -Location $location -SkuName Standard_LRS -Kind StorageV2 -Identity (New-AzIdentity)

# Loop through each day in the last year
foreach ($date in (Get-Date ($startDate)..$endDate)) {
  $containerName = $date.ToString("yyyyMMdd")
  New-AzStorageContainer -Context (Get-AzStorageAccount -ResourceGroupName $resourceGroup -Name $storageAccountName) -Name $containerName
  Write-Host "Created container: $containerName"
}

Write-Host "Storage account '$storageAccountName' and containers created successfully!"
