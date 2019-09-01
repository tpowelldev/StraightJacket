function Get-LCMManSchedule
{
    <#
    .SYNOPSIS
    Get information about configured LCMMan schedules

    .DESCRIPTION
    Queries the registry keys located in the root path for LCMMan and returns schedule information for each, including whether the schedule is currently active

    .PARAMETER ScheduleID
    ScheduleID of the specific schedule to return

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
        [string]$ScheduleID,
        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $now = Get-Date

    if ($PSBoundParameters.ContainsKey('ScheduleID')) {
        $schedules = Get-Item -Path "$RootRegPath\Schedules\$ScheduleID"
    } else {
        $schedules = Get-ChildItem -Path "$RootRegPath\Schedules"
    }

    if ($schedules) {
        $schedules | Get-ItemProperty | Select-Object @{n='ScheduleID';e={$_.PSChildName}},
            StartTime,
            EndTime,
            @{n='DaysActive';e={@($_.DaysActive -split ',')}},
            CreatedBy,
            @{n='ActiveNow';e={ @($_.DaysActive -split ',') -contains $now.DayOfWeek -and
            ((Get-Date $_.StartTime) -lt $now -and (Get-Date $_.EndTime) -gt $now) }}
    }
}