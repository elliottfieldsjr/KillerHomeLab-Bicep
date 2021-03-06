@description('Computer Name')
param computerName string

@description('NetBios Domain Name')
param NetBiosDomain string

@description('The FQDN of the AD Domain created ')
param InternalDomainName string

@description('The name of Reverse Lookup Zone 1 Network ID')
param ReverseLookup1 string

@description('The name of Forward Lookup Zone 1 Network ID')
param ForwardLookup1 string

@description('DC1 Last IP Octet')
param dc1lastoctet string

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

var ModulesURL = uri(artifactsLocation, 'DSC/CONFIGDNSINT.zip${artifactsLocationSasToken}')
var ConfigurationFunction = 'CONFIGDNSINT.ps1\\CONFIGDNSINT'

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
        computerName: computerName
        NetBiosDomain: NetBiosDomain
        InternalDomainName: InternalDomainName
        ReverseLookup1: ReverseLookup1
        ForwardLookup1: ForwardLookup1        
        dc1lastoctet: dc1lastoctet
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
