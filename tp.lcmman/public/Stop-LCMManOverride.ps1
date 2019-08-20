function Stop-LCMManOverride
{
    <#
    .SYNOPSIS
    Unconfigure LCM Manager override

    .DESCRIPTION
    Removes the flag that overrides any existing schedule and ensures the schedules are used to activate/deactivate the DSC LCM

    .PARAMETER RegRootPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Stop-LCMManOverride

    Disables override

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [string]$RegRootPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    Set-LCMAttribute -RefreshMode Disabled
    $null = Set-ItemProperty -Path $RegRootPath -Name OverrideOn -Value 0
}