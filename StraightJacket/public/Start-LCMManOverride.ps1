function Start-LCMManOverride
{
    <#
    .SYNOPSIS
    Configure LCM Manager override

    .DESCRIPTION
    Sets a flag that overrides any existing schedule and enables the DSC LCM with the specified RefreshMode

    .PARAMETER RefreshMode
    Defines whether the LCM is configured with a RefreshMode of either Push or Pull when active, to match the environment

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Start-LCMManOverride -RefreshMode Push

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [ValidateSet('Pull','Push')]
        [string]$RefreshMode = 'Pull',

        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $null = Set-ItemProperty -Path $RootRegPath -Name OverrideOn -Value 1
    Set-LCMAttribute -RefreshMode $RefreshMode
}