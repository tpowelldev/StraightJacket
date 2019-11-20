function Stop-LCMManOverride
{
    <#
    .SYNOPSIS
    Unconfigure LCM Manager override

    .DESCRIPTION
    Removes the flag that overrides any existing schedule and ensures the schedules are used to activate/deactivate the DSC LCM

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Stop-LCMManOverride

    Disables override

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    Set-LCMAttribute -RefreshMode Disabled
    $null = Set-ItemProperty -Path $RootRegPath -Name OverrideOn -Value 0
}