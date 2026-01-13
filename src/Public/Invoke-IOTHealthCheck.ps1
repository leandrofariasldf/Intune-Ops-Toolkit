function Invoke-IOTHealthCheck {
    [CmdletBinding()]
    param(
        [switch]$ExportReport
    )

    $result = Test-IOTAutopilotReadiness

    if ($ExportReport) {
        Export-IOTReport -InputObject $result -ReportName 'IOT-Readiness' | Out-Null
    }

    return $result
}
