function Set-LCMAttribute
{
    <#
    .SYNOPSIS
    Configures the DSC LCM

    .DESCRIPTION
    Updates the DSC LCM with the specified parameters by creating and applying a meta mof configuration file

    .PARAMETER ActionAfterReboot
    Action for DSC to take after a reboot. Either continue with configuration or stop

    .PARAMETER AllowModuleOverwrite
    Allow DSC to overwrite exiting modules

    .PARAMETER ConfigurationMode
    Mode in which DSC will operate. Valid options being ApplyOnly, ApplyAndMonitor or ApplyAndAutoCorrect

    .PARAMETER ConfigurationModeFrequencyMins
    How often DSC should apply the configuration

    .PARAMETER RebootNodeIfNeeded
    If the configuration requires a reboot, whether this allowed or not

    .PARAMETER RefreshMode
    Specifies whether the LCM operates in Push or Pull mode, or is disabled

    .PARAMETER RefreshFrequencyMins
    How often the LCM will check for new configuration

    .PARAMETER StatusRetentionTimeInDays
    How long the LCM will keep status

    .EXAMPLE
    Set-LCMAttribute -RefreshMode Disabled

    Disable the DSC LCM

    .EXAMPLE
    Set-LCMAttribute -RefreshMode Pull

    Enable the DSC LCM, using Pull mode

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [ValidateSet('ContinueConfiguration','StopConfiguration')]
        [string]$ActionAfterReboot,

        [bool]$AllowModuleOverwrite,

        [ValidateSet('ApplyOnly','ApplyAndMonitor','ApplyAndAutoCorrect')]
        [string]$ConfigurationMode,

        [int]$ConfigurationModeFrequencyMins,

        [bool]$RebootNodeIfNeeded,

        [ValidateSet('Disabled','Pull','Push')]
        [string]$RefreshMode,

        [int]$RefreshFrequencyMins,

        [int]$StatusRetentionTimeInDays
    )

    $currentLCMConfig = Get-DscLocalConfigurationManager

    if ($RefreshMode -eq 'Pull' -and
        ($null -eq $currentLCMConfig.ConfigurationID -or
        $null -eq $currentLCMConfig.ConfigurationDownloadManagers))
    {
        throw "'RefreshMode: Pull' has been specified, but this server hasn't previously been configured for Pull mode. `
        ConfigurationID and/or ConfigurationDownloadManagers are missing"
    }

    [DscLocalConfigurationManager()]
    Configuration SetLCMConfig
    {
        Node 'localhost'
        {
            Settings
            {
                ActionAfterReboot               = if ($ActionAfterReboot) { $ActionAfterReboot } else { $currentLCMConfig.ActionAfterReboot }
                AllowModuleOverwrite            = if ($null -ne $AllowModuleOverwrite) { $AllowModuleOverwrite } else { $currentLCMConfig.AllowModuleOverwrite }
                CertificateID                   = $currentLCMConfig.CertificateID
                ConfigurationID                 = $currentLCMConfig.ConfigurationID
                ConfigurationMode               = if ($ConfigurationMode) { $ConfigurationMode } else { $currentLCMConfig.ConfigurationMode }
                ConfigurationModeFrequencyMins  = if ($ConfigurationModeFrequencyMins) { $ConfigurationModeFrequencyMins } else { $currentLCMConfig.ConfigurationModeFrequencyMins }
                RebootNodeIfNeeded              = if ($null -ne $RebootNodeIfNeeded) { $RebootNodeIfNeeded } else { $currentLCMConfig.RebootNodeIfNeeded }
                RefreshMode                     = if ($RefreshMode) { $RefreshMode } else { $currentLCMConfig.RefreshMode }
                RefreshFrequencyMins            = if ($RefreshFrequencyMins) { $RefreshFrequencyMins } else { $currentLCMConfig.RefreshFrequencyMins }
                StatusRetentionTimeInDays       = if ($StatusRetentionTimeInDays) { $StatusRetentionTimeInDays } else { $currentLCMConfig.StatusRetentionTimeInDays }
            }

            if ($currentLCMConfig.ConfigurationDownloadManagers)
            {
                ConfigurationRepositoryShare ConfigurationRepositoryShare
                {
                    SourcePath = $currentLCMConfig.ConfigurationDownloadManagers.SourcePath
                }
            }

            if ($currentLCMConfig.ResourceModuleManagers)
            {
                ResourceRepositoryShare ResourceRepositoryShare
                {
                    SourcePath = $currentLCMConfig.ResourceModuleManagers.SourcePath
                }
            }
        }
    }
    $null = SetLCMConfig -OutputPath $env:TEMP

    Set-DscLocalConfigurationManager -Path $env:TEMP -ComputerName 'localhost'
    $null = Remove-Item "$env:TEMP\localhost.meta.mof" -Force
}