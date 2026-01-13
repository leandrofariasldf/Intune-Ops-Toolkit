$modulePath = Join-Path $PSScriptRoot '..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

Describe 'Write-IOTLog' {
    InModuleScope IntuneOpsToolkit {
        It 'creates a log file in ProgramData' {
            $logRoot = Join-Path $env:ProgramData 'IntuneOpsToolkit\Logs'
            $script:IOTConfig.LogPath = $logRoot

            Write-IOTLog -Level INFO -Message 'Pester log test'

            $dateStamp = Get-Date -Format 'yyyyMMdd'
            $logPath = Join-Path $logRoot ("IOT-{0}.log" -f $dateStamp)
            (Test-Path -Path $logPath) | Should Be $true
        }
    }
}
