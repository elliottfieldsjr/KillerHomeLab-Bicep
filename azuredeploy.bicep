@description('Environment Naming Convention')
param NamingConvention string = 'khl'

@description('DMZ VNet1 Prefix')
param VNet1ID string = '10.1'

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('Auto-generated token to access _artifactsLocation. Leave it blank unless you need to provide your own value.')
@secure()
param artifactsLocationSasToken string = ''

var VNet1Name = '${NamingConvention}-VNet1'
var VNet1Prefix = '${VNet1ID}.0.0/16'
var VNet1subnet1Name = '${NamingConvention}-VNet1-Subnet1'
var VNet1subnet1Prefix = '${VNet1ID}.1.0/24'
var VNet1subnet2Name = '${NamingConvention}-VNet1-Subnet2'
var VNet1subnet2Prefix = '${VNet1ID}.2.0/24'
var VNet1BastionsubnetPrefix = '${VNet1ID}.253.0/24'

module VNet1 'linkedtemplates/vnet.bicep' = {
  name: 'VNet1'
  params: {
    vnetName: VNet1Name
    vnetprefix: VNet1Prefix
    subnet1Name: VNet1subnet1Name
    subnet1Prefix: VNet1subnet1Prefix
    BastionsubnetPrefix: VNet1BastionsubnetPrefix
    location: resourceGroup().location
  }
}