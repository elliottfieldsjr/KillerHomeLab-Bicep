@description('Location 1 for Resources')
param Location1 string

@description('Location 2 for Resources')
param Location2 string

@description('Time Zone 1')
param TimeZone1 string

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

@description('Sub DNS Base DN Example:  DC=sub2,DC=sub1, must include COMMA AT END')
param SubDNSBaseDN string

@description('NetBios Parent Domain Name')
param ParentNetBiosDomain string

@description('NetBios Parent Domain Name')
param ParentDomain string

@description('NetBios Child Domain Name')
param ChildNetBiosDomain string

@description('Top-Level Domain Name')
param TLD string

@description('Virtual Network 1 Prefix')
param VNet1ID string

@description('Virtual Network 2 Prefix')
param VNet2ID string

@description('DNS Reverse Lookup Zone1 Prefix')
param ReverseLookup1 string

@description('DNS Reverse Lookup Zone2 Prefix')
param ReverseLookup2 string

@description('Domain Controller1 OS Version')
param DC1OSVersion string

@description('Domain Controller2 OS Version')
param DC2OSVersion string

@description('Workstation1 OS Version')
param WK1OSVersion string

@description('Workstation2 OS Version')
param WK2OSVersion string

@description('Domain Controller1 VMSize')
param DC1VMSize string

@description('Domain Controller1 VMSize')
param DC2VMSize string

@description('Workstation1 VMSize')
param WK1VMSize string

@description('Workstation2 VMSize')
param WK2VMSize string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var dc1lastoctet = '101'
var dc2lastoctet = '101'
var wk1lastoctet = '100'
var wk2lastoctet = '100'
var VNet1Name = '${NamingConvention}-VNet1'
var VNet1Prefix = '${VNet1ID}.0.0/16'
var VNet1subnet1Name = '${NamingConvention}-VNet1-Subnet1'
var VNet1subnet1Prefix = '${VNet1ID}.1.0/24'
var VNet1subnet2Name = '${NamingConvention}-VNet1-Subnet2'
var VNet1subnet2Prefix = '${VNet1ID}.2.0/24'
var VNet1BastionsubnetPrefix = '${VNet1ID}.253.0/24'
var VNet2Name = '${NamingConvention}-VNet2'
var VNet2Prefix = '${VNet2ID}.0.0/16'
var VNet2subnet1Name = '${NamingConvention}-VNet2-Subnet1'
var VNet2subnet1Prefix = '${VNet2ID}.1.0/24'
var VNet2subnet2Name = '${NamingConvention}-VNet2-Subnet2'
var VNet2subnet2Prefix = '${VNet2ID}.2.0/24'
var VNet2BastionsubnetPrefix = '${VNet2ID}.253.0/24'
var dc1Name = '${NamingConvention}-dc-01'
var dc1IP = '${VNet1ID}.1.${dc1lastoctet}'
var dc2Name = '${NamingConvention}-dc-02'
var dc2IP = '${VNet2ID}.1.${dc2lastoctet}'
var wk1Name = '${NamingConvention}-wk-01'
var wk1IP = '${VNet1ID}.2.${wk1lastoctet}'
var wk2Name = '${NamingConvention}-wk-02'
var wk2IP = '${VNet2ID}.2.${wk2lastoctet}'
var DCDataDisk1Name = 'NTDS'
var ReverseZone1 = '1.${ReverseLookup1}'
var ReverseZone2 = '1.${ReverseLookup2}'
var ForwardZone1 = '${VNet1ID}.1'
var ForwardZone2 = '${VNet2ID}.1'
var ParentDomainName = '${SubDNSDomain}${ParentDomain}.${TLD}'
var ParentBaseDN = '${SubDNSBaseDN}DC=${ParentDomain},DC=${TLD}'
var ParentWIN11OUPath = 'OU=Windows 11,OU=Workstations,${ParentBaseDN}'
var ParentWIN10OUPath = 'OU=Windows 10,OU=Workstations,${ParentBaseDN}'
var ParentWIN7OUPath = 'OU=Windows 7,OU=Workstations,${ParentBaseDN}'
var ChildDomainName = '${ChildNetBiosDomain}.${ParentDomainName}'
var ChildBaseDN = 'DC=${ChildNetBiosDomain},DC=${ParentBaseDN}'
var ChildWIN11OUPath = 'OU=Windows 11,OU=Workstations,${ChildBaseDN}'
var ChildWIN10OUPath = 'OU=Windows 10,OU=Workstations,${ChildBaseDN}'
var ChildWIN7OUPath = 'OU=Windows 7,OU=Workstations,${ChildBaseDN}'

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

