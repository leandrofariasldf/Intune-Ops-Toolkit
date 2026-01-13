$modulePath = Join-Path $PSScriptRoot '..\..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

$result = Test-IOTAutopilotReadiness -Verbose
if ($result.OverallStatus -eq 'Pass') {
    exit 0
} else {
    exit 1
}
