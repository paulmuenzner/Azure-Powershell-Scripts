<#
.SYNOPSIS
Custom Script Extension
Retrieves a secret from Azure Key Vault using managed identity and configures SSH to use it for GitHub deployments.

.NOTES
Requires the Az.Accounts module for managed identity operations (install with Install-Module Az.Accounts).
Replace placeholders like "YourKeyVaultName" and "deploy-key-secret" with your actual values.
Explore alternative secure storage methods for the deploy key instead of saving it as a file.
Implement logging for troubleshooting purposes.

Name: Azure-Custom-Script-Extension-Scale-Set
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.DESCRIPTION
This script securely retrieves a secret containing a deploy key from Azure Key Vault. It leverages managed identity for authentication and sets appropriate permissions on the downloaded key file. However, disabling StrictHostKeyChecking in SSH configuration is a security concern. Consider alternative security measures like trusted networks or host key pinning.

#>



# 1) Azure Key Vault details (Replace placeholders)
$keyVaultName = "YourKeyVaultName"
$secretName = "deploy-key-secret"

# 2) Fetch token using Managed Identity
$tokenUrl = "http://169.254.169.254/metadata/identity/oauth2/token"
$headers = @{
  "Metadata" = "true"
}
$tokenResponse = Invoke-RestMethod -Uri $tokenUrl -Headers $headers -Method POST -Body @{
  resource = "https://vault.azure.net"
} | Select-Object -ExpandProperty access_token
if (-not $tokenResponse) {
  Write-Error "Error: No access token retrieved"
  exit 1
}

# 3) Fetch secret from Key Vault using the token
$secretUrl = "https://${keyVaultName}.vault.azure.net/secrets/${secretName}/?api-version=7.0"
$secretValue = Invoke-RestMethod -Uri $secretUrl -Headers @{
  "Authorization" = "Bearer $tokenResponse"
} | Select-Object -ExpandProperty value

# 4) Save the secret to the SSH deploy key file
$secretValue | Out-File -FilePath "$env:USERPROFILE\.ssh\deploy_key" -Encoding ascii
icacls "$env:USERPROFILE\.ssh\deploy_key" /inheritance:r /grant:r "$env:USERNAME:`(R`)"
icacls "$env:USERPROFILE\.ssh\deploy_key" /inheritance:r /grant:r "$env:USERNAME:`(W`)"

# 5) Configure SSH to use the key for GitHub (Security Concern)
@"
Host github.com
  IdentityFile ~/.ssh/deploy_key
  StrictHostKeyChecking no
"@ | Out-File -Append -FilePath "$env:USERPROFILE\.ssh\config" -Encoding ascii

# 6) Clone the GitHub repository
git clone git@github.com:yourusername/yourrepository.git

# 7) Delete the deploy key (ONLY AFTER SUCCESSFUL CLONE)
if ($LASTEXITCODE -eq 0) {
  Remove-Item "$env:USERPROFILE\.ssh\deploy_key" -Force
  Write-Host "Successfully deleted the deploy key."
}

# 8) Continue with your deployment or configuration tasks