# 1. You need to allow WMI/SMB firewall ports (TCP 135,445) on each target server if they are not already open. Running this command directly on each server should accomplish this.
#	New-NetFirewallRule -DisplayName "WMI/SMB Firewall Rules: TCP" -Direction Inbound -Action Allow -EdgeTraversalPolicy Allow -Protocol TCP -LocalPort 135,445
#
# 2. If you changed the firewall, you need to enable it by restarting the firewall services on the server. You could run this command if you are running Windows 10.
#	If ((Get-Service mpssvc).Status -eq 'Running'){ Restart-Service -Name mpssvc -Force -Verbose }
#
# 3. On the switch, you need to allow TCP 135,445 to enable WMI/SMB ports on the firewall on the IP Address range of servers from your source location.

#Modify the path below to this program's location on your computer
$root_path = "C:\Users\$env:USERNAME\Desktop\"
#other variables
$date=$(Get-Date -format "ddMMMyyyy")
$server_file=$root_path\server_list.txt

$answer = Read-Host "Edit server_list.txt? [N]o or [Return] for Yes"
if ($answer -ne "N") {
    notepad $server_file
    Read-Host "After saving, hit [ENTER] to continue"
}
function Get_serverinformation($Each_server){
    #Insert code here
}
$servers=$(get-content $server_file | ? {$_.trim() -ne "" } | Foreach {$_.TrimEnd()})
$servers | ForEach {
  $Each_server=$_
  $OUTPUT_Serverinfo=$(Get_serverinformation($Each_server))
  $OUTPUT_Serverinfo++
}
$OUTPUT_Serverinfo | Export-Csv -Path $root_path\$date_serverinfo.csv