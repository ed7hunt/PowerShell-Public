Clear
Write-Host "
       Title: Update Powershell Modules"
$version="1.0"
Write-Host "     Version: $version
      Author: Edward Hunt
        Dept: Infrastructure Technology Division
        Date: Jan 31, 2020
Requirements: Your source OS should be >= Windows 10, Server 2012 + up
              If you would like a video tutorial, paste the link below into your browser:
              
              https://drive.google.com/file/d/1rA90vXshDwLidOnCIbFg8MhbRVO_qj3y/view?usp=sharing
              `n"


If ( -NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator" )) {
    Write-Host "You are not running PowerShell as ADMINISTRATOR." -ForegroundColor Yellow
    Write-Host "Use [SHIFT] + [RIGHT MOUSE CLICK], 'Run as Administrator'"
} 
Else {
    Write-Host "This script will run as ADMIN with elevated priviledges.`n" -ForegroundColor Green
    $answer1=$(Read-Host "Would you like to install latest modules and update your PowerShell to the latest version?  [Y] or [N]")
    If ($answer1 -eq "Y") {
        Write-Host "Below is the version of PowerShell installed on your computer:"
        $PSVersionTable
        Update-Module
        Write-Host "Follow the instructions on how to update PowerShell. Launching IE...`n" -ForegroundColor Green
        $InternetExplorer=new-object -com internetexplorer.application
        $InternetExplorer.navigate2("https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6")
        $InternetExplorer.visible=$true
    }
    $answer2=$(Read-Host "Would you like to update your policies so you can run Powershell?  [Y] or [N]")
    If ($answer2 -eq "Y"){
        If ($(Get-ExecutionPolicy -scope LocalMachine) -ne "Unrestricted") {
            Write-Host "Attempting to set Execution Policy for scope LocalMachine was set to Unrestricted." -ForegroundColor Green
            Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
            $Change=$True
        }
        If ($(Get-ExecutionPolicy -scope CurrentUser) -ne "RemoteSigned") {
            Write-Host "Attempting to set Execution Policy for scope CurrentUser to RemoteSigned." -ForegroundColor Green
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            $Change=$True
        }
        If ($Change) {
            Write-Host "`nDone making changes to Execution Policies. See output below:" -ForegroundColor Green
        }
        Else { 
            Write-Host "`nYour Execution Policies look OK here. No changes were made." -ForegroundColor Green
        }
        Get-Executionpolicy -list | Out-String
    }
    $answer3=$(Read-Host "Would you like to update other modules such as SQLServer, ServerManager, ActiveDirectory, Microsoft.Powershell.Management? [Y] or [N]")
    If ($answer3 -eq "Y") {
        "SqlServer","ServerManager","ActiveDirectory","Microsoft.Powershell.Management" | Foreach { Import-Module $_ }
    }
    Write-Host "`nComplete"
}