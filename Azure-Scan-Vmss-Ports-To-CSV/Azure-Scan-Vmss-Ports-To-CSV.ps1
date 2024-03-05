<#
.SYNOPSIS
Scans ports 1-1000 of a specified VM and writes open ports to a CSV file within an Azure storage container.

.DESCRIPTION
This script retrieves information about a VM, connects to it remotely, performs a port scan using Test-NetConnection,
and creates a CSV file with VM name, IP address, and open ports. The CSV file is then uploaded to a container in an Azure storage account.

.NOTES
Requires Az.Accounts, Az.Compute, Az.Storage modules for Azure cmdlets.
Requires Test-NetConnection cmdlet (available on Windows 10/11 or Windows PowerShell 5.1+).

Name: Azure-Scan-Vmss-Ports-To-CSV
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.EXAMPLE
Applying the script
1. Update variables like resource group name, VM name, storage account name, storage container name, and storage account key.
2. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
3. Then, execute the script by typing the following command:
.\Scan-Vmss-Ports-To-CSV.ps1
#>

# Connect to Azure (if not already connected)
Connect-AzAccount

# Resource group name, VM name, storage account details (update these)
$resourceGroup = "Your-Resource-Group"
$vmName = "Your-VM-Name"
$storageAccountName = "Your-Storage-Account-Name"
$storageContainerName = "Your-Container-Name"
$storageAccountKey = (Get-AzStorageAccountKey -ResourceGroupName $resourceGroup -StorageAccountName $storageAccountName)[0].Value

# Get VM object
try {
  $vm = Get-AzVM -ResourceGroupName $resourceGroup -Name $vmName
} catch {
  Write-Error "Error retrieving VM: $($_.Exception.Message)"
  return
}

# Validate Test-NetConnection availability
if (!(Test-Connection -ComputerName localhost -Count 1 -Quiet)) {
  Write-Error "Test-NetConnection cmdlet not available. Script requires Windows 10/11 or Windows PowerShell 5.1+"
  return
}

# Define port range to scan
$portRange = 1..1000

# Function to check open ports
function Test-VmPort {
  param (
    [Parameter(Mandatory = $true)]
    [string] $vmIpAddress,
    [int] $port
  )

  Test-NetConnection -ComputerName $vmIpAddress -Port $port -Count 1 -Quiet
}

# Create CSV file content
$csvContent = @()

foreach ($port in $portRange) {
  if (Test-VmPort -vmIpAddress $vm.IpAddress -port $port) {
    $csvContent += [PSCustomObject]@{
      "VM Name"    = $vm.Name
      "VM IP"      = $vm.IpAddress
      "Open Port"  = $port
    }
  }
}

# Create CSV file in memory
$csvBytes = ConvertTo-Csv $csvContent -NoTypeInformation | ConvertTo-Byte

# Connect to Azure storage account
$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccountKey

# Create container if it doesn't exist
try {
  New-AzStorageContainer -Context $storageContext -Name $storageContainerName -ErrorAction Stop
} catch {
  Write-Error "Error creating container '$storageContainerName': $($_.Exception.Message)"
  return
}

# Upload CSV file to container
$blobName = "vm-port-scan-$(Get-Date -Format yyyyMMdd-HHmmss).csv"
$blob = $storageContext.ForBlob($blobName)
$blob.UploadFromByteArray($csvBytes, $csvBytes.Length)

Write-Host "Port scan results for VM '$vmName' saved to CSV file: '$blobName' within container '$storageContainerName'."
Write-Host "Script execution completed."
