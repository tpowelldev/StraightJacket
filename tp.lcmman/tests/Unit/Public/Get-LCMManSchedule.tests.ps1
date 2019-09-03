$here = $PSScriptRoot
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    Describe Get-LCMManSchedule {

        New-Item -Path TestRegistry:\LCMMan\Schedules -Name 'd97efb3c-a759-421d-bed2-6c13b9ba22af' -Force
        $regRoot = 'TestRegistry:\LCMMan\Schedules\d97efb3c-a759-421d-bed2-6c13b9ba22af'
        New-ItemProperty -Path $regRoot -Name LastEditor -Value 'Administrator'
        New-ItemProperty -Path $regRoot -Name StartTime -Value '08:00:00'
        New-ItemProperty -Path $regRoot -Name EndTime -Value '22:25:00'
        New-ItemProperty -Path $regRoot -Name DaysActive -Value 'Friday'
        $now = Get-Date
        $activeNow = if ($now.DayOfWeek -eq 'Friday' -and (Get-Date '08:00:00') -lt $now -and (Get-Date '22:25:00') -gt $now) {
            $true
        } else { 
            $false 
        }

        $return = Get-LCMManSchedule -RootRegPath 'TestRegistry:\LCMMan'

        Context 'Return values' {

            It 'Returns a single object' {
                ($return | Measure-Object).Count | Should -Be 1
            }

            It 'Returns correct LastEditor value' {
                $return.LastEditor | Should -Be 'Administrator'
            }

            It 'Returns correct StartTime value' {
                $return.StartTime | Should -Be '08:00:00'
            }

            It 'Returns correct EndTime value' {
                $return.EndTime | Should -Be '22:25:00'
            }

            It 'Returns correct DaysActive value' {
                $return.DaysActive | Should -Be 'Friday'
            }

            It 'Returns correct ActiveNow value' {
                $return.ActiveNow | Should -Be $activeNow
            }
        }
    }
}