module VNet2 'modules/vnet.bicep' = {
  name: 'VNet2'
  params: {
    vnetName: VNet2Name
    vnetprefix: VNet2Prefix
    subnet1Name: VNet2subnet1Name
    subnet1Prefix: VNet2subnet1Prefix
    subnet2Name: VNet2subnet2Name
    subnet2Prefix: VNet2subnet2Prefix    
    BastionsubnetPrefix: VNet2BastionsubnetPrefix
    location: Location2
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
    NetBiosDomain: ParentNetBiosDomain
    domainName: ParentDomainName
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

module UpdateVNet2DNS_1 'modules/updatevnetdns.bicep' = {
  name: 'UpdateVNet2DNS-1'
  params: {
    vnetName: VNet2Name
    vnetprefix: VNet2Prefix
    subnet1Name: VNet2subnet1Name
    subnet1Prefix: VNet2subnet1Prefix
    subnet2Name: VNet2subnet2Name
    subnet2Prefix: VNet2subnet2Prefix
    BastionsubnetPrefix: VNet2BastionsubnetPrefix
    DNSServerIP: [
      dc1IP
    ]
    location: Location2
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
    DC2Name: dc2Name    
    NetBiosDomain: ParentNetBiosDomain
    InternalDomainName: ParentDomainName
    ReverseLookup1: ReverseZone1
    ReverseLookup2: ReverseZone2    
    ForwardLookup1: ForwardZone1    
    ForwardLookup2: ForwardZone2        
    dc1lastoctet: dc1lastoctet
    dc2lastoctet: dc2lastoctet    
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
    BaseDN: ParentBaseDN
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    configdns
  ]
}

module createsites 'modules/createsites.bicep' = {
  name: 'createsites'
  params: {
    computerName: dc1Name
    NamingConvention: NamingConvention
    BaseDN: ParentBaseDN
    Site1Prefix: VNet1Prefix
    Site2Prefix: VNet2Prefix
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location1
  }
  dependsOn: [
    createous
  ]
}

module VNet1ToVNet2Peering 'modules/peering.bicep' = {
  name: 'VNet1ToVNet2Peering'
  params: {
    SourceVNetName: VNet1Name
    TargetVNetName: VNet2Name
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    createsites
  ]
}

module VNet2ToVNet1Peering 'modules/peering.bicep' = {
  name: 'VNet2ToVNet1Peering'
  params: {
    SourceVNetName: VNet2Name
    TargetVNetName: VNet1Name
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    createsites
  ]
}

module deployDC2VM 'modules/1nic-2disk-vm.bicep' = {
  name: 'deployDC2VM'
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
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module promotedc2 'modules/childdc.bicep' = {
  name: 'promotedc2'
  params: {
    computerName: dc2Name
    TimeZone: TimeZone2
    ChildNetBiosDomain: ChildNetBiosDomain
    ChildDomainName:  ChildDomainName
    domainName: ParentDomainName
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

module restartchilddc1 'modules/restartvm.bicep' = {
  name: 'restartchilddc1'
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


module createous2 'modules/createous.bicep' = {
  name: 'createous2'
  params: {
    computerName: dc2Name
    BaseDN: ChildBaseDN
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location2
  }
  dependsOn: [
    restartchilddc1
  ]
}

module createsites2 'modules/createsites.bicep' = {
  name: 'createsites2'
  params: {
    computerName: dc2Name
    NamingConvention: NamingConvention
    BaseDN: ChildBaseDN
    Site1Prefix: VNet1Prefix
    Site2Prefix: VNet2Prefix
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location2
  }
  dependsOn: [
    createous2
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
    subnetName: VNet1subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
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
    subnetName: VNet1subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
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
    subnetName: VNet1subnet2Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module deployWK2VM_11 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-11') {
  name: 'deployWK2VM_11'
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
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module deployWK2VM_10 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-10') {
  name: 'deployWK2VM_10'
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
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module deployWK2VM_7 'modules/1nic-1disk-vm.bicep' = if (WK2OSVersion == 'Windows-7') {
  name: 'deployWK2VM_7'
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
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module DomainJoinWK1VM_11 'modules/domainjoin.bicep' = if (WK1OSVersion == 'Windows-11') {
  name: 'DomainJoinWK1VM_11'
  params: {
    computerName: wk1Name
    domainName: ParentDomainName    
    OUPath: ParentWIN11OUPath
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
    domainName: ParentDomainName    
    OUPath: ParentWIN10OUPath
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
    domainName: ParentDomainName    
    OUPath: ParentWIN7OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    deployWK1VM_7
  ]
}

module DomainJoinWK2VM_11 'modules/domainjoin.bicep' = if (WK2OSVersion == 'Windows-11') {
  name: 'DomainJoinWK2VM_11'
  params: {
    computerName: wk2Name
    domainName: ChildDomainName    
    OUPath: ChildWIN11OUPath
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
  params: {
    computerName: wk2Name
    domainName: ChildDomainName    
    OUPath: ChildWIN10OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    deployWK2VM_10
    createous
  ]
}

module DomainJoinWK2VM_7 'modules/domainjoin.bicep' = if (WK2OSVersion == 'Windows-7') {
  name: 'DomainJoinWK2VM_7'
  params: {
    computerName: wk2Name
    domainName: ChildDomainName    
    OUPath: ChildWIN7OUPath
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location2
  }
  dependsOn: [
    deployWK2VM_7
    createous
  ]
}
