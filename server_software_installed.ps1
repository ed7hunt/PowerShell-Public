# To run this script remotely from the web, use:
# Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/ed7hunt/PowerShell-and-PowerGUI/master/server_software_installed.ps1).Content
# Modify the path below to this program's location on your computer
$root_path = "C:\Users\$env:USERNAME\Desktop\"
Write-Host "
       Title: Server Software Installed"
$version="1.1"
Write-Host "     Version: $version
      Author: Edward Hunt
     Website: https://www.linkedin.com/in/edwardhunt4/
        Date: February 8, 2020
Requirements: Your server OS >= Windows 2008, Windows 10
              AT&T: Enable Firewall rules to allow WMI (TCP ports 135) from present location to the server
              Server: Allow TCP port 135 from your VLAN location to all servers on the server_list
              Server_List: Must contain either FQDN (Fully Qualified Domain Names) or IP Addresses
              Permissions: You may need Administrator access to each server in server_list if you are 
              running GET-WMIobject remotely from your jumpserver/workstation location.
  Exceptions: For each target server in server_list, this script will not output results if TCP ports 135 are 
              not open. If you get an error in which the RPC server is unavailable, you may need to update
              Windows .NET (use Google to figure out what is needed). For each exception, you will have 
              to go back to each server and manually run the script for problem determination and troubleshooting.
  Directions: Run this script from the server's DESKTOP to get the health check output, per the path below:" -NoNewline
Write-Host "
              $root_path`n`n" -ForegroundColor Green

# 1. You need to allow WMI firewall port (TCP 135) on each target server if they are not already open. Running this command directly on each server should accomplish this.
#    New-NetFirewallRule -DisplayName "WMI Firewall Rules: TCP" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 135
#
# 2. If you changed the firewall, you need to enable it by restarting the firewall services on the server. You could run this command, for example if you are running Windows 10.
#    If ((Get-Service mpssvc).Status -eq 'Running'){ Restart-Service -Name mpssvc -Force -Verbose }
#
# 3. On the switch, you may need to allow ports TCP 135 to enable WMI ports on the firewall on the IP Address range of servers from your source location.

# other variables
$date=$(Get-Date -format "ddMMMyyyy")
$server_list="$root_path\server_list.txt"
$output = "$root_path"+"$env:computername"+"_server_software_installed"+"_"+"$date"+".csv"

# Collect information on $Each_server and return the value as $software_inventory 
function Get_serverinformation($Each_server){
    try {
        $software_inventory = "" | Select Roadblocks,DisplayName,Version,OS_Name,OS_Version,HotFixID,Description,InstalledOn
        try {
            $ErrorActionPreference="stop"
            $software_installed=$(Get-WmiObject -Class Win32reg_AddRemovePrograms -Namespace root/cimv2 -ComputerName $Each_server | Select DisplayName,Version | Sort DisplayName)
            $software_inventory.DisplayName=$($software_installed.Displayname | Out-String)
            $software_inventory.Version=$($software_installed.Version | Out-String)
        }
        catch {
            $ERROR_MESSAGE=$_.Exception.Message
            If ($ERROR_MESSAGE -like "*Invalid class*") {
                $software_inventory.Displayname="Invalid class: Win32reg_AddRemovePrograms"
                $software_inventory.Version="Invalid class: Win32reg_AddRemovePrograms"
            }
            Elseif ($ERROR_MESSAGE -like "*Access denied*") {
                $software_inventory.Displayname="Access denied: Win32reg_AddRemovePrograms"
                $software_inventory.Version="Access denied: Win32reg_AddRemovePrograms"
            }
            Else {
                $software_inventory.Displayname="$ERROR_MESSAGE"
                $software_inventory.Version="$ERROR_MESSAGE"
            }
            Write-Host " Problem with Win32reg_AddRemovePrograms." -ForegroundColor Red -NoNewline 
        }
        $OS=$(Get-WmiObject -Class Win32_OperatingSystem -Namespace root/cimv2 -ComputerName $Each_server | Select-Object -Property Name,Version)
        $OS_patches=$(Get-WmiObject -Class win32_quickfixengineering -Namespace root/cimv2 -ComputerName $Each_server | Select-Object -Property HotFixID,Description,InstalledOn)
        $software_inventory.Roadblocks="none"
        $software_inventory.OS_Name=$($OS.Name -replace '\|C:\\Windows\|\\Device\\Harddisk\d{1}\\Partition\d{1}','')
        $software_inventory.OS_Version=$OS.Version
        $software_inventory.HotFixID=$($OS_patches.HotFixID)
        $software_inventory.Description=$($OS_patches.Description)
        $software_inventory.InstalledOn=$($OS_patches.InstalledOn)
        Write-Host " Script collected output successfully." -ForegroundColor Green
    }
    catch {
        Write-Host " WMI Failure: " -ForegroundColor Red -NoNewline 
        #$_.Exception.Message
        $ERROR_MESSAGE=$_.Exception.Message
        if ($ERROR_MESSAGE -like "*Call was canceled*" ) {
            $Roadblocks = "Get-WmiObject : Call was canceled by the message filter."
        }
        elseif ($ERROR_MESSAGE -like "*Access*denied*" ) {
            $Roadblocks = "$env:USERDOMAIN/$env:USERNAME needs ADMIN access in order to run WMI command"
        }
        elseif ($ERROR_MESSAGE -like "*HRESULT: 0x800706BA*" ) {
            $Roadblocks = "The RPC server is unavailable. (Exception from HRESULT: 0x800706BA)"
        }
        else {
            $Roadblocks = $ERROR_MESSAGE
        }
        Write-Host "$Roadblocks" -ForegroundColor Red
        $software_inventory.Roadblocks=$Roadblocks
    }
    return $software_inventory
}

