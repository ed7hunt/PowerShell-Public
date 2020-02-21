Clear
$version=[string]"1.0"
Write-Host "
       Title: Test SMTP Server
     Version: $version
     Purpose: To verify you can send email from your server through a SMTP Server over a certain port
        Date: February 21, 2020
      Author: Edward Hunt
       Title: Information Technology Division Supervisor
Requirements: 1) Firewall must be allowed from HOST to SMTP Server.
              2) A valid email account and password is needed on the SMTP Server.
                 or
              3) Your HOST must be whitelisted on the SMTP Server.`n"

# You may populate these variables per your agency's security policy
$My_userid = "!ehunt"
$My_email = "edward.huntiv@dor.ga.gov"
$My_password = ""

#SMTP Variables
#$SMTPServer = "smtp.office365.com"
$SMTPServer = "smtp.gets.ga.gov"
#$SMTP_Port = "587"
$SMTP_Port = "25"

#Dynamic variables
$do_another="Y"
$username,$Userinfo=""

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

Function send_an_email {
    $email_credentials=$(store_credentials "$env:USERDOMAIN email address" $My_email $My_password)
    $To_email=$(Read-Host "Enter CC email address (if applicable)")
    Try {
        If ($To_email -eq "") {
            Send-MailMessage -To $($email_credentials.UserName) -From $email_credentials.Username -Subject "IT WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br><br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -Credential $email_credentials -UseSsl
        }
        Else {
            Send-MailMessage -To $To_email -Cc $($email_credentials.UserName) -From $email_credentials.Username -Subject "IT WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br><br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -Credential $email_credentials -UseSsl
        }
        Write-Host "Email sent!`n" -ForegroundColor Green
    }
    Catch { 
        $ERROR_MESSAGE=$Error[0].Exception.Message
        Write-Host "There was an error and email was not sent.`n"
        Write-Host "Error Message ="$ERROR_MESSAGE -ForegroundColor Red
        Break
    }
}

send_an_email
