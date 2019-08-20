function Invoke-LCMMan
{
    <#
    .SYNOPSIS
    Invokes LCM Manager

    .DESCRIPTION
    Collects the currently configured LCMMan schedules and changes the state of the DSC LCM to match the discovered schedules (active/disable)

    Futher, the RefreshMode of the LCM can be specified when active, either Push or Pull

    .PARAMETER RefreshMode
    Defines whether the LCM is configured with a RefreshMode of either Push or Pull when active, to match the environment

    .PARAMETER RegRootPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Invoke-LCMMan -RefreshMode Push

    .NOTES

    #>

    [CmdletBinding()]
    param
    (
        [ValidateSet('Pull','Push')]
        [string]$RefreshMode = 'Pull',

        [string]$RegRootPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $overrideOn = Get-ItemProperty -Path $RegRootPath -Name OverrideOn
    $currentRefreshMode = (Get-DscLocalConfigurationManager).RefreshMode

    if ($overrideOn -ne 1)
    {
        if (Get-LCMManSchedule | Where-Object ActiveNow)
        {
            Write-Verbose "Active schedule matched. Checking LCM, RefreshMode: $RefreshMode"
            if ($currentRefreshMode -ne $RefreshMode)
            {
                Set-LCMAttribute -RefreshMode $RefreshMode
                Write-Verbose "Local LCM RefreshMode was: $currentRefreshMode, Configured LCM RefreshMode to: $RefreshMode"
            }
            else
            {
                Write-Verbose "Local LCM RefreshMode currently: $currentRefreshMode, no action required"
            }
        }
        else
        {
            Write-Verbose "No active schedule matched. Checking LCM, RefreshMode: Disabled"
            if ($currentRefreshMode -ne 'Disabled')
            {
                Set-LCMAttribute -RefreshMode 'Disabled'
                Write-Verbose "Local LCM RefreshMode was: $currentRefreshMode, Configured LCM RefreshMode to: Disabled"
            }
            else
            {
                Write-Verbose "Local LCM RefreshMode currently: $currentRefreshMode, no action required"
            }
        }
    }
    else
    {
        Write-Verbose "Override is currently active. Ignoring schedule"
    }
}