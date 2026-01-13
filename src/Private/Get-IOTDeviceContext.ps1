function Get-IOTDeviceContext {
    [CmdletBinding()]
    param()

    $cs = Get-CimInstance -ClassName Win32_ComputerSystem
    $os = Get-CimInstance -ClassName Win32_OperatingSystem

    $timeZone = $script:IOTConfig.TimeZone
    if (-not $timeZone -or $timeZone -eq 'Local') {
        $timeZone = ([TimeZoneInfo]::Local).Id
    }

    [pscustomobject]@{
        ComputerName = $env:COMPUTERNAME
        UserName = $env:USERNAME
        Domain = $cs.Domain
        OSBuild = $os.BuildNumber
        TimeZone = $timeZone
        OrgName = $script:IOTConfig.OrgName
    }
}
