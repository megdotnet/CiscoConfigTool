<#
.Synopsis
   This script will test ssh connectivity to a network device.
.INPUTS
   Inputs will come from the config file.
.OUTPUTS
   The script will return the prompt text from the device upon successful connection.
#>

# import the config file
. $PSScriptRoot\config.ps1

# set variables from config values
$hostname = $test_device_hostname
$ip_address = $test_device_ip_address

# clear any old sessions, just in case...
Get-SSHSession | Remove-SSHSession | Out-Null

# attemp connection to device
Write-Host "`nConnecting to $hostname on $ip_address" -ForegroundColor Green

try {
    $sesh = New-SSHSession -Computername $ip_address -Credential $conx_cred -AcceptKey -ErrorAction SilentlyContinue
    $ssh_stream = New-SSHShellStream -SessionId $sesh.SessionId    
}
catch {
    Write-Host "Connection timeout"
}

start-sleep -Seconds 1
$output = $ssh_stream.Read()

# display results
$output

# close the ssh session
Remove-SSHSession -SSHSession $sesh | Out-Null