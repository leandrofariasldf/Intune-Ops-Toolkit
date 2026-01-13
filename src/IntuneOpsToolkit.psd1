@{
    RootModule = 'IntuneOpsToolkit.psm1'
    ModuleVersion = '0.1.0'
    GUID = '37a9ce73-834a-4452-983a-ce0a245b925a'
    Author = 'Leandro'
    CompanyName = ''
    Copyright = '(c) 2025'
    Description = 'Intune Ops Toolkit module for readiness and inventory.'
    PowerShellVersion = '5.1'
    FunctionsToExport = @(
        'Invoke-IOTHealthCheck',
        'Get-IOTInventory',
        'Invoke-IOTFix',
        'Test-IOTAutopilotReadiness'
    )
    CmdletsToExport = @()
    VariablesToExport = @()
    AliasesToExport = @()
    PrivateData = @{
        PSData = @{}
    }
}
