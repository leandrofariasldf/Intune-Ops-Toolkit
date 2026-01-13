$script:ModuleRoot = $PSScriptRoot

$configPath = Join-Path $PSScriptRoot 'Config\IOT.Config.json'
$script:IOTConfig = [pscustomobject]@{}

if (Test-Path -Path $configPath) {
    try {
        $script:IOTConfig = Get-Content -Path $configPath -Raw | ConvertFrom-Json
    } catch {
        $script:IOTConfig = [pscustomobject]@{}
    }
}

if (-not $script:IOTConfig.OutputPath) {
    $script:IOTConfig | Add-Member -NotePropertyName OutputPath -NotePropertyValue (Join-Path $env:ProgramData 'IntuneOpsToolkit\Output') -Force
}

if (-not $script:IOTConfig.LogPath) {
    $script:IOTConfig | Add-Member -NotePropertyName LogPath -NotePropertyValue (Join-Path $env:ProgramData 'IntuneOpsToolkit\Logs') -Force
}

$publicPath = Join-Path $PSScriptRoot 'Public'
$privatePath = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path $privatePath -Filter '*.ps1' | ForEach-Object { . $_.FullName }
Get-ChildItem -Path $publicPath -Filter '*.ps1' | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function @(
    'Invoke-IOTHealthCheck',
    'Get-IOTInventory',
    'Invoke-IOTFix',
    'Test-IOTAutopilotReadiness'
)
