<#
.SYNOPSIS
Deletes empty containers from a storage account protected with Azure Active Directory (AAD).

.DESCRIPTION
This script connects to Azure, retrieves containers within a specified storage account, and deletes any container that is empty. 
It handles potential authorization errors by returning informative messages.

.NOTES
Requires Az.Accounts and Az.Storage modules for Azure cmdlets.

Name: Delete-Empty-Storage-Containers-AAD
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.EXAMPLE
Applying the script
1. Update variables like resource group name, storage account name, and Azure AD application details (ClientId, TenantId, and SubscriptionId).
2. Ensure the script has appropriate access (Contributor or Storage Blob Data Contributor role) to the storage account.
3. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
4. Then, execute the script by typing the following command:
.\Delete-Empty-Storage-Containers-AAD.ps1
#>

# Connect to Azure (if not already connected)
Connect-AzAccount

# Resource group and storage account names
$resourceGroup = "Your-Resource-Group"
$storageAccountName = "Your-Storage-Account-Name"

# Azure AD application details (replace with yours)
$aadClientId = "Your-Azure-AD-Application-ClientId"
$aadTenantId = "Your-Azure-AD-Tenant-Id"
$aadSubscriptionId = "Your-Azure-AD-Subscription-Id"

# Authenticate with Azure AD (replace with your application registration details)
$context = New-AzContext -SubscriptionId $aadSubscriptionId -AadClientId $aadClientId -AadTenantId $aadTenantId

# Get all containers in the storage account
try {
  $containers = Get-AzStorageContainer -Context $context -AccountName $storageAccountName
} catch {
  Write-Error "Error retrieving containers: $($_.Exception.Message)"
  exit
}

# Loop through each container and delete empty ones
foreach ($container in $containers) {
  $blobCount = (Get-AzStorageBlob -Context $context -Container $container.Name).Count
  if ($blobCount -eq 0) {
    Write-Host "Deleting empty container: $container.Name"
    try {
      Remove-AzStorageContainer -Context $context -Name $container.Name
    } catch {
      Write-Error "Error deleting container '$container.Name': $($_.Exception.Message)"
    }
  }
}

Write-Host "Script completed!"
