Clear
[string]$version="1.0"
$rootpath="C:\Users\$env:USERNAME\Desktop\Disk Usage Check"
Write-Host "
       Title: Disk_Usage
     Version: $version
     Purpose: To query disk usage for a server that is remote.
        Date: February 27, 2020
      Author: Edward Hunt
       Title: Information Technology Division Supervisor
Requirements: 1) Enable TCP 135/WMI through the firewall from your source to the `$TARGET_SERVER.
              2) Your `$UID must have Administrator privileges on the `$TARGET_SERVER.`n"

# You may populate these variables per your company/agency security policy
$UID = ""
$My_password = ""

# Disk threshold alert
[int]$Alert=90

# Store a list of your target servers here...
[Array]$TARGET_SERVER=
"Server1",
"Server2",
"Server3"
# Comment out the following line if you would rather use the $TARGET_SERVER array list above
$TARGET_SERVER=$(Read-Host "Enter the HOSTNAME or IP Address of the TARGET_SERVER")

# Establish a new root path, if needed.
Write-Host "`nFile I/O path = $rootpath" -ForegroundColor Green
$new_root_path=$(Read-Host "If this is not correct, please enter a new path. Else, hit [Enter]")
If ($new_root_path -eq "") {
    # Do nothing
    }
Else { $rootpath=$new_root_path }
If (-NOT $(Test-Path $rootpath)) { mkdir $rootpath | Out-Null }
$output="$rootpath\disk_usage_report.csv"


Function store_credentials ($blob, $user, $password) {
    Write-Host "Please enter your $blob and password in the credential widget..." -ForegroundColor Yellow
    Try {
        If (($user -eq "") -and ($password -eq "")) { 
            $credentials = $(Get-Credential -Message "$blob and password?") 
        }
        ElseIf ($My_password -eq "") { 
            $credentials = $(Get-Credential -Credential "$user") }
        Else { 
            $secured_passwd = ConvertTo-SecureString $password -AsPlainText -Force
            $credentials = New-Object System.Management.Automation.PSCredential ($user, $secured_passwd) 
        }
        Return $credentials
    }
    Catch { 
        $ERROR_MESSAGE=$Error[0].Exception.Message
        Write-Host "Cancelled successfully.`n"
        Write-Host "Error Message ="$ERROR_MESSAGE -ForegroundColor Red
        Break
    }
}

$GET_credentials=$(store_credentials "$env:USERDOMAIN\USERID and password?" $UID $My_password)

$TARGET_SERVER | ForEach {
    [String]$HOSTNAME=$_
    $DISK_INFO=@()
    $DISK_INFO=$(Get-WmiObject -Class Win32_logicaldisk -Namespace root/cimv2 -ComputerName $HOSTNAME -Credential $GET_credentials | Select Hostname,DeviceID,FreeSpace,Size,Percent_Utilized,VolumeName,Alert)
    $DISK_INFO | ForEach {
        $EACH_DISK=$_
        $EACH_DISK.Hostname=$HOSTNAME
        #Write-Host ($EACH_DISK.Size -ne $null), $EACH_DISK.Size
        If ($EACH_DISK.Size -ne $null) {
            If ($((1-($EACH_DISK.FreeSpace/$EACH_DISK.Size))*100) -ge $Alert) {$EACH_DISK.Alert="TRUE"}
            $EACH_DISK.Percent_Utilized="{0:N1}"-f$((1-($EACH_DISK.FreeSpace/$EACH_DISK.Size))*100)+"%"
            $EACH_DISK.FreeSpace="{0:N0}"-f($EACH_DISK.FreeSpace/1GB)+" GB"
            $EACH_DISK.Size="{0:N0}"-f($EACH_DISK.Size/1GB)+" GB"
        }
    }
    $RESULTS += $DISK_INFO
}
$RESULTS | Out-GridView
$RESULTS | Export-CSV -Path $output -Force
Write-Host "A report was saved to: " -NoNewline;
Write-Host $output -ForegroundColor Green
