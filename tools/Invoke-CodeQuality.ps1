$modulePath = Join-Path $PSScriptRoot '..\src\IntuneOpsToolkit.psd1'
$testsPath = Join-Path $PSScriptRoot '..\tests'

Import-Module $modulePath -Force -ErrorAction Stop
$pesterLegacy = Get-Module -ListAvailable Pester | Where-Object { $_.Version.Major -lt 4 } | Sort-Object Version -Descending | Select-Object -First 1
if ($pesterLegacy) {
    Import-Module $pesterLegacy -Force
} else {
    Import-Module Pester -Force -ErrorAction Stop
}

$result = Invoke-Pester -Path $testsPath -PassThru
if ($result.FailedCount -gt 0) {
    exit 1
}

exit 0
