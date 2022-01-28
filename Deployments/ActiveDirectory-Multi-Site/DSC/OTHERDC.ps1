configuration OTHERDC
{
   param
    (
        [String]$TimeZone,
        [String]$DomainName,
        [String]$DNSServerIP,
        [String]$NetBiosDomain,
        [System.Management.Automation.PSCredential]$Admincreds,
        [Int]$RetryCount=20,
        [Int]$RetryIntervalSec=30
    )

    Import-DscResource -ModuleName xStorage
    Import-DscResource -ModuleName xNetworking
    Import-DscResource -ModuleName xPSDesiredStateConfiguration
    Import-DscResource -ModuleName ComputerManagementDsc
    Import-DscResource -ModuleName ActiveDirectoryDsc
    Import-DscResource -ModuleName xPendingReboot
    Import-DscResource -ModuleName DNSServerDsc

    [System.Management.Automation.PSCredential ]$DomainCredsFQDN = New-Object System.Management.Automation.PSCredential ("$($Admincreds.UserName)@$($DomainName)", $Admincreds.Password)

    $Interface=Get-NetAdapter|Where Name -Like "Ethernet*"|Select-Object -First 1
    $InterfaceAlias=$($Interface.Name)

    Node localhost
    {
        Script EnableTls12
        {
            SetScript =
            {
                [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

            }
            GetScript =  { @{} }
            TestScript = { $false}
        }

        LocalConfigurationManager
        {
            RebootNodeIfNeeded = $true
        }

        xWaitforDisk Disk2
        {
                DiskId = 2
                RetryIntervalSec =$RetryIntervalSec
                RetryCount = $RetryCount
        }

        xDisk ADDataDisk
        {
            DiskId = 2
            DriveLetter = "N"
            DependsOn = "[xWaitForDisk]Disk2"
        }

        WindowsFeature ADDSInstall
        {
            Ensure = "Present"
            Name = "AD-Domain-Services"
        }

        WindowsFeature ADDSTools
        {
            Ensure = "Present"
            Name = "RSAT-ADDS-Tools"
            DependsOn = "[WindowsFeature]ADDSInstall"
        }

        WindowsFeature ADAdminCenter
        {
            Ensure = "Present"
            Name = "RSAT-AD-AdminCenter"
            DependsOn = "[WindowsFeature]ADDSTools"
        }

        WaitForADDomain DscForestWait
        {
            DomainName = $DomainName
            Credential= $DomainCredsFQDN
            RestartCount = $RetryCount
            WaitTimeout = $RetryIntervalSec
            DependsOn = '[WindowsFeature]ADAdminCenter'
        }

        ADDomainController BDC
        {
            DomainName = $DomainName
            Credential = $DomainCredsFQDN
            SafemodeAdministratorPassword = $DomainCredsFQDN
            DatabasePath = "N:\NTDS"
            LogPath = "N:\NTDS"
            SysvolPath = "N:\SYSVOL"
            DependsOn = "[WaitForADDomain]DscForestWait"
        }

        TimeZone SetTimeZone
        {
            IsSingleInstance = 'Yes'
            TimeZone         = $TimeZone
        }

        Script UpdateDNSSettings
        {
            SetScript =
            {
                # Reset DNS
                Set-DnsClientServerAddress -InterfaceAlias "$using:InterfaceAlias" -ResetServerAddresses
            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[ADDomainController]BDC'
        }

        xPendingReboot RebootAfterPromotion {
            Name = "RebootAfterDCPromotion"
            DependsOn = "[Script]UpdateDNSSettings"
        }               
    }
}