<#
.SYNOPSIS
Configures a Windows VM Scale Set in Azure to use custom autoscale with a scaling rule based on CPU utilization.

.NOTES
Requires the Az.Compute module for working with VM Scale Sets (Install-Module Az.Compute).

Name: Azure-Vmss-Add-Autoscale-Rule
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.DESCRIPTION
This script modifies a VM Scale Set to leverage custom autoscale. 
It checks if custom autoscale is already configured and only applies changes if necessary.

The script then creates a scaling rule named "HighCpuScaleRule" that triggers adding new VMs to the VMSS if the average CPU usage exceeds 75% for a duration of 10 minutes (PT10M). 
Additionally, it sets optional instance limits for the VMSS (minimum and maximum instances).

.EXAMPLE
Applying the script
Open a PowerShell window with administrator privileges.
Navigate to the directory where you saved the script (e.g., .\Azure-Vmss-Add-Autoscale-Rule.ps1).
Execute the script.

#>


# Define variables (replace with placeholders)
$resourceGroupName = "Your-Resource-Group"
$vmssName = "Your-VMSS-Name"

# Connect to Azure (ensure you're logged in)
Connect-AzAccount

# Get the VM Scale Set
$vmss = Get-AzVmss -ResourceGroupName $resourceGroupName -Name $vmssName

# Check if custom autoscale is already configured
$hasCustomScale = ($vmss.Sku.Capacity.ScalingPolicy & "Custom") -eq "Custom"

if (!$hasCustomScale) {
  # Configure custom autoscale if not already set
  $vmss.Sku.Capacity.ScalingPolicy = "Custom"
  $vmss.Sku.Capacity.InstanceDeletionPolicy = "Default"  # Optional: Set instance deletion policy (Default:OnDelete)
  $vmss = Set-AzVmss -ResourceGroupName $resourceGroupName -Name $vmssName -Vmss $vmss

  # Create a scale rule for adding VMs on high CPU
  $ruleName = "HighCpuScaleRule"
  $scaleRule = New-AzVmssScaleRuleObject -Name $ruleName -MetricName "Percentage CPU" -Operator "GreaterThan" -Statistic "Average" -TimeGrain "PT10M" -Threshold 75 -ScaleActionCooldown "PT10M" -ScaleActionDirection "Increase" -ScaleActionValue 1

  # Create a profile with the scale rule
  $profileName = "HighCpuAutoScale"
  $autoscaleProfile = New-AzVmssScaleProfileObject -Name $profileName -Rules ($scaleRule)

  # Set the autoscale profile for the VMSS
  $vmss.AutomaticScalingProfiles = @($autoscaleProfile)
  Set-AzVmss -ResourceGroupName $resourceGroupName -Name $vmssName -Vmss $vmss

  Write-Output "Custom autoscale with CPU scaling rule configured for VM Scale Set '$vmssName'"
} else {
  Write-Output "VM Scale Set '$vmssName' already uses custom autoscale. Skipping configuration."
}

# Set instance limits (optional, adjust values as needed)
$vmss.Sku.Capacity.DefaultMinInstanceCount = 1
$vmss.Sku.Capacity.DefaultMaxInstanceCount = 5
Set-AzVmss -ResourceGroupName $resourceGroupName -Name $vmssName -Vmss $vmss

Write-Output "VM Scale Set '$vmssName' instance limits set to Min: 1, Max: 5"
