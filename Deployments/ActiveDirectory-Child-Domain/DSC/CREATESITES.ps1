configuration CREATESITES
{
   param
   (
        [String]$computerName,
        [String]$NamingConvention,
        [String]$BaseDN,
        [String]$Site1Prefix,
        [String]$Site2Prefix
    )

    Import-DscResource -Module ActiveDirectoryDsc

    Node localhost
    {

        ADReplicationSite Site1
        {
            Ensure = 'Present'
            Name   = "$NamingConvention-Site1"
        }

        ADReplicationSite Site2
        {
            Ensure = 'Present'
            Name   = "$NamingConvention-Site2"
        }

        ADReplicationSubnet Site1Subnet1
        {
            Name     = $Site1Prefix
            Site     = "$NamingConvention-Site1"
            DependsOn = "[ADReplicationSite]Site1"
        }

        ADReplicationSubnet Site2Subnet1
        {
            Name     = $Site2Prefix
            Site     = "$NamingConvention-Site2"
            DependsOn = "[ADReplicationSite]Site2"
        }

        ADReplicationSiteLink ChangeDefaultSiteCost
        {
            Name                          = "DEFAULTIPSITELINK"
            SitesIncluded                 = @("$NamingConvention-Site1", "$NamingConvention-Site2", "Default-First-Site-Name")
            Cost                          = 1000
            DependsOn = "[ADReplicationSubnet]Site2Subnet1"
        }

        ADReplicationSiteLink Site1andSite2
        {
            Name                          = "Site1-and-Site2"
            SitesIncluded                 = @("$NamingConvention-Site1", "$NamingConvention-Site2")
            Cost                          = 100
            ReplicationFrequencyInMinutes = 15
            Ensure                        = 'Present'
            DependsOn = "[ADReplicationSiteLink]ChangeDefaultSiteCost"
        }

        Script UpdateDNSSettings
        {
            SetScript =
            {

                # Move First Domain Controller
                $Site1DN = "CN=$using:NamingConvention-Site1,CN=Sites,CN=Configuration,$using:BaseDN"
                Move-ADDirectoryServer -Identity $using:computerName -Site $Site1DN

            }
            GetScript =  { @{} }
            TestScript = { $false}
            DependsOn = '[ADReplicationSiteLink]Site1andSite2'
        }

    }
}