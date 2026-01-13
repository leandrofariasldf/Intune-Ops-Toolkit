$destination = Join-Path $env:ProgramFiles 'IntuneOpsToolkit'

if (Test-Path -Path $destination) {
    Remove-Item -Path $destination -Recurse -Force
}

Write-Output 'Removed IntuneOpsToolkit module files. Logs remain in ProgramData.'
