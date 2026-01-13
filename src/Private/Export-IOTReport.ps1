function Export-IOTReport {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [object]$InputObject,

        [string]$ReportName = 'IOT-Report',

        [string]$Format
    )

    $outputRoot = $script:IOTConfig.OutputPath
    if (-not $outputRoot) {
        $outputRoot = Join-Path $env:ProgramData 'IntuneOpsToolkit\Output'
    }

    if (-not (Test-Path -Path $outputRoot)) {
        New-Item -ItemType Directory -Path $outputRoot -Force | Out-Null
    }

    $timestamp = Get-Date -Format 'yyyyMMdd-HHmmss'
    $baseName = '{0}-{1}' -f $ReportName, $timestamp
    $jsonPath = Join-Path $outputRoot ($baseName + '.json')

    $formatValue = if ($Format) { $Format } else { $script:IOTConfig.ReportFormat }
    if (-not $formatValue) { $formatValue = 'json' }
    $formatValue = $formatValue.ToLower()

    $json = $InputObject | ConvertTo-Json -Depth 6
    $json | Set-Content -Path $jsonPath -Encoding UTF8
    Write-IOTLog -Level INFO -Message ("Completed report export: {0}" -f $jsonPath)

    $htmlPath = $null
    if ($formatValue -like '*html*') {
        $checks = $null
        if ($InputObject.PSObject.Properties.Name -contains 'Checks') {
            $checks = $InputObject.Checks
        }

        $rows = ''
        if ($checks) {
            foreach ($check in $checks) {
                $rows += "<tr><td>$($check.Name)</td><td>$($check.Status)</td><td>$($check.Evidence)</td><td>$($check.RemediationHint)</td></tr>`n"
            }
        } else {
            $rows = '<tr><td colspan="4">No checks available</td></tr>'
        }

        $html = @"
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">
<title>IntuneOpsToolkit Report</title>
<style>
body { font-family: Segoe UI, Arial, sans-serif; margin: 24px; }
table { border-collapse: collapse; width: 100%; }
th, td { border: 1px solid #d0d0d0; padding: 8px; text-align: left; }
th { background: #f2f2f2; }
</style>
</head>
<body>
<h1>IntuneOpsToolkit Report</h1>
<p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
<table>
<thead>
<tr><th>Name</th><th>Status</th><th>Evidence</th><th>RemediationHint</th></tr>
</thead>
<tbody>
$rows
</tbody>
</table>
</body>
</html>
"@

        $htmlPath = Join-Path $outputRoot ($baseName + '.html')
        $html | Set-Content -Path $htmlPath -Encoding UTF8
        Write-IOTLog -Level INFO -Message ("Completed report export: {0}" -f $htmlPath)
    }

    [pscustomobject]@{
        JsonPath = $jsonPath
        HtmlPath = $htmlPath
    }
}
