function Test-IOTBitLocker {
    [CmdletBinding()]
    param()

    $check = [pscustomobject]@{
        Name = 'BitLocker'
        Status = 'Fail'
        Evidence = ''
        RemediationHint = 'Turn on BitLocker protection and ensure a Recovery Key/TPM protector exists (policy/Intune escrow).'
    }

    $drive = $env:SystemDrive
    $protText = 'Unknown'
    $keyProtectors = 'Unknown'

    try {
        $vol = Get-CimInstance -Namespace 'root\cimv2\Security\MicrosoftVolumeEncryption' -ClassName Win32_EncryptableVolume -Filter "DriveLetter='$drive'" -ErrorAction Stop

        if (-not $vol) {
            $check.Status = 'Fail'
            $check.Evidence = "Volume not found for $drive"
            return $check
        }

        $prot = $vol.ProtectionStatus
        $statusMap = @{
            0 = 'Off'
            1 = 'On'
            2 = 'Unknown'
        }

        $protText = if ($statusMap.ContainsKey($prot)) { $statusMap[$prot] } else { 'Unknown' }

        if ($vol.PSObject.Methods.Name -contains 'GetKeyProtectors') {
            $kpResult = $vol.GetKeyProtectors(0)
            if ($kpResult.ReturnValue -eq 0 -and $kpResult.VolumeKeyProtectorID) {
                $keyProtectors = 'Present'
            } else {
                $keyProtectors = 'NoneFound'
            }
        }

        if ($prot -eq 1) {
            $check.Status = 'Pass'
        } else {
            $check.Status = 'Warn'
        }

        $check.Evidence = "ProtectionStatus=$protText; KeyProtectors=$keyProtectors"
    } catch {
        $manageOutput = & manage-bde.exe -status $drive 2>$null
        if ($LASTEXITCODE -eq 0 -and $manageOutput) {
            $lines = @($manageOutput)
            $keyProtectors = 'NoneFound'
            $protLine = $lines | Where-Object { $_ -match 'Protection Status|Status de Protec..o' } | Select-Object -First 1
            if ($protLine -match ':\s*(.+)$') {
                $raw = $Matches[1].Trim()
                if ($raw -match 'On|Ativ') {
                    $protText = 'On'
                } elseif ($raw -match 'Off|Desativ|Deslig') {
                    $protText = 'Off'
                }
            }

            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($lines[$i] -match '^\s*(Key Protectors|Protetores de Chave)\s*:') {
                    $found = $false
                    for ($j = $i + 1; $j -lt $lines.Count; $j++) {
                        if ($lines[$j] -match '^\s*$') { break }
                        if ($lines[$j] -match '^\s+\S') { $found = $true; continue }
                        break
                    }
                    if ($found) {
                        $keyProtectors = 'Present'
                    } else {
                        $keyProtectors = 'NoneFound'
                    }
                    break
                }
            }

            if ($protText -eq 'On') {
                $check.Status = 'Pass'
            } else {
                $check.Status = 'Warn'
            }

            $check.Evidence = "ProtectionStatus=$protText; KeyProtectors=$keyProtectors"
        } else {
            $check.Status = 'Fail'
            $check.Evidence = "Failed to query BitLocker status. ErrorType=$($_.Exception.GetType().Name)"
        }
    }

    return $check
}
