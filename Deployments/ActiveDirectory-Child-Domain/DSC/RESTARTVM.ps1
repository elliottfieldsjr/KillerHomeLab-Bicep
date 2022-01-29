configuration RESTARTVM
{
   param
   (
    )

    Import-DscResource -Module xPendingReboot # Used for Reboots

    Node localhost
    {
        LocalConfigurationManager 
        {
           RebootNodeIfNeeded = $true
        }

        xPendingReboot Reboot
        {
           Name = "Reboot"
        }

        Script Reboot
        {
            TestScript = {
            return (Test-Path HKLM:\SOFTWARE\MyMainKey\RebootKey)
            }
            SetScript = {
			        New-Item -Path HKLM:\SOFTWARE\MyMainKey\RebootKey -Force
			        $global:DSCMachineStatus = 1 
                }
            GetScript = { return @{result = 'result'}}
        }
    }
}