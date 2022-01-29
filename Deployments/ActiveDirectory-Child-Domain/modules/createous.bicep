@description('Computer Name')
param computerName string

@description('Base Domain Distiguished Name')
param BaseDN string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

@description('Region of Resources')
param location string

var ModulesURL = uri(artifactsLocation, 'DSC/CREATEOUS.zip${artifactsLocationSasToken}')
var ConfigurationFunction = 'CREATEOUS.ps1\\CREATEOUS'

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
        BaseDN: BaseDN
      }
    }
  }
}
