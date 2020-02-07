# Modify the path below to this program's location on your computer
$root_path = "C:\Users\$env:USERNAME\Desktop\"

Write-Host "
       Title: Server Software Installed"
$version="1.0"
Write-Host "     Version: $version
      Author: Edward Hunt
     Website: https://www.linkedin.com/in/edwardhunt4/
        Date: February 7, 2019
Requirements: Your server OS >= Windows 2008, Windows 10
              AT&T: Enable Firewall rules to allow WMI (TCP ports 135,445) from present location to the server
              Server: Allow TCP port 135,445 from your VLAN location to all servers on the server_list
              Server_List: Must contain either FQDN (Fully Qualified Domain Names) or IP Addresses
              Permissions: You may need Administrator access to each server in server_list if you are 
              running GET-WMIobject remotely from your jumpserver/workstation location.
  Exceptions: For each target server in server_list, this script will not output results if TCP ports 135,445 are 
              not open. If you get an error in which the RPC server is unavailable, you may need to update
              Windows .NET (use Google to figure out what is needed). For each exception, you will have 
              to go back to each server and manually run the script for problem determination and troubleshooting.
  Directions: Run this script from the server's DESKTOP to get the health check output, per the path below:" -NoNewline
Write-Host "
              $root_path`n`n" -ForegroundColor Green

# 1. You need to allow WMI/SMB firewall ports (TCP 135,445) on each target server if they are not already open. Running this command directly on each server should accomplish this.
#    New-NetFirewallRule -DisplayName "WMI/SMB Firewall Rules: TCP" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 135,445
#
# 2. If you changed the firewall, you need to enable it by restarting the firewall services on the server. You could run this command if you are running Windows 10.
#    If ((Get-Service mpssvc).Status -eq 'Running'){ Restart-Service -Name mpssvc -Force -Verbose }
#
# 3. On the switch, you may need to allow ports TCP 135,445 to enable WMI/SMB ports on the firewall on the IP Address range of servers from your source location.

# other variables
$date=$(Get-Date -format "ddMMMyyyy")
$server_list="$root_path\server_list.txt"
$output = "$root_path"+"$env:computername"+"_server_software_installed"+"_"+"$date"+".csv"

# Collect information on $Each_server and return the value as $software_inventory 
function Get_serverinformation($Each_server){
    $software_inventory=$(Get-WmiObject -Class Win32reg_AddRemovePrograms -Namespace root/cimv2 -ComputerName $Each_server | Select DisplayName,Version | Sort DisplayName)
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
echo """Hostname"",""Software Installed"",""Version""" | Out-File -Append $output

# Loop through each server and export output into CSV file
$servers | ForEach {
  $Each_server=$_
  $OUTPUT_Serverinfo=$(Get_serverinformation($Each_server))
  $DisplayName=$($OUTPUT_Serverinfo.DisplayName | Out-String)
  $Version=$($OUTPUT_Serverinfo.Version | Out-String)
  echo """$Each_server"",""$DisplayName"",""$Version""" | Out-File -Append $output
} 
Write-Host "CSV File generated. Target file location = $output" -ForegroundColor Green

