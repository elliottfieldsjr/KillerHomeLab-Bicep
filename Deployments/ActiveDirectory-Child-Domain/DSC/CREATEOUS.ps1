configuration CREATEOUs
{
   param
   (
        [String]$BaseDN
    )

    Import-DscResource -Module ActiveDirectoryDsc

    Node localhost
    {

       ADOrganizationalUnit AccountsOU
        {
            Name                            = "Accounts"
            Path                            = "$BaseDN"
            Description                     = "Accounts OU"
            Ensure                          = 'Present'
        }

       ADOrganizationalUnit GroupsOU
        {
            Name                            = "Groups"
            Path                            = "$BaseDN"
            Description                     = "Groups OU"
            Ensure                          = 'Present'
        }

       ADOrganizationalUnit AdminOU
        {
            Name                            = "Admin"
            Path                            = "OU=Accounts,$BaseDN"
            Description                     = "Admin OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]AccountsOU"
        }

        ADOrganizationalUnit AdminGroupsOU
        {
            Name                            = "Admin"
            Path                            = "OU=Groups,$BaseDN"
            Description                     = "Admin Groups OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]GroupsOU"
        }

        ADOrganizationalUnit EndUserOU
        {
            Name                            = "End User"
            Path                            = "OU=Accounts,$BaseDN"
            Description                     = "End User OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]AccountsOU"
        }

        ADOrganizationalUnit EndUserGroupOU
        {
            Name                            = "End User"
            Path                            = "OU=Groups,$BaseDN"
            Description                     = "End User Groups OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]GroupsOU"
        }

        ADOrganizationalUnit Office365OU
        {
            Name                            = "Office 365"
            Path                            = "OU=End User,OU=Accounts,$BaseDN"
            Description                     = "Office 365 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]EndUserOU"
        }

        ADOrganizationalUnit Office365GroupOU
        {
            Name                            = "Office 365"
            Path                            = "OU=End User,OU=Groups,$BaseDN"
            Description                     = "Office 365 Groups OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]EndUserGroupOU"
        }

        ADOrganizationalUnit Sub1OU
        {
            Name                            = "Sub1"
            Path                            = "OU=Office 365,OU=End User,OU=Accounts,$BaseDN"
            Description                     = "Sub1 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]Office365OU"
        }

        ADOrganizationalUnit NonOffice365OU
        {
            Name                            = "Non-Office 365"
            Path                            = "OU=End User,OU=Accounts,$BaseDN"
            Description                     = "Non-Office 365 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]EndUserOU"
        }

        ADOrganizationalUnit ServiceOU
        {
            Name                            = "Service"
            Path                            = "OU=Accounts,$BaseDN"
            Description                     = "Service OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]AccountsOU"
        }

        ADOrganizationalUnit ServersOU
        {
            Name                            = "Servers"
            Path                            = "$BaseDN"
            Description                     = "Servers OU"
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit Server2012R2OU
        {
            Name                            = "Servers2012R2"
            Path                            = "OU=Servers,$BaseDN"
            Description                     = "Server2012R2 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]ServersOU"
        }

        ADOrganizationalUnit Server2016OU
        {
            Name                            = "Servers2016"
            Path                            = "OU=Servers,$BaseDN"
            Description                     = "Server2016 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]ServersOU"
        }

        ADOrganizationalUnit Server2019OU
        {
            Name                            = "Servers2019"
            Path                            = "OU=Servers,$BaseDN"
            Description                     = "Server2019 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]ServersOU"
        }

        ADOrganizationalUnit Server2022OU
        {
            Name                            = "Servers2022"
            Path                            = "OU=Servers,$BaseDN"
            Description                     = "Server2022 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]ServersOU"
        }
      
        ADOrganizationalUnit MaintenanceServersOU
        {
            Name                            = "Maintenance Servers"
            Path                            = "$BaseDN"
            Description                     = "Maintenance Servers OU"
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit MaintenanceWorkstationsOU
        {
            Name                            = "Maintenance Workstations"
            Path                            = "$BaseDN"
            Description                     = "Maintenance Workstations OU"
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit WorkstationsOU
        {
            Name                            = "Workstations"
            Path                            = "$BaseDN"
            Description                     = "Workstations OU"
            Ensure                          = 'Present'
        }

        ADOrganizationalUnit Windows11OU
        {
            Name                            = "Windows 11"
            Path                            = "OU=Workstations,$BaseDN"
            Description                     = "Windows 11 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]WorkstationsOU"
        }

        ADOrganizationalUnit Windows10OU
        {
            Name                            = "Windows 10"
            Path                            = "OU=Workstations,$BaseDN"
            Description                     = "Windows 10 OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]WorkstationsOU"
        }

        ADOrganizationalUnit Windows7OU
        {
            Name                            = "Windows 7"
            Path                            = "OU=Workstations,$BaseDN"
            Description                     = "Workstations OU"
            Ensure                          = 'Present'
            DependsOn = "[ADOrganizationalUnit]WorkstationsOU"
        }

    }
}