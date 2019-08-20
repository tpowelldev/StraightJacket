function Remove-LCMManSchedule
{
    <#
    .SYNOPSIS
    Remove LCM Manager schedule

    .DESCRIPTION
    Using the supplied schedule GUID, either specified or from the pipeline, removes the schedule

    .PARAMETER ScheduleID
    GUID of schedule to be removed, as listed by Get-LCMManSchedule

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    Remove-LCMManSchedule -ScheduleID c3ba85f5-5336-4d7b-b861-ff34d212c83f

    .EXAMPLE
    Get-LCMManSchedule | ? DaysActive -eq Friday | Remove-LCMManSchedule

    Remove all schedules configured to trigger on Friday

    .NOTES

    #>

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Low')]
    param
    (
        [Parameter(Mandatory=$true,ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [String]$ScheduleID,

        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    $null = Remove-Item -Path "$RootRegPath\Schedules\$ScheduleID" -Force -Confirm:$false
}