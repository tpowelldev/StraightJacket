function Set-LCMAttribute
{
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ActionAfterReboot
    Parameter description

    .PARAMETER AllowModuleOverwrite
    Parameter description

    .PARAMETER ConfigurationMode
    Parameter description

    .PARAMETER ConfigurationModeFrequencyMins
    Parameter description

    .PARAMETER RebootNodeIfNeeded
    Parameter description

    .PARAMETER RefreshMode
    Parameter description

    .PARAMETER RefreshFrequencyMins
    Parameter description

    .PARAMETER StatusRetentionTimeInDays
    Parameter description

    .EXAMPLE
    Set-LCMAttribute -RefreshMode Disabled

    Disable the DSC LCM

    .EXAMPLE
    Set-LCMAttribute -RefreshMode Pull

    Enable the DSC LCM, using Pull mode

    .NOTES

    #>

    [cmdletbinding()]
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