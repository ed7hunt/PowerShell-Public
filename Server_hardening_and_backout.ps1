# If this file were public, you may run this script remotely from GitHub using this command:
# Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/ed7hunt/PowerShell-and-PowerGUI/master/Server_hardening_and_backout.ps1).Content

Invoke-Expression (Invoke-WebRequest https://raw.githubusercontent.com/ed7hunt/PowerShell-and-PowerGUI/master/update_powershell.ps1).Content

function create_the_key ($TLS) {
    # Create the key and Disable it
    $global:My_path = "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\$TLS"
    If ($(Test-Path "$My_path") -eq $False) {
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols" -Name $TLS -Verbose
    }
    If ($(Test-Path "$My_path\Server") -eq $False) {
        New-Item -Path "$My_path" -Name "Server" -Verbose
    }
    If ($(Test-Path "$My_path\Client") -eq $False) {
        New-Item -Path "$My_path" -Name "Client" -Verbose
    }
}

function disable ($TLS) {
    create_the_key $TLS
    #get-childitem $My_path -Recurse
    "Server","Client" | ForEach {
        $Name=$_
        "DisabledByDefault" | ForEach {
            $KEY=$_ 
            If ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq $null) { New-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "1" -PropertyType "DWord" -Verbose}
            Elseif ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq "1") { Write-Host "Already disabled" -ForegroundColor Green }
            Else { Set-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "1" -Verbose }
        }
        "Enabled" | ForEach {
            $KEY=$_ 
            If ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq $null) { New-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "0" -PropertyType "DWord" -Verbose}
            Elseif ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq "0") { Write-Host "Already disabled" -ForegroundColor Green }
            Else { Set-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "0" -Verbose }
        }
    }
}

function HardeningScript () {
    # Windows PowerShell Script for hardening Secure Sockets Layer on IIS.
    # This script also enables TLS, and sets it to be preferred over SSL.  It
    # also sets the preferred ciphers, cipher suites, and their preferred order.
    # Copyright 2014, Stephen Hodges

    # Disable Multi-Protocol Unified Hello
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\Server' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\Multi-Protocol Unified Hello\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force 

    # Disable PCT 1.0
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\PCT 1.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force 

    # Disable SSL 2.0 (PCI Compliance)
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 2.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force 

    # Disable SSL 3.0 (PCI Compliance) and enable "Poodle" protection
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\SSL 3.0\Server' -name Enabled -value 0 -PropertyType 'DWord' -Force 

    # Add and Enable TLS 1.0 for client and server SCHANNEL communications
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'Enabled' -value '0xffffffff' -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.0\Server' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force 

    # Add and Enable TLS 1.1 for client and server SCHANNEL communications
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -Force 
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'Enabled' -value '0xffffffff' -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Server' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'Enabled' -value 1 -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.1\Client' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force 

    # Add and Enable TLS 1.2 for client and server SCHANNEL communications
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force 
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'Enabled' -value '0xffffffff' -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'Enabled' -value 1 -PropertyType 'DWord' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'DisabledByDefault' -value 0 -PropertyType 'DWord' -Force 

    # Re-create the ciphers key.
    New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers' -Force 

    # Disable insecure/weak ciphers.
    # - RC4: Disabling RC4 may lock out WinXP/IE8. This is a requirement for FIPS 140-2.
    $insecureCiphers = @(
      'DES 56/56',
      'NULL',
      'RC2 128/128',
      'RC2 40/128',
      'RC2 56/128',
      'RC4 40/128',
      'RC4 56/128',
      'RC4 64/128’,
      'RC4 128/128'
    )

    Foreach ($insecureCipher in $insecureCiphers) {
      $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($insecureCipher)
      $key.SetValue('Enabled', 0, 'DWord')
      $key.close()
    }

    # Enable new secure ciphers.
    # - 3DES: It is recommended to disable these in near future.
    $secureCiphers = @(
      'AES 128/128',
      'AES 256/256',
      'Triple DES 168/168'
    )

    Foreach ($secureCipher in $secureCiphers) {
      $key = (Get-Item HKLM:\).OpenSubKey('SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers', $true).CreateSubKey($secureCipher)
      New-ItemProperty -path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Ciphers\$secureCipher" -name 'Enabled' -value '0xffffffff' -PropertyType 'DWord' -Force 
      $key.close()
    }

    # Set hashes configuration.
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\MD5' -name Enabled -value 0 -PropertyType 'DWord' -Force 
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\SHA' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Hashes\SHA' -name Enabled -value '0xffffffff' -PropertyType 'DWord' -Force 

    # Set KeyExchangeAlgorithms configuration.
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\Diffie-Hellman' -name Enabled -value '0xffffffff' -PropertyType 'DWord' -Force 
    New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS' -Force 
    New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\KeyExchangeAlgorithms\PKCS' -name Enabled -value '0xffffffff' -PropertyType 'DWord' -Force 

    # Set cipher suites order as secure as possible (Enables Perfect Forward Secrecy).
    $cipherSuitesOrder = @(
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P521',
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P384',
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA384_P256',
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P521',
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P384',
      'TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA_P256',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P521',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P521',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P384',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA256_P256',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P384',
      'TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA_P256',
      'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256_P256',
      'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA384_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_256_CBC_SHA_P256',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA256_P256',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P521',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P384',
      'TLS_ECDHE_ECDSA_WITH_AES_128_CBC_SHA_P256',
      'TLS_DHE_DSS_WITH_AES_256_CBC_SHA256',
      'TLS_DHE_DSS_WITH_AES_256_CBC_SHA',
      'TLS_DHE_DSS_WITH_AES_128_CBC_SHA256',
      'TLS_DHE_DSS_WITH_AES_128_CBC_SHA',
      'TLS_DHE_DSS_WITH_3DES_EDE_CBC_SHA',
      'TLS_RSA_WITH_AES_256_CBC_SHA256',
      'TLS_RSA_WITH_AES_256_CBC_SHA',
      'TLS_RSA_WITH_AES_128_CBC_SHA256',
      'TLS_RSA_WITH_AES_128_CBC_SHA',
      'TLS_RSA_WITH_RC4_128_SHA',
      'TLS_RSA_WITH_3DES_EDE_CBC_SHA'
    )

    $cipherSuitesAsString = [string]::join(',', $cipherSuitesOrder)
    New-ItemProperty -path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002' -name 'Functions' -value $cipherSuitesAsString -PropertyType 'String' -Force 

    Write-Host -ForegroundColor Red ‘You must restart the computer for these changes to take effect.'
}

