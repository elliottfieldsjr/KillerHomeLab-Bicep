@description('Computer Name')
param computerName string

@description('Time Zone')
param TimeZone string

@description('Child NetBios Domain Name')
param ChildNetBiosDomain string

@description('Child Domain Name')
param ChildDomainName string

@description('The FQDN of the AD Domain created ')
param domainName string

@description('DNS Server IP ')
param DnsServerIP string

@description('Region of Resources')
param location string

@description('The name of the Administrator of the new VM and Domain')
param adminUsername string

@description('The password for the Administrator account of the new VM and Domain')
@secure()
param adminPassword string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var ModulesURL = uri(artifactsLocation, 'DSC/CHILDDC.zip${artifactsLocationSasToken}')
var ConfigurationFunction = 'CHILDDC.ps1\\CHILDDC'

resource computerName_Microsoft_Powershell_DSC 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${computerName}/Microsoft.Powershell.DSC'
  location: location
  properties: {
    publisher: 'Microsoft.Powershell'
    type: 'DSC'
    typeHandlerVersion: '2.19'
    autoUpgradeMinorVersion: true
    settings: {
      ModulesUrl: ModulesURL
      ConfigurationFunction: ConfigurationFunction
      Properties: {
        TimeZone: TimeZone
        DomainName: domainName
        ChildNetBiosDomain: ChildNetBiosDomain
        ChildDomainName: ChildDomainName
        DnsServerIP: DnsServerIP
        AdminCreds: {
          UserName: adminUsername
          Password: 'PrivateSettingsRef:AdminPassword'
        }
      }
    }
    protectedSettings: {
      Items: {
        AdminPassword: adminPassword
      }
    }
  }
}
