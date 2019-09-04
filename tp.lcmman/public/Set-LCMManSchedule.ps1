function Set-LCMManSchedule
{
    <#
    .SYNOPSIS
    Reconfigures an existing LCM Manager schedule

    .DESCRIPTION
    Using the supplied schedule GUID, either specified or from the pipeline, reconfigures the schedule

    .PARAMETER ScheduleID
    GUID of schedule to be reconfigured, as listed by Get-LCMManSchedule

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
    Set-LCMManSchedule -ScheduleID c3ba85f5-5336-4d7b-b861-ff34d212c83f -StartTime 09:00 -EndTime 21:00

    Reconfigure schedule with ID c3ba85f5-5336-4d7b-b861-ff34d212c83f to activate between 09:00 and 21:00

    .EXAMPLE
    Get-LCMManSchedule | ? DaysActive -eq Friday | Set-LCMManSchedule -DaysActive Saturday

    Reconfigures all schedules configured to trigger on Friday, to trigger on Saturday instead

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low', DefaultParameterSetName='None')]
    param
    (
        [Parameter(Mandatory,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String[]]$ScheduleID,

        [datetime]$StartTime,

        [datetime]$EndTime,

        [Parameter(ParameterSetName='Days')]
        [ValidateSet('Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday')]
        [string[]]$Days,

        [Parameter(ParameterSetName='Weekend')]
        [switch]$Weekend,

        [Parameter(ParameterSetName='All')]
        [switch]$All,

        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    process {
        foreach ($sid in $ScheduleID) {
            $schedKey = "$RootRegPath\Schedules\$sid"
            if (-not (Test-Path $schedKey)) { throw "ScheduleID: $sid doesn't exist. Cannot set" }

            $existingKey = Get-ItemProperty $schedKey

            switch ($PSBoundParameters) {
                {$_.ContainsKey('Days')} {
                    $daysActive = $Days -join ','
                    Set-ItemProperty -Path $schedKey -Name DaysActive -Value $daysActive
                }
                {$_.ContainsKey('Weekend')} {
                    $daysActive = 'Saturday,Sunday'
                    Set-ItemProperty -Path $schedKey -Name DaysActive -Value $daysActive
                }
                {$_.ContainsKey('All')} {
                    $daysActive = 'Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday'
                    Set-ItemProperty -Path $schedKey -Name DaysActive -Value $daysActive
                }
                {$_.ContainsKey('StartTime') -and $_.ContainsKey('EndTime')} {
                    if ($StartTime -gt $EndTime) { throw "End time cannot be before start time" }
                    Set-ItemProperty -Path $schedKey -Name StartTime -Value $StartTime.TimeOfDay.ToString()
                    Set-ItemProperty -Path $schedKey -Name EndTime -Value $EndTime.TimeOfDay.ToString()
                    break
                }
                {$_.ContainsKey('StartTime')} {
                    if ($StartTime -gt [datetime]$existingKey.EndTime) { throw "End time cannot be before start time" }
                    Set-ItemProperty -Path $schedKey -Name StartTime -Value $StartTime.TimeOfDay.ToString()
                }
                {$_.ContainsKey('EndTime')} {
                    if ([datetime]$existingKey.StartTime -gt $EndTime) { throw "End time cannot be before start time" }
                    Set-ItemProperty -Path $schedKey -Name EndTime -Value $EndTime.TimeOfDay.ToString()
                }
            }
            Set-ItemProperty -Path $schedKey -Name LastEditor -Value $env:USERNAME
        }
    }
}