# Get environment information
Write-Host "Which describes your scenario?"
Write-Host "`n     [1] I am running this script my workstation/jump server to collect data from many servers."-ForegroundColor White
Write-Host "     [2] I am running this script manually on the target server to collect data.`n" -ForegroundColor Yellow
switch (Read-Host "Enter your choice. Default = [2] ?") {
    1 {$answer = Read-Host "Edit server_list.txt? [N]o or [Return] for Yes"
        if ($answer -ne "N") {
            notepad $server_list
            Read-Host "After saving, hit [ENTER] to continue"
        }
        $servers=$(get-content $server_list | ? {$_.trim() -ne "" } | Foreach {$_.TrimEnd()})}
    2 {$servers="$env:Computername"}
    default {$servers="$env:Computername"}
}

# Assign delimiter for CSV file
echo 'SEP=,' | Out-File -FilePath $output -Force

# Create header for CSV file
echo """Hostname"",""Script Roadblocks (for GET-WMIObject)"",""Software Installed"",""Version"",""OS Name"",""OS Version"",""HotFixID"",""Description"",""Install Date""" | Out-File -Append $output

# Loop through each server and export output into CSV file
$servers | ForEach {
    $Each_server=$_
    $Roadblocks=$DisplayName=$Version=$OS_Name=$OS_Version=$HotFixID=$Description=$InstalledOn=$ERROR_MESSAGE=$software_inventory=$OS=$OS_patches=$software_installed=""
    try {
        $tcp = new-object System.Net.Sockets.TcpClient
        $tcp.ReceiveTimeout = 1000
        $tcp.client.ReceiveTimeout = 1000
        $tcp.SendTimeout = 1000
        $tcp.client.SendTimeout = 1000
        $tcp.NoDelay = "True"
        $tcp.Connect($Each_server,135)
        Write-Host "$Each_server : Connected via TCP port 135/WMI." -ForegroundColor Green -NoNewline
        $tcp.close()
        $OUTPUT_Serverinfo=$(Get_serverinformation($Each_server))
        $DisplayName=$($OUTPUT_Serverinfo.DisplayName | Out-String)
        $Version=$($OUTPUT_Serverinfo.Version | Out-String)
        $OS_Name=$($OUTPUT_Serverinfo.OS_Name | Out-String)
        $OS_Version=$($OUTPUT_Serverinfo.OS_Version | Out-String)
        $HotFixID=$($OUTPUT_Serverinfo.HotFixID | Out-String)
        $Description=$($OUTPUT_Serverinfo.Description | Out-String)
        $InstalledOn=$($OUTPUT_Serverinfo.InstalledOn | Out-String)
        $Roadblocks=$($OUTPUT_Serverinfo.Roadblocks | Out-String)
        }
    catch {
        $ERROR_MESSAGE=$_.Exception.Message
        If ($ERROR_MESSAGE -like "*period of time*") {
            $Roadblocks="TCP Port 135 TIMESOUT. Server might be offline or you could be blocked by a firewall."
            Write-Host "$Each_server : $Roadblocks" -ForegroundColor Red
        }
        ElseIf ($ERROR_MESSAGE -like "*refused*") {
            $Roadblocks="TCP Port 135 is REFUSED. WMI not running on server."
            Write-Host "$Each_server : $Roadblocks" -ForegroundColor Yellow
        }
        ElseIf ($ERROR_MESSAGE -like "*no such host*" -or $ERROR_MESSAGE -like "*unreachable host*") {
            $Roadblocks="The hostname's FQDN is not correctly spelled."
            Write-Host "$Each_server : $Roadblocks" -ForegroundColor Red
        }
        Else {
            $Roadblocks="$ERROR_MESSAGE"
        }
    }
    echo """$Each_server"",""$Roadblocks"",""$DisplayName"",""$Version"",""$OS_Name"",""$OS_Version"",""$HotFixID"",""$Description"",""$InstalledOn""" | Out-File -Append $output
} 
Write-Host "`nCSV File generated. Target file location = $output" -ForegroundColor Green

