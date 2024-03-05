<#
.SYNOPSIS
Creates a user in Azure Active Directory (Azure AD) with comprehensive error handling and security considerations.

.DESCRIPTION
This script connects to Azure, prompts for user information, creates a user in Azure AD, and assigns a password meeting complexity requirements. It incorporates error handling and best practices for secure user creation.

.NOTES
Requires Az.Accounts module for Azure cmdlets.

Secure Password Handling: Use of ConvertTo-SecureString to convert the generated password into a secure string before adding it to the user object. This is a good practice as it avoids storing plain text passwords in the script.
Additional User Properties: Use of AccountEnabled property set to $true (enabled) and sets ForceChangePasswordNextLogin to $true within the PasswordProfile. This forces the user to change their password upon first login.
New-AzADUser Parameters: Use of a hashtable (@newUserParams) to define user properties and the password profile, providing a cleaner way to structure the object creation.

Name: Azure-Create-Secure-AzureAD-User
Author: Paul Münzner (github.com/paulmuenzner)
Version: 1.0.0

.EXAMPLE
Applying the script
1. Open a PowerShell window with administrator privileges and navigate to the directory where you saved the script.
2. Follow the prompts to enter user details.

#>

# Connect to Azure (if not already connected)
Connect-AzAccount

# Function to generate a complex password
function Generate-ComplexPassword {
  $chars = [System.Convert]::ToChar(33..126)  # Printable ASCII characters (avoid control chars)
  $passwordLength = 12
  $random = New-Object System.Random
  $password = [String]::Empty
  for ($i = 0; $i -lt $passwordLength; $i++) {
    $password += $chars[$random.Next(0, $chars.Length)]
  }
  return $password
}

# Get user information interactively
$displayName = Read-Host "Enter display name for the user:"
$userPrincipalName = Read-Host "Enter desired User Principal Name (UPN) (e.g., user@contoso.com):"
$mailNickname = $userPrincipalName.Split("@")[0]  # Extract mail nickname from UPN

# Generate a secure password
$password = Generate-ComplexPassword

try {
  # Create the user object with secure password
  $securePassword = ConvertTo-SecureString -String $password -AsPlainText -Force
  $newUserParams = @{
    DisplayName        = $displayName
    UserPrincipalName  = $userPrincipalName
    MailNickname       = $mailNickname
    AccountEnabled     = $true
    PasswordProfile    = @{
      Password  = $securePassword
      ForceChangePasswordNextLogin = $true
    }
  }

  # Create the user in Azure AD
  $createdUser = New-AzADUser @newUserParams

  # Write success message and password (avoid storing in script)
  Write-Host "User '$displayName' created successfully with User Principal Name: '$userPrincipalName'"
  Write-Host "Generated password (please copy and store securely, won't be shown again): $password"

} catch {
  Write-Error "Error creating user: $($_.Exception.Message)"
}

# Disconnect from Azure
Disconnect-AzAccount

Write-Host "Script execution completed."