function total_backout () {
    $SCHANNEL_Items="Ciphers",
    "CipherSuites",
    "Hashes",
    "KeyExchangeAlgorithms",
    "Protocols"
    Remove-Item 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002'-Recurse -Force -Verbose
    New-Item -path 'HKLM:\SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL' -Name '00010002' -Verbose
    Remove-Item "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" -Recurse -Force -Verbose
    New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders" -Name "SCHANNEL" -Verbose
    $SCHANNEL_Items | ForEach {
        $newkey=$_
        New-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" -Name $newkey -Verbose
    }
}

function enable ($TLS) {
    # Create the TLS key and Enable it
    create_the_key $TLS
    #get-childitem $My_path -Recurse
    "Server","Client" | ForEach {
        $Name=$_
        "DisabledByDefault" | ForEach {
            $KEY=$_ 
            If ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq $null) { New-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "0" -PropertyType "DWord" -Verbose}
            Elseif ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq "0") { Write-Host "Already setup correctly" -ForegroundColor Green }
            Else { Set-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "0" -Verbose }
        }
        "Enabled" | ForEach {
            $KEY=$_ 
            If ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq $null) { New-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "4294967295" -PropertyType "DWord" -Verbose}
            Elseif ($(Get-ItemProperty -Path "$My_path\$Name").$KEY -eq "4294967295") { Write-Host "Already setup correctly" -ForegroundColor Green }
            Else { Set-ItemProperty -Path "$My_path\$Name" -Name $KEY -Value "4294967295" -Verbose }
        }
    }
}
$quit=$false
$version = [string]"1.0"
$agency = "DOR"

While ($quit -ne $true) {
# Install VPN and Agency bookmarks to Internet Explorer Favorites and Favorites Bar
Clear
Write-Host "
       Title: Set TLS protocols settings
      Agency: $agency
     Version: $version
     Purpose: This script will install and display the TLS Settings in the Windows Registry
        Date: August 21, 2020
      Author: Edward Hunt
       Title: DOR - Information Technology Division Supervisor
Requirements: Make sure the operating system and load balancer is compatible with the TLS settings.`n"
    Write-Host "    1 - Disable TLS_1.0
    2 - Disable TLS_1.1
    3 - Enable TLS_1.1
    4 - Enable TLS_1.2
    5 - Enable TLS_1.3 (reserved for Windows 2019 OS)
    6 - Enable Full Server Hardening, TLS & Cypher Suites, & SSL over IIS
    7 - Show all SCHANNEL settings
    8 - Backout all SCHANNEL settings
    9 - QUIT`n" -ForegroundColor yellow
    switch (Read-Host "Which describes the TLS setting you prefer? Default = [4] ?") {
        1 { $TLS="TLS 1.0"; disable $TLS; read-host "Continue [RETURN]" }
        2 { $TLS="TLS 1.1"; disable $TLS; read-host "Continue [RETURN]" }
        3 { $TLS="TLS 1.1"; enable $TLS; read-host "Continue [RETURN]" } 
        4 { $TLS="TLS 1.2"; enable $TLS; read-host "Continue [RETURN]" }
        5 { $TLS="TLS 1.3"; enable $TLS; read-host "Continue [RETURN]" }
        6 { HardeningScript; read-host "Continue [RETURN]" }
        7 { get-childitem "Registry::HKLM\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL" -Recurse; read-host "Continue [RETURN]" }
        8 { total_backout; read-host "Continue [RETURN]" }
        9 { $quit=$true }
        default { $TLS="TLS 1.2"; enable; read-host "Continue [RETURN]" }
    }
}
