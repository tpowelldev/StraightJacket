function New-LCMManSchedule
{
    <#
    .SYNOPSIS
    Creates a new LCM Manager schedule

    .DESCRIPTION
    Uses the defined schedule parameters to create a recurring schedule

    .PARAMETER StartTime
    Time at which the schedule starts, activating the LCM. (HH:MM:SS)

    .PARAMETER EndTime
    Time at which the schedule ends and the LCM will disable again. (HH:MM:SS)

    .PARAMETER Days
    Configures the schedule to activate on each day specified in the supplied array of days

    .PARAMETER Weekend
    Configures the schedule on both days of the weekend

    .PARAMETER All
    Configures the schedule on every day of the week

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    New-LCMManSchedule -StartTime 08:00 -EndTime 12:00 -Saturday

    Configures a schedule to activate the LCM between 8am and 12pm each Saturday

    .EXAMPLE
    New-LCMManSchedule -Weekend

    Configures a schedule to activate the LCM for the whole weekend

    .EXAMPLE
    New-LCMManSchedule -StartTime 22:00 -EndTime 23:59 -All

    Configures a schedule to activate the LCM every day for two hours

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [datetime]$StartTime = '00:00:00',
        [datetime]$EndTime = '23:59:59',

        [Parameter(ParameterSetName='Days')]
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
        [string[]]$Days,

        [Parameter(ParameterSetName='Weekend')]
        [switch]$Weekend,

        [Parameter(ParameterSetName='All')]
        [switch]$All,

        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $keyGUID = New-Guid
    $null = New-Item -Path "$RootRegPath\Schedules" -Name $keyGUID -Force

    $schedKey = "$RootRegPath\Schedules\$keyGUID"

    if ($Days)    { $daysActive = $Days -join ',' }
    if ($Weekend) { $daysActive = 'Saturday,Sunday' }
    if ($All)     { $daysActive = 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday' }

    $null = New-ItemProperty -Path $schedKey -Name LastEditor -Value $env:USERNAME -PropertyType String
    $null = New-ItemProperty -Path $schedKey -Name StartTime -Value $StartTime.TimeOfDay.ToString() -PropertyType String
    $null = New-ItemProperty -Path $schedKey -Name EndTime -Value $EndTime.TimeOfDay.ToString() -PropertyType String
    $null = New-ItemProperty -Path $schedKey -Name DaysActive -Value $daysActive -PropertyType String
}