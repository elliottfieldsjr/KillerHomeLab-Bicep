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

@description('Windows Client OS License Type')
param WindowsClientLicenseType string

@description('Environment Naming Convention')
param NamingConvention string

@description('Sub DNS Domain Name Example:  sub1. must include a DOT AT END')
param SubDNSDomain string

@description('Sub DNS Domain Name Example:  DC=sub2,DC=sub1, must include COMMA AT END')
param SubDNSBaseDN string

@description('NetBios Parent Domain Name')
param NetBiosDomain string

@description('NetBios Parent Domain Name')
param InternalDomain string

@description('Internal Top-Level Domain Name')
param InternalTLD string

@description('Virtual Network 1 Prefix')
param VNet1ID string

@description('Domain Controller1 OS Version')
param DC1OSVersion string

@description('Workstation1 OS Version')
param WK1OSVersion string

@description('Domain Controller1 VMSize')
param DC1VMSize string

@description('Workstation1 VMSize')
param WK1VMSize string

@description('DNS Reverse Lookup Zone1 Prefix')
param ReverseLookup1 string

@description('Location 1 for Resources')
param Location1 string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var dc1lastoctet = '101'
var wk1lastoctet = '100'
var VNet1Name = '${NamingConvention}-VNet1'
var VNet1Prefix = '${VNet1ID}.0.0/16'
var VNet1subnet1Name = '${NamingConvention}-VNet1-Subnet1'
var VNet1subnet1Prefix = '${VNet1ID}.1.0/24'
var VNet1subnet2Name = '${NamingConvention}-VNet1-Subnet2'
var VNet1subnet2Prefix = '${VNet1ID}.2.0/24'
var VNet1BastionsubnetPrefix = '${VNet1ID}.253.0/24'
var dc1Name = '${NamingConvention}-dc-01'
var dc1IP = '${VNet1ID}.1.${dc1lastoctet}'
var wk1Name = '${NamingConvention}-wk-01'
var wk1IP = '${VNet1ID}.2.${wk1lastoctet}'
var DCDataDisk1Name = 'NTDS'
var InternalDomainName = '${SubDNSDomain}${InternalDomain}.${InternalTLD}'
var ReverseZone1 = '1.${ReverseLookup1}'
var BaseDN = '${SubDNSBaseDN}DC=${InternalDomain},DC=${InternalTLD}'
var WIN11OUPath = 'OU=Windows 11,OU=Workstations,${BaseDN}'
var WIN10OUPath = 'OU=Windows 10,OU=Workstations,${BaseDN}'
var WIN7OUPath = 'OU=Windows 7,OU=Workstations,${BaseDN}'

module VNet1 'modules/vnet.bicep' = {
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

module BastionHost1 'modules/bastionhost.bicep' = {
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

module deployDC1VM 'modules/1nic-2disk-vm.bicep' = {
  name: 'deployDC1VM'
  params: {
    computerName: dc1Name
    Nic1IP: dc1IP
    TimeZone: TimeZone1
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
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
    location: Location1
  }
  dependsOn: [
    VNet1
  ]
}

module promotedc1 'modules/firstdc.bicep' = {
  name: 'PromoteDC1'
  params: {
    computerName: dc1Name
    TimeZone: TimeZone1
    NetBiosDomain: NetBiosDomain
    domainName: InternalDomainName
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1          
    artifactsLocation:  artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
  }
  dependsOn: [
    deployDC1VM
  ]
}

module UpdateVNet1DNS_1 'modules/updatevnetdns.bicep' = {
  name: 'UpdateVNet1DNS-1'
  params: {
    vnetName: VNet1Name
    vnetprefix: VNet1Prefix
    subnet1Name: VNet1subnet1Name
    subnet1Prefix: VNet1subnet1Prefix
    subnet2Name: VNet1subnet2Name
    subnet2Prefix: VNet1subnet2Prefix
    BastionsubnetPrefix: VNet1BastionsubnetPrefix
    DNSServerIP: [
      dc1IP
    ]
    location: Location1
  }
  dependsOn: [
    promotedc1
  ]
}

module restartdc1 'modules/restartvm.bicep' = {
  name: 'restartdc1'
  params: {
    computerName: dc1Name
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    UpdateVNet1DNS_1
  ]
}

module configdns 'modules/configdnsint.bicep' = {
  name: 'configdns'
  params: {
    computerName: dc1Name
    NetBiosDomain: NetBiosDomain
    InternalDomainName: InternalDomainName
    ReverseLookup1: ReverseZone1
    dc1lastoctet: dc1lastoctet
    adminUsername: adminUsername
    adminPassword: adminPassword
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    restartdc1
  ]
}

module createous 'modules/createous.bicep' = {
  name: 'createous'
  params: {
    computerName: dc1Name
    BaseDN: BaseDN
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    configdns
  ]
}

module deployWK1VM_11 'modules/1nic-1disk-vm.bicep' = if (WK1OSVersion == 'Windows-11') {
  name: 'deployWK1VM_11'
  params: {
    computerName: wk1Name
    Nic1IP: wk1IP
    TimeZone: TimeZone1
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-11'
    OSVersion: 'win11-21h2-pro'
    licenseType: WindowsClientLicenseType
    VMSize: WK1VMSize
    vnetName: VNet1Name
    subnetName: VNet1subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    restartdc1
  ]
}

module deployWK1VM_10 'modules/1nic-1disk-vm.bicep' = if (WK1OSVersion == 'Windows-10') {
  name: 'deployWK1VM_10'
  params: {
    computerName: wk1Name
    Nic1IP: wk1IP
    TimeZone: TimeZone1
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-10'
    OSVersion: '21h1-pro'
    licenseType: WindowsClientLicenseType
    VMSize: WK1VMSize
    vnetName: VNet1Name
    subnetName: VNet1subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    restartdc1
  ]
}

module deployWK1VM_7 'modules/1nic-1disk-vm.bicep' = if (WK1OSVersion == 'Windows-7') {
  name: 'deployWK1VM_7'
  params: {
    computerName: wk1Name
    Nic1IP: wk1IP
    TimeZone: TimeZone1
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-7'
    OSVersion: 'win7-enterprise'
    licenseType: WindowsClientLicenseType
    VMSize: WK1VMSize
    vnetName: VNet1Name
    subnetName: VNet1subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    restartdc1
  ]
}

module DomainJoinWK1VM_11 'modules/domainjoin.bicep' = if (WK1OSVersion == 'Windows-11') {
  name: 'DomainJoinWK1VM_11'
  params: {
    computerName: wk1Name
    domainName: InternalDomainName    
    OUPath: WIN11OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    deployWK1VM_11
  ]
}

module DomainJoinWK1VM_10 'modules/domainjoin.bicep' = if (WK1OSVersion == 'Windows-10') {
  name: 'DomainJoinWK1VM_10'
  params: {
    computerName: wk1Name
    domainName: InternalDomainName    
    OUPath: WIN10OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    deployWK1VM_10
  ]
}

module DomainJoinWK1VM_7 'modules/domainjoin.bicep' = if (WK1OSVersion == 'Windows-7') {
  name: 'DomainJoinWK1VM_7'
  params: {
    computerName: wk1Name
    domainName: InternalDomainName    
    OUPath: WIN7OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    deployWK1VM_7
  ]
}
