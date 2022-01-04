[![ActiveDirectory-Multi-Site](https://github.com/elliottfieldsjr/KillerHomeLab-Bicep/actions/workflows/ActiveDirectory-Multi-Site.yml/badge.svg)](https://github.com/elliottfieldsjr/KillerHomeLab-Bicep/actions/workflows/ActiveDirectory-Multi-Site.yml)

# Active Directory Single-Site
<img src="../x_Images/ActiveDirectoryMultiSite.png" alt="Active Directory" width="150">

This Templates deploys a Single Forest/Domain:

- 1 - Active Directory Forest/Domain
- 2 - Domain Controllers
- 2 - Domain Joined Windows Workstations (Windows 11/10/7)

The deployment leverages Desired State Configuration scripts to further customize the following:

AD OU Structure:
- [domain.com]
- -- Accounts
- --- End User
- ---- Office 365
- ---- Non-Office 365
- --- Admin
- --- Service
- -- Groups
- --- End User
- --- Admin
- -- Servers
- --- Servers2012R2
- --- Serverrs2016
- --- Servers2019
- --- Servers2022
- -- MaintenanceServers
- -- MaintenanceWorkstations
- -- Workstations
- --- Windows11
- --- Windows10
- --- Windows7

Parameters that support changes
- TimeZone1.  Select an appropriate Time Zone.
- TimeZone2.  Select an appropriate Time Zone.
- AutoShutdownEnabled.  Yes = AutoShutdown Enabled, No = AutoShutdown Disabled.
- AutoShutdownTime.  24-Hour Clock Time for Auto-Shutdown (Example: 1900 = 7PM)
- AutoShutdownEmail.  Auto-Shutdown notification Email (Example:  user@domain.com)
- Admin Username.  Enter a valid Admin Username
- Admin Password.  Enter a valid Admin Password
- WindowsServerLicenseType.  Choose Windows Server License Type (Example:  Windows_Server or None)
- WindowsClientLicenseType.  Choose Windows Client License Type (Example:  Windows_Client or None)
- Naming Convention. Enter a name that will be used as a naming prefix for (Servers, VNets, etc) you are using.
- Sub DNS Domain.  OPTIONALLY, enter a valid DNS Sub Domain. (Example:  sub1. or sub1.sub2.    This entry must end with a DOT )
- Sub DNS BaseDN.  OPTIONALLY, enter a valid DNS Sub Base DN. (Example:  DC=sub1, or DC=sub1,DC=sub2,    This entry must end with a COMMA )
- Net Bios Domain.  Enter a valid Net Bios Domain Name (Example:  killerhomelab).
- Internal Domain.  Enter a valid Internal Domain (Exmaple:  killerhomelab)
- InternalTLD.  Select a valid Top-Level Domain using the Pull-Down Menu.
- Vnet1ID.  Enter first 2 octets of your desired Address Space for Virtual Network 1 (Example:  10.1)
- Vnet2ID.  Enter first 2 octets of your desired Address Space for Virtual Network 2 (Example:  10.2)
- Reverse Lookup1.  Enter first 2 octets of your desired Address Space in Reverse (Example:  1.10)
- Reverse Lookup2.  Enter first 2 octets of your desired Address Space in Reverse (Example:  2.10)
- DC1OSVersion.  Select 2022-Datacenter (Windows 2022), 2019-Datacenter (Windows 2019), 2016-Datacenter (Windows 2016) or 2012-R2-Datacenter (Windows 2012 R2) Domain Controller 1 OS Version
- DC2OSVersion.  Select 2022-Datacenter (Windows 2022), 2019-Datacenter (Windows 2019), 2016-Datacenter (Windows 2016) or 2012-R2-Datacenter (Windows 2012 R2) Domain Controller 1 OS Version
- WK1OSVersion.  Select Windows-11, Windows-10 or Windows-7 Worksation 1 OS Version
- WK2OSVersion.  Select Windows-11, Windows-10 or Windows-7 Worksation 1 OS Version
- DC1VMSize.  Enter a Valid VM Size based on which Region the VM is deployed.
- DC2VMSize.  Enter a Valid VM Size based on which Region the VM is deployed.
- WK1VMSize.  Enter a Valid VM Size based on which Region the VM is deployed.
- WK2VMSize.  Enter a Valid VM Size based on which Region the VM is deployed.