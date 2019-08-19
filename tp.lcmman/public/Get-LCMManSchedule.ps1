function Get-LCMManSchedule
{
    <#
    .SYNOPSIS
    Get information about configured LCMMan schedules

    .DESCRIPTION
    Queries the registry keys located in the root path for LCMMan and returns schedule information for each, including whether the schedule is currently active

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Get-LCMManSchedule

    ScheduleID : b9822879-82ac-436f-8fe9-c42a3a23f311
    StartTime  : 04:00:00
    EndTime    : 12:00:00
    DaysActive : Saturday
    CreatedBy  : Administrator
    ActiveNow  : True

    .NOTES

    #>

    param
    (
        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $now = Get-Date
    $schedules = Get-ChildItem -Path "$RootRegPath\Schedules" | 
    Get-ItemProperty | Select-Object @{n='ScheduleID';e={$_.PSChildName}},
                                    StartTime,
                                    EndTime,
                                    DaysActive,
                                    CreatedBy,
                                    @{n='ActiveNow';e={ $_.DaysActive -contains $now.DayOfWeek -and 
                                    ((Get-Date $_.StartTime) -lt $now -and (Get-Date $_.EndTime) -gt $now) }}
    $schedules
}