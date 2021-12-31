param vnetName
param vnetprefix
param subnet1Name
param subnet1Prefix
param subnet2Name
param subnet2Prefix
param BastionsubnetPrefix
param location


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
