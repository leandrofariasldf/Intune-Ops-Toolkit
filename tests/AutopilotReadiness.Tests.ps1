$modulePath = Join-Path $PSScriptRoot '..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

Describe 'Test-IOTAutopilotReadiness' {
    InModuleScope IntuneOpsToolkit {
        BeforeAll {
            Mock Test-IOTTpm {
                [pscustomobject]@{
                    Name = 'TPM 2.0'
                    Status = 'Pass'
                    Evidence = 'Mock TPM'
                    RemediationHint = ''
                }
            }
            Mock Test-IOTSecureBoot {
                [pscustomobject]@{
                    Name = 'Secure Boot'
                    Status = 'Pass'
                    Evidence = 'Mock Secure Boot'
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
            Mock Get-PSDrive { [pscustomobject]@{ Free = 20GB } }
            $script:IOTConfig.MinFreeDiskGB = 10
        }

        It 'returns overall status, checks, and timestamp' {
            $result = Test-IOTAutopilotReadiness
            ($result.PSObject.Properties.Name -contains 'OverallStatus') | Should Be $true
            ($result.PSObject.Properties.Name -contains 'Checks') | Should Be $true
            ($result.PSObject.Properties.Name -contains 'Timestamp') | Should Be $true
        }

        It 'returns checks with required fields' {
            $result = Test-IOTAutopilotReadiness
            foreach ($check in $result.Checks) {
                ($check.PSObject.Properties.Name -contains 'Name') | Should Be $true
                ($check.PSObject.Properties.Name -contains 'Status') | Should Be $true
                ($check.PSObject.Properties.Name -contains 'Evidence') | Should Be $true
            }
        }
    }
}
