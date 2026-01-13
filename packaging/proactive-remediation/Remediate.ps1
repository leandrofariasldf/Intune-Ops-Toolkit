$modulePath = Join-Path $PSScriptRoot '..\..\src\IntuneOpsToolkit.psd1'
Import-Module $modulePath -Force -ErrorAction Stop

Invoke-IOTFix -Verbose -ExportReport | Out-Null
exit 0
