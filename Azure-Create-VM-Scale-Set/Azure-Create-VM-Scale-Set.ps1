<#
.SYNOPSIS
Creates a virtual machine scale set with Ubuntu Server in Azure, utilizing a custom script extension stored in a container. Managed identity is enabled for the VMs, and network security groups are configured for SSH access from a specific IP and HTTP traffic.

.NOTES
Requires the Az.Accounts and Az.Compute modules for Azure cmdlets.

Name: Azure-Create-VM-Scale-Set
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.DESCRIPTION
This script automates the deployment of a virtual machine scale set in Azure. It leverages the following features:

Resource group creation
Virtual network, subnet, public IP, and load balancer configuration
Ubuntu Server VM scale set creation with managed identity
Custom script extension deployment from Azure storage container
Network security group rules for secure access
Important Notes:

Replace placeholder names with your desired values.
Update the scriptBlobUri variable with the actual URL of your custom script.
Consider error handling for increased robustness.
Provide custom script in storage account

.EXAMPLE
Applying the script
Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script. 
Then, execute the script by typing the following command:
.\Azure-Create-VM-Scale-Set.ps1

#>



# Connect to Azure (if not already connected)
Connect-AzAccount

# Resource group and location
$resourceGroup = "Your-Project-Resource-Group"
$location = "East US"

# Create resource group
New-AzResourceGroup -Name $resourceGroup -Location $location

# Network, subnet, load balancer, and public IP placeholder names
$virtualNetworkName = "Your-VNet-Name"
$subnetName = "Your-Subnet-Name"
$loadBalancerName = "Your-LB-Name"
$publicIpName = "Your-Public-IP-Name"
$ipWhitelist = "111.111.111.0/24"  # White-listed CIDR notation for port 22 Adjust based on your specific IP range

# Storage account details (replace with your values)
$storageAccountName = "Your-Storage-Account-Name"
$containerName = "Your-Container-Name"
$customScriptName = "Your-Script.ps1"
$scriptBlobUri = "https://$storageAccountName.blob.core.windows.net/$containerName/$customScriptName"

# Virtual machine scale set configuration
$vmssName = "Your-Scale-Set-Name"
$vmssSize = "Standard_DS1_v2"  # Example VM size, adjust as needed

# Create virtual network, subnet, and public IP address
New-AzVirtualNetwork -Name $virtualNetworkName -ResourceGroupName $resourceGroup -Location $location -AddressPrefix 10.0.0.0/16
New-AzVirtualNetworkSubnetConfig -Name $subnetName -AddressPrefix 10.0.0.0/24 -VirtualNetwork $virtualNetworkName
$virtualNetwork | Set-AzVirtualNetwork
New-AzPublicIpAddress -Name $publicIpName -ResourceGroupName $resourceGroup -Location $location -AllocationMethod Dynamic

# Create load balancer
New-AzLoadBalancer -ResourceGroupName $resourceGroup -Name $loadBalancerName -Location $location -FrontendIpConfiguration $publicIpName

# Create virtual machine scale set with managed identity
New-AzVmss `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -VMScaleSetName $vmssName `
    -VirtualNetworkName $virtualNetworkName `
    -SubnetName $subnetName `
    -PublicIpAddressName $publicIpName `
    -LoadBalancerName $loadBalancerName `
    -UpgradePolicyMode "Automatic" `
    -ImageOffer "UbuntuServer" `
    -ImageSku "20.04-LTS" `
    -ImagePublisher "Canonical" `
    -InstanceSize $vmssSize `
    -AssignIdentity

# Create network security group rules
$nsg = New-AzNetworkSecurityGroup `
    -ResourceGroupName $resourceGroup `
    -Location $location `
    -Name "Your-NSG-Name"

New-AzNetworkSecurityRuleConfig `
    -Name "AllowSSHFromWhitelist" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 100 `
    -SourceAddressPrefix $sourceIpPrefix `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 22 `
    -Access Allow `
    | Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg

New-AzNetworkSecurityRuleConfig `
    -Name "AllowHTTP" `
    -Protocol Tcp `
    -Direction Inbound `
    -Priority 110 `
    -SourceAddressPrefix * `
    -SourcePortRange * `
    -DestinationAddressPrefix * `
    -DestinationPortRange 80 `
    -Access Allow `
    | Add-AzNetworkSecurityRuleConfig -NetworkSecurityGroup $nsg

# Associate NSG with subnet
$subnet = $virtualNetwork.Subnets | Where-Object Name -eq $subnetName
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $virtualNetwork -Name $subnetName -AddressPrefix $subnet.AddressPrefix -NetworkSecurityGroup $nsg
Set-AzVirtualNetwork -VirtualNetwork $virtualNetwork

# Apply custom script extension
$publicSettings = @{
    "fileUris" = @($scriptBlobUri);
    "commandToExecute" = "powershell -ExecutionPolicy Unrestricted -File $($customScriptName)"
}
Add-AzVmssExtension -VirtualMachineScaleSet $vmss `
    -Name "CustomScriptExtension" `
    -Publisher "Microsoft.Compute" `
    -Type "CustomScriptExtension" `
    -TypeHandlerVersion 1.8 `
    -Setting $publicSettings
Update-AzVmss -ResourceGroupName $resourceGroup -Name $vmssName -VirtualMachineScaleSet $vmss
