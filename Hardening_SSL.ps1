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
