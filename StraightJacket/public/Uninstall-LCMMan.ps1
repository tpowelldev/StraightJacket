function Uninstall-LCMMan
{
    <#
    .SYNOPSIS
    Uninstalls LCM Manager

    .DESCRIPTION
    Uninstalls the scheduled task and registry keys associated with LCM Manager

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Uninstall-LCMMan

    Uninstalls associated scheduled task and registry keys

    .NOTES

    #>

    param
    (
        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    if (Test-Path $RootRegPath)
    {
        $null = Remove-Item -Path $RootRegPath -Force
    }

    if (Get-ScheduledTask -TaskName 'LCMMan' -ErrorAction SilentlyContinue)
    {
        Unregister-ScheduledTask -TaskName 'LCMMan' -Confirm:$false
    }
}