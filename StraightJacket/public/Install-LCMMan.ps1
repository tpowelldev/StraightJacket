function Install-LCMMan
{
    <#
    .SYNOPSIS
    Install LCMMan LCM Management

    .DESCRIPTION
    Installs the necessary scheduled task and registry keys to configure LCM Manager. This tool manages enabling and disabling the DSC LCM to any configured schedules

    .PARAMETER TriggerParams
    A hashtable containing the required parameters to configure the scheduled task trigger

    .PARAMETER RootRegPath
    Root registry location where LCMMan keys are located

    .EXAMPLE
    $triggerParams = @{
            At                  = '00:00:00'
            Daily               = $true
            RepetitionDuration  = 'P1D'
            RepetitionInterval  = 'PT5M'
    }
    Install-LCMMan -TriggerParams @triggerParams

    Configures a trigger schedule to run daily at 00:00 with a repetition of 5 minutes, lasting for 1 day

    .NOTES

    #>

    param
    (
        [hashtable]$TriggerParams = @{
            At                  = '00:00:00'
            Daily               = $true
            DaysInterval        = $null
            DaysOfWeek          = $null
            Weekly              = $null
            WeeksInterval       = $null
            RepetitionDuration  = 'P1D'
            RepetitionInterval  = 'PT5M'
        },
        [string]$RootRegPath = 'HKLM:\SOFTWARE\LCMMan'
    )

    # Create required registry keys for storing schedules
    if (-not (Test-Path "$RootRegPath\Schedules"))
    {
        $null = New-Item -Path $RootRegPath -Name 'Schedules' -Force
        $null = New-ItemProperty -Path $RootRegPath -Name OverrideOn -Value 0 -PropertyType DWord -Force
    }

    # If repetition has been set remove keys for later configuration
    if ($TriggerParams.ContainsKey('RepetitionDuration'))
    {
        $StRepDuration = $TriggerParams['RepetitionDuration']
        $TriggerParams.Remove('RepetitionDuration')
    }

    if ($TriggerParams.ContainsKey('RepetitionInterval'))
    {
        $StRepInterval = $TriggerParams['RepetitionInterval']
        $TriggerParams.Remove('RepetitionInterval')
    }

    # Remove null keys
    $TriggerParamsClone = $TriggerParams.Clone()
    foreach ($item in $TriggerParamsClone.GetEnumerator())
    {
        if ($null -eq $item.Value) { $TriggerParams.Remove($item.Key) }
    }

    # Register the scheduled task
    if (-not (Get-ScheduledTask -TaskName 'LCMMan' -ErrorAction SilentlyContinue))
    {
        $action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -Command "Import-Module StraightJacket -Force; Invoke-LCMMan"'
        $trigger = New-ScheduledTaskTrigger @TriggerParams

        $null = Register-ScheduledTask -Action $action -Trigger $trigger -TaskName 'LCMMan' -Description "DSC LCM Manager & Scheduler"
    }
    $task = Get-ScheduledTask -TaskName 'LCMMan'

    # Add repetition configuration, if defined
    if ($null -ne $StRepDuration -and $null -ne $StRepInterval)
    {
        $task.Triggers.Repetition.Duration = $StRepDuration
        $task.Triggers.Repetition.Interval = $StRepInterval
    }
    $null = $task | Set-ScheduledTask -User "NT AUTHORITY\SYSTEM"
}