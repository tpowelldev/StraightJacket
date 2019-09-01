$here = $PSScriptRoot
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'

$modulePath = "$here\..\..\.."
$moduleName = Split-Path -Path $modulePath -Leaf

InModuleScope $moduleName {
    Describe Install-LCMMan {
        
        New-Item -Path TestRegistry:\ -Name 'LCMMan' -Force

        Mock Register-ScheduledTask { $null }

        Install-LCMMan -RootRegPath 'TestRegistry:\LCMMan'

        Context 'Registry values' {

            It 'Creates Schedules key' {
                Test-Path 'TestRegistry:\LCMMan\Schedules' | Should Be True
            }

            It 'Creates OverrideOn property' {
                (Get-ItemProperty -Path 'TestRegistry:\LCMMan').OverrideOn | Should Be 0
            }
        }

        Context 'Scheduled task' {
            
        }
    }
}