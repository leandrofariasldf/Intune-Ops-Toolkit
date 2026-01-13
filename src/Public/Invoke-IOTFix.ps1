function Invoke-IOTFix {
    [CmdletBinding()]
    param(
        [switch]$ExportReport
    )

    $readiness = Test-IOTAutopilotReadiness
    $suggestions = @()

    foreach ($check in $readiness.Checks) {
        if ($check.Status -ne 'Pass') {
            $suggestions += [pscustomobject]@{
                Name = $check.Name
                Status = $check.Status
                Suggestion = $check.RemediationHint
            }

            Write-IOTLog -Level WARN -Message ("Result: Suggestion for {0} - {1}" -f $check.Name, $check.RemediationHint)
        }
    }

    $result = [pscustomobject]@{
        Device = $readiness.Device
        Suggestions = $suggestions
        OverallStatus = $readiness.OverallStatus
        Timestamp = (Get-Date).ToString('o')
    }

    if ($ExportReport) {
        Export-IOTReport -InputObject $result -ReportName 'IOT-Remediation' | Out-Null
    }

    return $result
}
