# Nexora AD Lab Setup Script
# Run this script on DC01 in PowerShell to build the vulnerable environment.

# 1. Set Password Policy to allow weak passwords
Set-ADDefaultDomainPasswordPolicy -Identity nexora.local -ComplexityEnabled $false

# 2. Create OUs
New-ADOrganizationalUnit -Name "IT" -Path "DC=nexora,DC=local"
New-ADOrganizationalUnit -Name "HR" -Path "DC=nexora,DC=local"
New-ADOrganizationalUnit -Name "Finance" -Path "DC=nexora,DC=local"
New-ADOrganizationalUnit -Name "Engineering" -Path "DC=nexora,DC=local"
New-ADOrganizationalUnit -Name "Management" -Path "DC=nexora,DC=local"

# 3. Create Special Users (Path A and C)
New-ADUser -Name "Low Priv User" -SamAccountName "lowpriv" -UserPrincipalName "lowpriv@nexora.local" -Path "OU=IT,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "UserPass123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "ACL User" -SamAccountName "acluser" -UserPrincipalName "acluser@nexora.local" -Path "OU=IT,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "AclPass123!" -AsPlainText -Force) -Enabled $true

# 4. Create Standard Users (Just to populate the domain)
New-ADUser -Name "IT User1" -SamAccountName "ITUser1" -Path "OU=IT,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "HR User1" -SamAccountName "HRUser1" -Path "OU=HR,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true
New-ADUser -Name "Finance User1" -SamAccountName "FinanceUser1" -Path "OU=Finance,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "Password123!" -AsPlainText -Force) -Enabled $true

# 5. Path B Vulnerability: Kerberoastable Service Account
New-ADUser -Name "SQL Service" -SamAccountName "svc_sql" -UserPrincipalName "svc_sql@nexora.local" -Path "OU=Service Accounts,DC=nexora,DC=local" -AccountPassword (ConvertTo-SecureString "Summer2024!" -AsPlainText -Force) -Enabled $true
Set-ADUser -Identity "svc_sql" -ServicePrincipalNames @{Add="MSSQLSvc/DC01.nexora.local:1433"}

# 6. Path C Vulnerability: ACL Abuse (GenericAll over Domain Admins)
$DomainAdmins = Get-ADGroup "Domain Admins"
$AclUser = Get-ADUser "acluser"
$SID = New-Object System.Security.Principal.SecurityIdentifier($AclUser.SID)
$Identity = $SID.Translate([System.Security.Principal.NTAccount])
$Acl = Get-Acl "AD:\$($DomainAdmins.DistinguishedName)"
$AccessRule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity,"GenericAll","Allow")
$Acl.AddAccessRule($AccessRule)
Set-Acl -Path "AD:\$($DomainAdmins.DistinguishedName)" -AclObject $Acl

# 7. Path A Vulnerability: Exposed Credentials in File Share
New-Item -ItemType Directory -Path "C:\Shares\IT" -Force
New-SmbShare -Name "IT" -Path "C:\Shares\IT" -FullAccess "Everyone"
Set-Content -Path "C:\Shares\IT\deployment_config.txt" -Value "DomainAdminUser: NEXORA\Administrator`nDomainAdminPassword: Soham@2005"