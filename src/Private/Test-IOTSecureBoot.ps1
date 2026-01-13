function Test-IOTSecureBoot {
    [CmdletBinding()]
    param()

    $check = [pscustomobject]@{
        Name = 'Secure Boot'
        Status = 'Fail'
        Evidence = ''
        RemediationHint = 'Enable Secure Boot in UEFI/BIOS.'
    }

    try {
        $enabled = Confirm-SecureBootUEFI -ErrorAction Stop
        if ($enabled) {
            $check.Status = 'Pass'
        } else {
            $check.Status = 'Fail'
        }

        $check.Evidence = "SecureBootEnabled=$enabled"
    } catch {
        $check.Status = 'Fail'
        $check.Evidence = "Failed to query Secure Boot status. ErrorType=$($_.Exception.GetType().Name)"
    }

    return $check
}
