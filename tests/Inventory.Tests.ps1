$modulePath = Join-Path $PSScriptRoot '..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

Describe 'Get-IOTInventory' {
    InModuleScope IntuneOpsToolkit {
        BeforeAll {
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_Processor' } {
                [pscustomobject]@{ Name = 'Mock CPU' }
            }
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_ComputerSystem' } {
                [pscustomobject]@{
                    TotalPhysicalMemory = 8GB
                    Domain = 'CONTOSO'
                }
            }
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_BIOS' } {
                [pscustomobject]@{
                    Manufacturer = 'Contoso'
                    SMBIOSBIOSVersion = '1.0'
                    SerialNumber = 'ABC123'
                    ReleaseDate = '20240101000000.000000+000'
                }
            }
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_OperatingSystem' } {
                [pscustomobject]@{
                    Caption = 'Windows 11'
                    Version = '10.0.22621'
                    BuildNumber = '22621'
                }
            }
            Mock Get-CimInstance -ParameterFilter { $ClassName -eq 'Win32_NetworkAdapterConfiguration' } {
                [pscustomobject]@{
                    Description = 'Ethernet'
                    MACAddress = '00-11-22-33-44-55'
                    IPAddress = @('192.168.1.10')
                }
            }
            Mock Test-IOTTpm {
                [pscustomobject]@{
                    Name = 'TPM 2.0'
                    Status = 'Pass'
                    Evidence = 'Mock TPM'
                    RemediationHint = ''
                }
            }
            Mock Test-IOTBitLocker {
                [pscustomobject]@{
                    Name = 'BitLocker'
                    Status = 'Pass'
                    Evidence = 'Mock BitLocker'
                    RemediationHint = ''
                }
            }
        }

        It 'returns serial number and OS build' {
            $result = Get-IOTInventory
            (($result.BIOS.Serial -ne $null) -and ($result.BIOS.Serial -ne '')) | Should Be $true
            (($result.Device.OSBuild -ne $null) -and ($result.Device.OSBuild -ne '')) | Should Be $true
        }
    }
}
