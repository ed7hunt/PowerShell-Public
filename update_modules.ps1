# If this file were public, you may run this script remotely from GitHub using this command:
# Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/ed7hunt/PowerShell-and-PowerGUI/master/update_modules.ps1).Content
Clear
Write-Host "
       Title: Update Powershell Modules"
$version="1.1"
Write-Host "     Version: $version
      Author: Edward Hunt
        Dept: Infrastructure Technology Division
        Date: Feb 14, 2020
     Purpose: The purpose of this script is to:
              a) Enable Execution Policies so your PowerShell scripts can run.
              b) Update your PowerShell versions to the latest levels.
              c) Install common Windows PowerShell modules that System Administrators commonly use.
Requirements: Your source OS should be >= Windows 10, Server 2012 + up
Write-Host "              This script should be run as Administrator. Use [SHIFT] + [RIGHT MOUSE CLICK], 'Run as Administrator'" -foregroundcolor Red -Nonewline

$Elevated_Privileges=$([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator" )
Write-Host "Running as USERID = " -NoNewline
Write-Host "$(whoami)" -ForegroundColor Yellow
Write-Host "Elevated Privileges = $Elevated_Privileges`n"
If ($Elevated_Privileges) {    
    Write-Host "Adjusting your Execution policies so this script can properly run. " -ForegroundColor Green
    Write-Host "Listing Execution policy BEFORE making changes..."
    $EPout=$(Get-ExecutionPolicy -List | Out-String)
    Write-Host $EPout -ForegroundColor Cyan
    Read-Host "Hit [ENTER] to continue"
    $ErrorActionPreference="silentlycontinue"
    Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
    $ErrorActionPreference="stop"
    Write-Host "Listing Execution policy AFTER making changes..."
    $EPout=$(Get-ExecutionPolicy -List | Out-String)
    Write-Host $EPout -ForegroundColor Cyan
    Read-Host "Hit [ENTER] to continue"
    $update_modules=$(Read-Host "To update PowerShell modules type 'Y', else hit [ENTER]")
    If ($update_modules -eq "Y") {
        "Microsoft.Powershell.Management","Get-WmiObject","TCPClient","SqlServer","ServerManager","ActiveDirectory","Microsoft.Powershell.Management"" | Foreach { Get-Module $_ }
    }
    Start-Sleep -s 5
    Write-Host "`nComplete"
}
Else {
    Write-Host "You are not running PowerShell as ADMINISTRATOR." -ForegroundColor Yellow
    Write-Host "Use [SHIFT] + [RIGHT MOUSE CLICK], 'Run as Administrator'"
}    
