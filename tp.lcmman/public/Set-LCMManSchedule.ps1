function Set-LCMManSchedule
{
    <#
    .SYNOPSIS
    Reconfigures an existing LCM Manager schedule

    .DESCRIPTION
    Using the supplied schedule GUID, either specified or from the pipeline, reconfigures the schedule

    .PARAMETER ScheduleID
    GUID of schedule to be reconfigured, as listed by Get-LCMManSchedule

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Set-LCMManSchedule -ScheduleID c3ba85f5-5336-4d7b-b861-ff34d212c83f

    .EXAMPLE
    Get-LCMManSchedule | ? DaysActive -eq Friday | Set-LCMManSchedule -DaysActive Saturday

    Reconfigures all schedules configured to trigger on Friday, to trigger on Saturday instead

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
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
            $sid
        }
    }
}