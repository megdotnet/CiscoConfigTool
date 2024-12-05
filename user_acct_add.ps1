<#
.Synopsis
   This script can be used to add users or modify existing users on Cisco network devices.
.DESCRIPTION
   ---
.INPUTS
   ---
.OUTPUTS
   ---
#>

# import config
. .\config.ps1

# user account to add/modify on devices
$new_creds = Get-Secret $working_user
$new_user = $new_creds.username

# convert password to plaintext
$secureStringPtr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($new_creds.password)
$new_pass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($secureStringPtr)


# import the connection list
$list = import-csv -path $list_fp | where-object { $_.SSH -eq $true }

# declare an empty error list
$error_list = @()

# loop through each of the entries in the list
$list | foreach-object {

    $hostname = $_.Hostname
    $ip_address = $_.IP_Address

    # clear any old sessions, just in case...
    get-sshSession | Remove-SSHSession | Out-Null
    
    # attempt connection to device
    Write-Host "`nConnecting to $hostname on $ip_address" -foregroundcolor green    

    $sesh = New-SSHSession -Computername $ip_address -Credential $conx_cred -AcceptKey -ErrorAction SilentlyContinue    
    Start-Sleep -Seconds 1

    if ($sesh) {
        # create ssh stream
        $ssh_stream = New-SSHShellStream -SessionId $sesh.SessionId -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 1
    }
    else { 
        $error_msg = "Error creating SSH Session for $hostname"
        Write-host $error_msg -ForegroundColor Red
        $error_list += $error_msg
    }
    
    if ($ssh_stream) {
        Write-Host "Adding user: $new_user"
        $ssh_stream.WriteLine("configure terminal")
        Start-Sleep -Seconds 1
        $output = $ssh_stream.Read()
        
        $ssh_stream.WriteLine("username $new_user privilege 15 secret 0 $new_pass")
        Start-Sleep -Seconds 1
        
        $ssh_stream.WriteLine("exit")
        Start-Sleep -Seconds 1
        
        $ssh_stream.WriteLine("show running-config | include username netwrix5")
        Start-Sleep -Seconds 1
        $output += $ssh_stream.Read()
    
        $ssh_stream.WriteLine("copy running-config startup-config")
        Start-Sleep -Seconds 1
        $output += $ssh_stream.Read()
    
        $ssh_stream.WriteLine("`n")
        Start-Sleep -Seconds 10
        $output += $ssh_stream.Read()

        $output
    }      
    else {
        $error_msg = "Error creating Stream for $hostname"
        Write-Host $error_msg -ForegroundColor Red
        $error_list += $error_msg
    }
    if ($sesh) {
        Remove-SSHSession -SSHSession $sesh | Out-Null 
    }
}    

# dispay any errors that ocurred
$error_list