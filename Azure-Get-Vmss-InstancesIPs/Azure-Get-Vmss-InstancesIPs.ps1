<#
.SYNOPSIS
Lists IP addresses of all instances in an Azure VM scale set within a virtual network behind a load balancer.

.DESCRIPTION
This script retrieves information about a VM scale set, its virtual network, and the associated load balancer. 
It then iterates through the VM instances in the scale set and leverages the load balancer backend pool to determine the private IP address 
assigned to each instance.

.NOTES
Requires Az.Accounts, Az.Compute, and Az.Network modules for Azure cmdlets.

Name: Azure-Get-Vmss-InstancesIPs
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.EXAMPLE
Applying the script
1. Update variables like resource group name, VM scale set name, and load balancer name.
2. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
3. Then, execute the script by typing the following command:
.\Azure-Get-Vmss-InstancesIPs.ps1
#>

# Connect to Azure (if not already connected)
Connect-AzAccount

# Resource group name, VM scale set name, and load balancer name (update these)
$resourceGroup = "Your-Resource-Group"
$vmssName = "Your-Vmss-Name"
$loadBalancerName = "Your-LoadBalancer-Name"

# Get VM scale set
try {
  $vmss = Get-AzVmScaleSet -ResourceGroupName $resourceGroup -Name $vmssName
} catch {
  Write-Error "Error retrieving VM scale set: $($_.Exception.Message)"
  return
}

# Get load balancer backend pool
try {
  $backendPool = Get-AzLoadBalancerBackendAddressPool -LoadBalancerName $loadBalancerName -ResourceGroupName $resourceGroup
} catch {
  Write-Error "Error retrieving load balancer backend pool: $($_.Exception.Message)"
  return
}

# Get all VM instances in the scale set
$vmssInstances = Get-AzVmScaleSetVM -ResourceGroupName $resourceGroup -VmScaleSetName $vmssName

# Loop through each instance and find its IP address
Write-Host "Listing IP addresses of VM instances behind load balancer:"
foreach ($vmInstance in $vmssInstances) {
  # Find backend address pool IP configuration associated with the instance
  $instanceIpConfig = $backendPool.BackendAddressConfigurations | Where-Object { $_.Id -match $vmInstance.InstanceId }
  if ($instanceIpConfig) {
    $privateIpAddress = $instanceIpConfig.IpAddress
    Write-Host "  - VM Instance ID: $vmInstance.InstanceId, Private IP: $privateIpAddress"
  } else {
    Write-Warning "  - VM Instance ID: $vmInstance.InstanceId, IP address not found in load balancer backend pool."
  }
}

Write-Host "Script execution completed."
