function Write-IOTLog {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('INFO','WARN','ERROR','DEBUG')]
        [string]$Level,

        [Parameter(Mandatory)]
        [string]$Message
    )

    $logRoot = $script:IOTConfig.LogPath
    if (-not $logRoot) {
        $logRoot = Join-Path $env:ProgramData 'IntuneOpsToolkit\Logs'
    }

    if (-not (Test-Path -Path $logRoot)) {
        New-Item -ItemType Directory -Path $logRoot -Force | Out-Null
    }

    $dateStamp = Get-Date -Format 'yyyyMMdd'
    $logPath = Join-Path $logRoot ("IOT-{0}.log" -f $dateStamp)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    $line = '{0} [{1}] {2}' -f $timestamp, $Level, $Message

    if ($PSCmdlet.ShouldProcess($logPath, 'Write log entry')) {
        Add-Content -Path $logPath -Value $line -Encoding UTF8
    }

    Write-Verbose $line
}
