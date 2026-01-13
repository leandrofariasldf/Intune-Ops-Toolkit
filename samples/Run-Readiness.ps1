$modulePath = Join-Path $PSScriptRoot '..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

$result = Test-IOTAutopilotReadiness -Verbose
$report = Export-IOTReport -InputObject $result -ReportName 'IOT-Readiness'

$sampleOutput = Join-Path $PSScriptRoot 'output'
if (-not (Test-Path -Path $sampleOutput)) {
    New-Item -ItemType Directory -Path $sampleOutput -Force | Out-Null
}

$result | ConvertTo-Json -Depth 6 | Set-Content -Path (Join-Path $sampleOutput 'readiness.json') -Encoding UTF8
Write-Output ("Report: {0}" -f $report.JsonPath)
