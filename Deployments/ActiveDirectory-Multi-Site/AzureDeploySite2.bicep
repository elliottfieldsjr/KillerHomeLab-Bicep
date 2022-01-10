// set the target scope for this file
targetScope = 'subscription'

@description('Resource Group 1 Name')
param ResourceGroup1Name string

@description('Resource Group 2 Name')
param ResourceGroup2Name string

@description('Time Zone 2')
param TimeZone2 string

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

@description('Virtual Network 2 Prefix')
param VNet1ID string

@description('Virtual Network 2 Prefix')
param VNet2ID string

@description('Domain Controller2 OS Version')
param DC2OSVersion string

@description('Workstation2 OS Version')
param WK2OSVersion string

@description('Domain Controller1 VMSize')
param DC2VMSize string

@description('Workstation2 VMSize')
param WK2VMSize string

@description('Location 1 for Resources')
param Location1 string

@description('Location 2 for Resources')
param Location2 string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var dc1lastoctet = '101'
var dc2lastoctet = '101'
var wk2lastoctet = '100'
var VNet2Name = '${NamingConvention}-VNet2'
var VNet2Prefix = '${VNet2ID}.0.0/16'
var VNet2subnet1Name = '${NamingConvention}-VNet2-Subnet1'
var VNet2subnet1Prefix = '${VNet2ID}.1.0/24'
var VNet2subnet2Name = '${NamingConvention}-VNet2-Subnet2'
var VNet2subnet2Prefix = '${VNet2ID}.2.0/24'
var VNet2BastionsubnetPrefix = '${VNet2ID}.253.0/24'
var dc2Name = '${NamingConvention}-dc-02'
var dc1IP = '${VNet1ID}.1.${dc1lastoctet}'
var dc2IP = '${VNet2ID}.1.${dc2lastoctet}'
var wk1Name = '${NamingConvention}-wk-01'
var wk2Name = '${NamingConvention}-wk-02'
var wk2IP = '${VNet2ID}.2.${wk2lastoctet}'
var DCDataDisk1Name = 'NTDS'
var InternalDomainName = '${SubDNSDomain}${InternalDomain}.${InternalTLD}'
var BaseDN = '${SubDNSBaseDN}DC=${InternalDomain},DC=${InternalTLD}'
var WIN11OUPath = 'OU=Windows 11,OU=Workstations,${BaseDN}'
var WIN10OUPath = 'OU=Windows 10,OU=Workstations,${BaseDN}'
var WIN7OUPath = 'OU=Windows 7,OU=Workstations,${BaseDN}'

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroup1Name
  location: Location1
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroup2Name
  location: Location2
}

module deployDC2VM 'modules/1nic-2disk-vm.bicep' = {
  name: 'deployDC2VM'
  scope: RG2    
  params: {
    computerName: dc2Name
    Nic1IP: dc2IP
    TimeZone: TimeZone2
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsServer'
    Offer: 'WindowsServer'
    OSVersion: DC2OSVersion
    licenseType: WindowsServerLicenseType
    DataDisk1Name: DCDataDisk1Name
    VMSize: DC2VMSize
    vnetName: VNet2Name
    subnetName: VNet2subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
}

module promotedc2 'modules/otherdc.bicep' = {
  name: 'promotedc2'
  scope: RG2      
  params: {
    computerName: dc2Name
    TimeZone: TimeZone2
    NetBiosDomain: NetBiosDomain
    domainName: InternalDomainName
    DnsServerIP: dc1IP
    adminUsername: adminUsername
    adminPassword: adminPassword
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location2
  }
  dependsOn: [
    deployDC2VM
  ]
}

module UpdateVNet2DNS_2 'modules/updatevnetdns.bicep' = {
  name: 'UpdateVNet2DNS-2'
  scope: RG2        
  params: {
    vnetName: VNet2Name
    vnetprefix: VNet2Prefix
    subnet1Name: VNet2subnet1Name
    subnet1Prefix: VNet2subnet1Prefix
    subnet2Name: VNet2subnet2Name
    subnet2Prefix: VNet2subnet2Prefix
    BastionsubnetPrefix: VNet2BastionsubnetPrefix
    DNSServerIP: [
      dc2IP
    ]
    location: Location2
  }
  dependsOn: [
    promotedc2
  ]
}

module restartdc2 'modules/restartvm.bicep' = {
  name: 'restartdc2'
  scope: RG2          
  params: {
    computerName: dc2Name
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location2
  }
  dependsOn: [
    UpdateVNet2DNS_2
  ]
}

module deployWK2VM_11 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-11') {
  name: 'deployWK2VM_11'
  scope: RG2              
  params: {
    computerName: wk2Name
    Nic1IP: wk2IP
    TimeZone: TimeZone2
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-11'
    OSVersion: 'win11-21h2-pro'
    licenseType: WindowsClientLicenseType
    VMSize: WK2VMSize
    vnetName: VNet2Name
    subnetName: VNet2subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    restartdc2
  ]
}

module deployWK2VM_10 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-10') {
  name: 'deployWK2VM_10'
  scope: RG2              
  params: {
    computerName: wk2Name
    Nic1IP: wk2IP
    TimeZone: TimeZone2
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-10'
    OSVersion: '21h1-pro'
    licenseType: WindowsClientLicenseType
    VMSize: WK2VMSize
    vnetName: VNet2Name
    subnetName: VNet2subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    restartdc2
  ]
}

module deployWK2VM_7 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-7') {
  name: 'deployWK2VM_7'
  scope: RG2              
  params: {
    computerName: wk1Name
    Nic1IP: wk2IP
    TimeZone: TimeZone2
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsDesktop'
    Offer: 'Windows-7'
    OSVersion: 'win7-enterprise'
    licenseType: WindowsClientLicenseType
    VMSize: WK2VMSize
    vnetName: VNet2Name
    subnetName: VNet2subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    restartdc2
  ]
}

module DomainJoinWK2VM_11 'modules/domainjoin.bicep' = if (WK2OSVersion == 'Windows-11') {
  name: 'DomainJoinWK2VM_11'
  scope: RG2              
  params: {
    computerName: wk2Name
    domainName: InternalDomainName    
    OUPath: WIN11OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    deployWK2VM_11
  ]
}

module DomainJoinWK2VM_10 'modules/domainjoin.bicep' = if (WK2OSVersion == 'Windows-10') {
  name: 'DomainJoinWK2VM_10'
  scope: RG2              
  params: {
    computerName: wk2Name
    domainName: InternalDomainName    
    OUPath: WIN10OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    deployWK2VM_10
  ]
}

module DomainJoinWK2VM_7 'modules/domainjoin.bicep' = if (WK2OSVersion == 'Windows-7') {
  name: 'DomainJoinWK2VM_7'
  scope: RG2
  params: {
    computerName: wk2Name
    domainName: InternalDomainName    
    OUPath: WIN7OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    deployWK2VM_7
  ]
}
