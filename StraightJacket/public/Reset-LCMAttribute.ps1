function Reset-LCMAttribute
{
    <#
    .SYNOPSIS
    Resets the DSC LCM to a default state

    .DESCRIPTION
    Creates and applies a meta mof configuration that returns the LCM to a default state, as when first installed

    .EXAMPLE
    Reset-LCMAttribute

    Returns the DSC LCM back to a default state

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param()

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