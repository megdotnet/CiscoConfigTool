# populate the variables and rename this to confg.ps1

#Requires -Modules Posh-SSH
#Requires -Modules Microsoft.PowerShell.SecretManagement
#Requires -Modules Microsoft.PowerShell.SecretStore

# unock the secret store
$passwordPath = Join-Path (Split-Path $profile) SecretStore.vault.credential
$pass = Import-Clixml $passwordPath
Unlock-SecretStore $pass

# net connection credential
$conx_cred = Get-Secret "secret name"

# user account to be added/removed/modified
# creds may need to exist in the secret store depening on task to be performed
$working_user = "username"

# path variables
$list_fo = $PSScriptRoot 
$list_fn = ".\conx_list.csv"
$list_fp = Join-Path -Path $list_fo -ChildPath $list_fn

# other variables
$test_device_hostname = "hostname"
$test_device_ip_address = "1.2.3.4"