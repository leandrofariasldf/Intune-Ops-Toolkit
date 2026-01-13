function Test-IOTAutopilotReadiness {
    [CmdletBinding()]
    param()

    Write-IOTLog -Level INFO -Message 'Starting Autopilot readiness checks.'

    $checks = @()
    $checks += Test-IOTTpm
    $checks += Test-IOTSecureBoot
    $checks += Test-IOTBitLocker

    $minFree = [int]$script:IOTConfig.MinFreeDiskGB
    if (-not $minFree) { $minFree = 10 }

    $diskCheck = [pscustomobject]@{
        Name = 'Disk Space'
        Status = 'Fail'
        Evidence = ''
        RemediationHint = 'Free up disk space to reach the required threshold.'
    }

    try {
        $driveName = $env:SystemDrive.TrimEnd(':')
        $drive = Get-PSDrive -Name $driveName -ErrorAction Stop
        $freeGB = [math]::Round($drive.Free / 1GB, 2)

        if ($freeGB -ge $minFree) {
            $diskCheck.Status = 'Pass'
        } else {
            $diskCheck.Status = 'Fail'
        }

        $diskCheck.Evidence = "FreeGB=$freeGB; RequiredGB=$minFree"
    } catch {
        $diskCheck.Status = 'Fail'
        $diskCheck.Evidence = "Failed to query disk space. ErrorType=$($_.Exception.GetType().Name)"
    }

    $checks += $diskCheck

    $overall = 'Pass'
    if ($checks.Status -contains 'Fail') {
        $overall = 'Fail'
    } elseif ($checks.Status -contains 'Warn') {
        $overall = 'Warn'
    }

    $result = [pscustomobject]@{
        Device = Get-IOTDeviceContext
        Checks = $checks
        OverallStatus = $overall
        Timestamp = (Get-Date).ToString('o')
    }

    Write-IOTLog -Level INFO -Message ("Completed Autopilot readiness checks. Result: {0}" -f $overall)
    return $result
}
