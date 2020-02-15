# Written by Edward Hunt, DOR Infrastructure Supervisor
# Purpose: This script will list the WWNs from HBA info which is needed for adding SAN Luns.
# November 19, 2018
# Directions:
#  1) Download this PowerShell script to retrieve the Fiber-Channel WWNs for your Window's Server. 
#  2) Run the script with your administrator account in PowerShell ISE.
#  3) The output will be located on the server's desktop in CSV format. 

param(  
[String[]]$ComputerName = $ENV:ComputerName, 
[Switch]$LogOffline  
)  

  
$ComputerName | ForEach-Object {  
try { 
    $Computer = $_ 
     
    $Params = @{ 
        Namespace    = 'root\WMI' 
        class        = 'MSFC_FCAdapterHBAAttributes'
        ComputerName = $Computer  
        ErrorAction  = 'Stop' 
        } 
     
    Get-WmiObject @Params  | ForEach-Object {  
            $hash=@{  
                ComputerName     = $_.__SERVER  
                NodeWWN          = (($_.NodeWWN) | ForEach-Object {"{0:X2}" -f $_}) -join ":"  
                Active           = $_.Active  
                DriverName       = $_.DriverName  
                DriverVersion    = $_.DriverVersion  
                FirmwareVersion  = $_.FirmwareVersion  
                Model            = $_.Model  
                ModelDescription = $_.ModelDescription  
                }  
            New-Object psobject -Property $hash  
        }#Foreach-Object(Adapter)  
}#try 
catch { 
    Write-Warning -Message $_ 
    if ($LogOffline) 
    { 
        "$Computer is offline or not supported" >> "C:$env:HOMEPATH\Desktop\Offline.txt" 
    } 
} 
 
} | Export-Csv -Path C:$env:HOMEPATH\Desktop\WWN_output.csv -Confirm #Foreach-Object(Computer)  
  
