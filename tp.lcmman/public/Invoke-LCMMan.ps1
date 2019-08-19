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

    [cmdletbinding()]
    param
    (
        [ValidateSet('Pull','Push')]
        [string]$RefreshMode = 'Pull',

        [string]$RegRootPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $overrideOn = Get-ItemProperty -Path $RegRootPath -Name OverrideOn
    if ($overrideOn -ne 1)
    {
        if (Get-LCMManSchedule | Where-Object ActiveNow -eq $true)
        {
            Write-Verbose "Active schedule matched. Setting LCM, Refresh Mode: $RefreshMode"
            Set-LCMAttribute -RefreshMode $RefreshMode
        }
    }
    else
    {
        Write-Verbose "Override is currently active. Ignoring schedule"
    }
}