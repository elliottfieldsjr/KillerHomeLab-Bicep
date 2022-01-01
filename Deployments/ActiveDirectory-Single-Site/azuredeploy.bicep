
@description('Environment Naming Convention')
param NamingConvention string

@description('Virtual Network 1 Prefix')
param VNet1ID string

@description('Location 1 for Resources')
param Location1 string

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
    subnet2Name: VNet1subnet2Name
    subnet2Prefix: VNet1subnet2Prefix    
    BastionsubnetPrefix: VNet1BastionsubnetPrefix
    location: Location1
  }
}

module BastionHost1 'linkedtemplates/bastionhost.bicep' = {
  name: 'BastionHost1'
  params: {
    publicIPAddressName: '${VNet1Name}-Bastion-pip'
    AllocationMethod: 'Static'
    vnetName: VNet1Name
    subnetName: 'AzureBastionSubnet'
    location: Location1
  }
  dependsOn: [
    VNet1
  ]
}