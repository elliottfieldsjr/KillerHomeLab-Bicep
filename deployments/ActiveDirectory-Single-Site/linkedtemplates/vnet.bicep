@description('Virtual Network Name')
param vnetName string

@description('Virtual Network Prefix')
param vnetprefix string

@description('Subnet 1 Name')
param subnet1Name string

@description('Subnet 1 Prefix')
param subnet1Prefix string

@description('Subnet 2 Name')
param subnet2Name string

@description('Subnet 2 Prefix')
param subnet2Prefix string

@description('Bastion Subnet Prefix')
param BastionsubnetPrefix string

@description('Resource Location')
param location string

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2020-04-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetprefix
      ]
    }
    subnets: [
      {
        name: subnet1Name
        properties: {
          addressPrefix: subnet1Prefix
        }
      }
      {
        name: subnet2Name
        properties: {
          addressPrefix: subnet2Prefix
        }
      }
      {
        name: AzureBastionSubnet
        properties: {
          addressPrefix: param BastionsubnetPrefix
        }
      }
    ]
  }
}

output vnetName string = vnetName
