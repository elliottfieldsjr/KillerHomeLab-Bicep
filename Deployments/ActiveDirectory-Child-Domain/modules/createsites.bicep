@description('Computer Name')
param computerName string

@description('Domain Naming Convention')
param NamingConvention string

@description('Base Domain Distiguished Name')
param BaseDN string

@description('AD Site 1 Subnet')
param Site1Prefix string

@description('AD Site 2 Subnet')
param Site2Prefix string

@description('Region of Resources')
param location string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var ModulesURL = uri(artifactsLocation, 'DSC/CREATESITES.zip${artifactsLocationSasToken}')
var ConfigurationFunction = 'CREATESITES.ps1\\CREATESITES'

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
        NamingConvention: NamingConvention
        BaseDN: BaseDN
        Site1Prefix: Site1Prefix
        Site2Prefix: Site2Prefix
      }
    }
  }
}
