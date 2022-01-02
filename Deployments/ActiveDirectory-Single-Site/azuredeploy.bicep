@description('Time Zone')
param TimeZone1 string

@description('Enable Auto Shutdown')
param AutoShutdownEnabled string

@description('Auto Shutdown Time')
param AutoShutdownTime string

@description('Auto Shutdown Email')
param AutoShutdownEmail string

@description('The name of the Administrator of the new VM and Domain')
param adminUsername string

@description('The password for the Administrator account of the new VM and Domain')
@secure()
param adminPassword string

@description('Windows Server OS License Type')
param WindowsServerLicenseType string

@description('Environment Naming Convention')
param NamingConvention string

@description('Virtual Network 1 Prefix')
param VNet1ID string

@description('Domain Controller1 OS Version')
param DC1OSVersion string

@description('Domain Controller1 VMSize')
param DC1VMSize string

@description('Location 1 for Resources')
param Location1 string

var dc1lastoctet = '101'
var VNet1Name = '${NamingConvention}-VNet1'
var VNet1Prefix = '${VNet1ID}.0.0/16'
var VNet1subnet1Name = '${NamingConvention}-VNet1-Subnet1'
var VNet1subnet1Prefix = '${VNet1ID}.1.0/24'
var VNet1subnet2Name = '${NamingConvention}-VNet1-Subnet2'
var VNet1subnet2Prefix = '${VNet1ID}.2.0/24'
var VNet1BastionsubnetPrefix = '${VNet1ID}.253.0/24'
var dc1Name = '${NamingConvention}-dc-01'
var dc1IP = '${VNet1ID}.1.${dc1lastoctet}'
var DCDataDisk1Name = 'NTDS'

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

module deployDC1VM 'linkedtemplates/1nic-2disk-vm.bicep' = {
  name: 'deployDC1VM'
  params: {
    computerName: dc1Name
    Nic1IP: dc1IP
    Publisher: 'MicrosoftWindowsServer'
    Offer: 'WindowsServer'
    OSVersion: DC1OSVersion
    licenseType: WindowsServerLicenseType
    DataDisk1Name: DCDataDisk1Name
    VMSize: DC1VMSize
    vnetName: VNet1Name
    subnetName: VNet1subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    TimeZone: TimeZone
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail
    location: Location1
  }
  dependsOn: [
    VNet1
  ]
}

module promotedc1 'linkedtemplates/firstdc.bicep' = {
  name: 'promotedc1'
  params: {
    computerName: dc1name
    TimeZone: TimeZone1
    NetBiosDomain: NetBiosDomain
    domainName: InternaldomainName
    adminUsername: adminUsername
    adminPassword: adminPassword
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    deployDC1VM
  ]
}