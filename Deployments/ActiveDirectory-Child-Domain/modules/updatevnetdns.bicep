@description('VNet name')
param vnetName string

@description('VNet prefix')
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

@description('The DNS address(es) of the DNS Server(s) used by the VNET')
param DNSServerIP array

@description('Region of Resources')
param location string

resource vnetName_resource 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetprefix
      ]
    }
    dhcpOptions: {
      dnsServers: DNSServerIP
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
        name: 'AzureBastionSubnet'
        properties: {
          addressPrefix: BastionsubnetPrefix
        }
      }      
    ]
  }
}

output vnetName string = vnetName
