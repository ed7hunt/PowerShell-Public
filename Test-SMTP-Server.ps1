Clear
$version=[string]"1.0"
Write-Host "
       Title: Test SMTP Server
     Version: $version
     Purpose: To verify you can send email from your server through a SMTP Server over a certain port
        Date: February 21, 2020
      Author: Edward Hunt
       Title: Information Technology Division Supervisor
Requirements: TCP ports 25 and/or 587 must be allowed through the firewall from HOST to SMTP Server. 
     Outputs: You will receive EMAIL #1 if you have a valid email account and password on the SMTP server.
              You will recevie EMAIL #2 if your HOST is whitelisted on the SMTP server.`n"

# You should modify/populate these variables per your company/agency security policy
$No_reply = "noreply@yourcompany.com"
$My_email = "your_email@yourcompany.com"
$My_password = "yourpassword"

# SMTPServers: smtp.office365.com, ...
$SMTPServer = ""
# Valid SMTP ports are 25,587
$SMTP_Port = "25"

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
            Send-MailMessage -To $($email_credentials.UserName) -From $email_credentials.Username -Subject "EMAIL #1 WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br>Authentication Method:  Validated credentials<br><br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -Credential $email_credentials -UseSsl
            Send-MailMessage -To $($email_credentials.UserName) -From $No_reply -Subject "EMAIL #2 WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br>Authentication Method:  No credentials.<br><br> If you received this email, it means the server has been <b>successfully whitelisted on $SMTPServer</b>.<br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -UseSsl
        }
        Else {
            Send-MailMessage -To $To_email -Cc $($email_credentials.UserName) -From $email_credentials.Username -Subject "EMAIL #1 WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br><br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -Credential $email_credentials -UseSsl
            Send-MailMessage -To $To_email -Cc $($email_credentials.UserName) -From $No_reply -Subject "EMAIL #2 WORKS! an SMTP email was sent from $env:Computername.$env:USERDNSDOMAIN" -Body "Hello,<br><br>This is a test SMTP email validating that the server, <b>$env:Computername.$env:USERDNSDOMAIN</b> can send an email via SMTP through:<br><br>SERVER:  $SMTPServer<br>PORT:  $SMTP_port<br>Authentication Method:  No credentials.<br><br> If you received this email, it means the server has been <b>successfully whitelisted on $SMTPServer</b>.<br>This was verified via Edward Hunt's <font color='red'><b>Test SMTP Server</b></font> PowerShell script which is available to the general public at:<br><a href='http://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1'>https://github.com/ed7hunt/PowerShell-and-PowerGUI/blob/master/Test-SMTP-Server.ps1</a>:<br><br>Kindest regards,<br><br>The Infrastructure Team<br><a href='http://helpdesk:8081'>http://helpdesk:8081</a>" -BodyAsHtml -SMTPServer $SMTPServer -Port $SMTP_Port -UseSsl
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
