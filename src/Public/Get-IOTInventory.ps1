function Get-IOTInventory {
    [CmdletBinding()]
    param(
        [switch]$ExportReport
    )

    Write-IOTLog -Level INFO -Message 'Starting inventory collection.'

    $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1
    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $bios = Get-CimInstance -ClassName Win32_BIOS
    $os = Get-CimInstance -ClassName Win32_OperatingSystem

    $tpm = Test-IOTTpm
    $bitLocker = Test-IOTBitLocker

    $nics = Get-CimInstance -ClassName Win32_NetworkAdapterConfiguration -Filter "IPEnabled=TRUE" | ForEach-Object {
        [pscustomobject]@{
            Description = $_.Description
            MACAddress = $_.MACAddress
            IPAddress = ($_.IPAddress -join ',')
        }
    }

    $result = [pscustomobject]@{
        Device = Get-IOTDeviceContext
        CPU = $cpu.Name
        RAMGB = [math]::Round($cs.TotalPhysicalMemory / 1GB, 2)
        BIOS = [pscustomobject]@{
            Manufacturer = $bios.Manufacturer
            Version = $bios.SMBIOSBIOSVersion
            Serial = $bios.SerialNumber
            ReleaseDate = $bios.ReleaseDate
        }
        OS = [pscustomobject]@{
            Caption = $os.Caption
            Version = $os.Version
            Build = $os.BuildNumber
        }
        TPM = $tpm
        BitLocker = $bitLocker
        NICs = $nics
        Timestamp = (Get-Date).ToString('o')
    }

    if ($ExportReport) {
        Export-IOTReport -InputObject $result -ReportName 'IOT-Inventory' | Out-Null
    }

    return $result
}
