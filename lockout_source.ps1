Import-Module ActiveDirectory
$version="1.0"
Write-Host "
       Title: DOR Lockout_source v$version
     Authors: Edward Hunt
      Agency: Georgia Department of Revenue
        Dept: Infrastructure Technology Division
        Date: October 17, 2019
     Purpose: This script investigates and exports each locked out user into a spreadsheet.
Requirements: The user running this script must have domain admin privileges."

#Variables
$Date=$(Get-Date)
$Timestamp="$($Date.Day)_$($Date.Month)_$($Date.Year)"
$Mypath = "C:\Users\$env:USERNAME\Desktop\Incident\DOR_Lockoutsource_Output_$Timestamp.csv"
$PDC = (Get-ADDomainController -Filter * | Where-Object {$_.OperationMasterRoles -contains "PDCEmulator"})
$UserName_list=@()

function Investigate_lockouts ($UserName_list) {
    Write-Host "`nInvestigating lockouts and building spreadsheet. Please standby...`n"
    For ($i=0;$i -lt $UserName_list.length;$i++) {
        $USERID=$UserName_list[$i]
        Write-Host "Checking $USERID..."
        $UserInfo = Get-ADUser $USERID
        #Search PDC for lockout events with ID 4740
        $LockedOutEvents = Get-WinEvent -ComputerName $PDC.HostName -FilterHashtable @{LogName='Security';Id=4740} -ErrorAction Stop | Sort-Object -Property TimeCreated -Descending
        #Parse and filter out lockout events
        Foreach($Event in $LockedOutEvents) {
            If($Event | Where {$_.Properties[2].value -match $UserInfo.SID.Value}) {
                $Event | Select-Object -Property @(
                    @{Label = 'User'; Expression = {$_.Properties[0].Value}}
                    @{Label = 'DomainController'; Expression = {$_.MachineName}}
                    @{Label = 'EventId'; Expression = {$_.Id}}
                    @{Label = 'LockoutTimeStamp'; Expression = {$_.TimeCreated}}
                    @{Label = 'Message'; Expression = {$_.Message -split "`r" | Select -First 1}}
                    @{Label = 'LockoutSource'; Expression = {$_.Properties[1].Value}})
            }
        }
    }
    $Event | Export-Csv -Path $Mypath -Append -Force
    #Show output in Excell
    $Excel = New-Object -ComObject Excel.Application
    $Workbook = $Excel.Workbooks.Open($Mypath)
    $Excel.Visible = $true
    Write-Host "Report is complete. Results are located at the target location:" 
    Write-Host "$Mypath" -ForegroundColor Green
}
#Main part of code:
Function DORLS () {
    If (Test-Path -path $Mypath) { Remove-Item -Path $Mypath -Verbose -Confirm }
    Write-Host "Enter the userid who is locked out. When finished, just hit [RETURN]" -ForegroundColor Yellow
    do {
        $each_user=Read-Host "Userid "
        if ($each_user -ne '') { [array]$UserName_list += $each_user }
    }
    until ($each_user -eq '')
    Investigate_lockouts $UserName_list
}

#Execute DORLS
DORLS
Write-Host "To execute this script again, just type: " -Nonewline
Write-Host "DORLS [Enter]"-ForegroundColor Black -BackgroundColor White 
