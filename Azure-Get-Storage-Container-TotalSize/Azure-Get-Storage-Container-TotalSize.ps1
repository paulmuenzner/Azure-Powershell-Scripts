<#
.SYNOPSIS
This PowerShell script calculates the total size of all blobs within a specified Azure storage container.

.NOTES
Requires Az.Accounts Azure PowerShell module for working with Azure Active Directory (AAD) authentication. This module provides cmdlets for connecting to Azure using your AAD credentials and managing various aspects of Azure AD, including service principals and role assignments.
Replace placeholders like "YourStorageAccountName" and "YourContainerName" with your actual values.
Implement logging for troubleshooting purposes.

Name: Azure-Get-Storage-Container-TotalSize
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.DESCRIPTION
Features:
Secure authentication: Use Azure Active Directory (AAD) authentication for enhanced security instead of using storage account keys directly.
Robust error handling: Employs a try-catch block to gracefully handle potential errors during blob retrieval.
Clear calculations: Accurately iterates through blobs, accumulates their sizes, and converts the total to kilobytes with formatted output.

#>


# Define storage account and container details (replace with placeholders)
$storageAccountName = "<YourStorageAccountName>"
$containerName = "<YourContainerName>"

# Connect to Azure (if not already connected)
Connect-AzAccount

try {
  # Use DefaultAzureCredential for AAD authentication
  $credential = New-Object System.Management.Automation.DefaultAzureCredential

  # Create a storage context with AAD credentials
  $context = New-AzStorageContext -StorageAccountName $storageAccountName -Credential $credential

  # Get all blobs in the specified container
  $blobs = Get-AzStorageBlob -Context $context -Container $containerName -Blob *

  # Initialize total size variable
  $totalSize = 0

  # Calculate the total size of all blobs
  foreach ($blob in $blobs) {
    $totalSize += $blob.Properties.Length
  }

  # Convert bytes to kilobytes with formatting
  $totalSizeKB = $totalSize / 1KB
  Write-Output "Total Size of Blobs in Container '{0}': {1:0.0} KB", $containerName, $totalSizeKB
}
catch {
  Write-Error "Error: An error occurred while retrieving blob information. $_"
}
