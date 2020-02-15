# Written by Edward Hunt, DOR Infrastructure Supervisor
# November 19, 2018
# Directions:
#  1) Download this PowerShell script to retrieve the Fiber-Channel WWNs on your Window's Server: 
#     //vdor-prod-01/Software/PowerShell/SAN_request/Get-HBAWin.ps1
#  2) Copy "Get-HBAWin.ps1" on the remote server. 
#  3) Run the script with your bang account using PowerShell or ISE. 
#  4) The output will be located on the server's desktop in CSV format. 
#  5) Fill out and copy the WWNs into the vendor's spreadsheet to submit the GETS SAN request: 
#     https://qtraining.gets.georgia.gov/SRMDocs/SAN_Request _Template_v1.doc 
#  6) Remove "Get-HBAWin.ps1" from the server after you run it.

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
  