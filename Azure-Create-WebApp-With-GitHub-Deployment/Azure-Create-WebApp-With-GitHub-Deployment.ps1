<#
.SYNOPSIS
Deploys an Azure Web App with GitHub integration.

.NOTES
The provided script focuses on automating the deployment process through configuration, but it doesn't directly handle the actual deployment of app code. Here's how the script sets the stage for deployment:

Resource Creation: It checks and creates essential Azure resources needed for the Web App, including:
--Resource Group: A logical container for organizing Azure resources.
--App Service Plan: Defines the pricing tier, OS, and scaling configuration for the Web App.
--Web App: The actual application hosting environment within the App Service plan.
GitHub Integration: The script configures the Web App to use a GitHub repository as its source control. This establishes a connection between your code in GitHub and the deployment environment.

Once these configurations are complete, the script doesn't directly trigger a deployment.

Name: Azure-Create-WebApp-With-GitHub-Deployment
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.DESCRIPTION
This script automates the deployment of an Azure Web App from a GitHub repository. 
It checks and creates necessary resources, such as the resource group, App Service plan, and Web App.



.EXAMPLE
Applying the script
1. Define variables like $repositoryUrl, $appName, $region, and $resourceGroupName with your values.
2. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
3. Execute the script by typing the following command:
  .\Azure-Create-WebApp-With-GitHub-Deployment.ps1

#>

# Define variables
$repositoryUrl = "<repo url goes here>"
$appName = "<web app name goes here>"
$region = "<location goes here>"
$resourceGroupName = "<resource name goes here>"

# Login to Azure (using Az module)
Connect-AzAccount -ErrorAction Stop

# Check if the resource group already exists; if not, create a new one
try {
  $existingResourceGroup = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue
  if (!$existingResourceGroup) {
    New-AzResourceGroup -Name $resourceGroupName -Location $region -ErrorAction Stop
    Write-Host "Resource group '$resourceGroupName' created successfully."
  } else {
    Write-Host "Resource group '$resourceGroupName' already exists."
  }
} catch {
  Write-Error "Error checking or creating resource group: $_"
  return
}

# Create the 'Free' tier App Service plan if it doesn't exist
try {
  $existingAppServicePlan = Get-AzAppServicePlan -ResourceGroupName $resourceGroupName -Name $appName -ErrorAction SilentlyContinue
  if (!$existingAppServicePlan) {
    New-AzAppServicePlan -Name $appName -Location $region -ResourceGroupName $resourceGroupName -Tier Free -ErrorAction Stop
    Write-Host "App Service plan '$appName' created successfully."
  } else {
    Write-Host "App Service plan '$appName' already exists."
  }
} catch {
  Write-Error "Error checking or creating App Service plan: $_"
  return
}

# Create the web app if it doesn't exist
try {
  $existingWebApp = Get-AzWebApp -ResourceGroupName $resourceGroupName -Name $appName -ErrorAction SilentlyContinue
  if (!$existingWebApp) {
    New-AzWebApp -Name $appName -Location $region -AppServicePlan $appName -ResourceGroupName $resourceGroupName -ErrorAction Stop
    Write-Host "Web App '$appName' created successfully."
  } else {
    Write-Host "Web App '$appName' already exists."
  }
} catch {
  Write-Error "Error checking or creating Web App: $_"
  return
}

# Configure GitHub deployment from your GitHub repo and deploy once
try {
  $propertiesObject = @{
    repoUrl = "$repositoryUrl";
    branch = "master";
    isManualIntegration = $true;  # By setting isManualIntegration to $true, the script configures manual deployment. This means any code changes pushed to the specified branch in your GitHub repository will trigger a deployment.
  }
  Set-AzResource -PropertyObject $propertiesObject `
          -ResourceGroupName $resourceGroupName `
          -ResourceType Microsoft.Web/sites/sourcecontrols `
          -ResourceName "$appName/web" `
          -ApiVersion 2023-11-01 -Force -ErrorAction Stop

  Write-Host "GitHub deployment configured for Web App '$appName'."
} catch {
  Write-Error "Error configuring GitHub
