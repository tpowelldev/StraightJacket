function Uninstall-LCMMan
{
    <#
    .SYNOPSIS
    Uninstalls LCM Manager

    .DESCRIPTION
    Uninstalls the scheduled task and registry keys associated with LCM Manager

    .PARAMETER RegRootPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Uninstall-LCMMan

    Uninstalls associated scheduled task and registry keys

    .NOTES

    #>

    param
    (
        [string]$RegRootPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    if (Test-Path $RegRootPath)
    {
        $null = Remove-Item -Path $RegRootPath -Force
    }

    if (Get-ScheduledTask -TaskName 'LCMMan' -ErrorAction SilentlyContinue)
    {
        Unregister-ScheduledTask -TaskName 'LCMMan' -Confirm:$false
    }
}