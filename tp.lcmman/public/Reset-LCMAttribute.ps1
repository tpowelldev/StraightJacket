function Reset-LCMAttribute
{
    <#
    .SYNOPSIS
    Resets the DSC LCM to a default state

    .DESCRIPTION
    Creates and applies a meta mof that returns the LCM to a default state

    .EXAMPLE
    Reset-LCMAttribute

    .NOTES

    #>

    [DscLocalConfigurationManager()]
    Configuration ResetLCMConfig
    {
        Node 'localhost'
        {
            Settings
            {
                ActionAfterReboot   = 'ContinueConfiguration'
                ConfigurationMode   = 'ApplyAndMonitor'
                RebootNodeIfNeeded  = $true
                RefreshMode         = 'Push'
            }
        }
    }
    $null = ResetLCMConfig -OutputPath $OutputPath

    Set-DscLocalConfigurationManager -Path $OutputPath -ComputerName 'localhost'
    $null = Remove-Item "$OutputPath\localhost.meta.mof" -Force
}