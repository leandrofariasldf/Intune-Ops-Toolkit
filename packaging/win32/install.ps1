$source = Join-Path $PSScriptRoot '..\..\src'
$destination = Join-Path $env:ProgramFiles 'IntuneOpsToolkit'

if (-not (Test-Path -Path $destination)) {
    New-Item -ItemType Directory -Path $destination -Force | Out-Null
}

Copy-Item -Path (Join-Path $source '*') -Destination $destination -Recurse -Force

$programDataRoot = Join-Path $env:ProgramData 'IntuneOpsToolkit'
foreach ($folder in @('Logs','Output')) {
    New-Item -ItemType Directory -Path (Join-Path $programDataRoot $folder) -Force | Out-Null
}

Write-Output "Installed IntuneOpsToolkit to $destination"
