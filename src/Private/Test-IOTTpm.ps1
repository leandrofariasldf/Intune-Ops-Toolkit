function Test-IOTTpm {
    [CmdletBinding()]
    param()

    $check = [pscustomobject]@{
        Name = 'TPM 2.0'
        Status = 'Fail'
        Evidence = ''
        RemediationHint = 'Enable TPM 2.0 in UEFI/BIOS.'
    }

    try {
        $tpm = Get-CimInstance -Namespace 'root\cimv2\security\microsofttpm' -ClassName Win32_Tpm -ErrorAction Stop
        $spec = $tpm.SpecVersion
        $enabled = $null
        $activated = $null

        if ($tpm.PSObject.Methods.Name -contains 'IsEnabled') {
            $enabled = $tpm.IsEnabled().IsEnabled
        }

        if ($tpm.PSObject.Methods.Name -contains 'IsActivated') {
            $activated = $tpm.IsActivated().IsActivated
        }

        $isTpm2 = $false
        if ($spec -match '2\.0') {
            $isTpm2 = $true
        }

        if ($isTpm2 -and ($enabled -ne $false) -and ($activated -ne $false)) {
            $check.Status = 'Pass'
        } elseif ($isTpm2) {
            $check.Status = 'Warn'
        }

        $check.Evidence = "SpecVersion=$spec; Enabled=$enabled; Activated=$activated"
    } catch {
        $check.Status = 'Fail'
        $check.Evidence = "Failed to query TPM status. ErrorType=$($_.Exception.GetType().Name)"
    }

    return $check
}
