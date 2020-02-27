# If this file were public, you may run this script remotely from GitHub using this command:
# Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/ed7hunt/PowerShell-and-PowerGUI/master/update_powershell.ps1).Content
#
# If you work in place such as ours in which the "POWERS THAT BE" do not want you running scripts over the network, you may find that
# PowerShell might not be enabled. Your execution policies could be disabled by group-policy: either on your computer, user account or 
# both. This script is therefore valuable because you can undo the security policy that was created to "keep you safe". It would be 
# wise to seek approval by your security offials or manager before running this script.
# 
# Be extremely cautious about updating .NET if you are confronted with this scenario. You may be successful in updating it; but end up
# breaking applications that may be dependent upon it in a server related environment. With that being said, good luck!

Clear
Write-Host "
       Title: Update Powershell"
$version="1.1"
Write-Host "     Version: $version
      Author: Edward Hunt
        Dept: Infrastructure Technology Division
        Date: February 14, 2020
     Purpose: The purpose of this script is to:
              a) Enable Execution Policies so your PowerShell scripts can run.
              b) Update your PowerShell versions to the latest levels.
              c) Install useful Windows PowerShell modules that System Administrators commonly use.
Requirements: Your source OS should be >= Windows 10, Server 2012 + up"
Write-Host "              This script should be run as Administrator. Use [SHIFT] + [RIGHT MOUSE CLICK], 'Run as Administrator'`n"
$Elevated_Privileges=$([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator" )
Write-Host "Running as USERID = " -NoNewline
Write-Host "$(whoami)" -ForegroundColor Yellow
Write-Host "Elevated Privileges = " -Nonewline
If ($Elevated_Privileges) {
    Write-Host "$Elevated_Privileges`n" -ForegroundColor Black -BackgroundColor Green
    $answer1=$(Read-Host "Would you like to update your PowerShell to the latest version?  [Y] or [N]")
    If ($answer1 -eq "Y") {
        Write-Host "Below is the version of PowerShell installed on your computer:"
        $PSVersionTable
        Update-Module
        Write-Host "`nFollow the instructions shown in Internet Explorer on how to update PowerShell. Launching IE...`n" -ForegroundColor Yellow
        $InternetExplorer=new-object -com internetexplorer.application
        $InternetExplorer.navigate2("https://docs.microsoft.com/en-us/powershell/scripting/install/installing-windows-powershell?view=powershell-6")
        $InternetExplorer.visible=$true
    }
    Write-Host "Checking your Execution policies... " -ForegroundColor Green
    $EPout=$(Get-ExecutionPolicy -List)
    Write-Host $($EPout | Out-String) -ForegroundColor Cyan
    If (($EPout[3].ExecutionPolicy -ne "RemoteSigned") -or ($EPout[4].ExecutionPolicy -ne "Unrestricted")) {
           Write-Host "Listing Execution policy BEFORE making changes..."
           Read-Host "Hit [ENTER] to continue"
           $ErrorActionPreference="silentlycontinue"
           Set-ExecutionPolicy -ExecutionPolicy Undefined -Scope Process -Force
           Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
           Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope LocalMachine -Force
           $ErrorActionPreference="stop"
           Write-Host "Listing Execution policy AFTER making changes..."
           Write-Host $(Get-ExecutionPolicy -List | Out-String) -ForegroundColor Cyan
    }
    Else { Write "No changes are needed for your Execution Policies." }
    $update_modules=$(Read-Host "Would you like to update PowerShell modules?  [Y] or [N]")
    If ($update_modules -eq "Y") {
        $ErrorActionPreference="silentlycontinue"
        "Microsoft.Powershell.Management","Microsoft.Powershell.Utility","SqlServer","ServerManager","ActiveDirectory" | Foreach { Get-Module $_ }
        "Microsoft.Powershell.Management","Microsoft.Powershell.Utility","SqlServer","ServerManager","ActiveDirectory" | Foreach { Install-Module $_ }
        "Microsoft.Powershell.Management","Microsoft.Powershell.Utility","SqlServer","ServerManager","ActiveDirectory" | Foreach { Update-Module $_ }
    }
    Write-Host "`nComplete."
}
Else {
    Write-Host "$Elevated_Privileges`n" -ForegroundColor Black -BackgroundColor Red
    Write-Host "You are not running PowerShell as ADMINISTRATOR.`nUse [SHIFT] + [RIGHT MOUSE CLICK], 'Run as Administrator'" -ForegroundColor Yellow
}
