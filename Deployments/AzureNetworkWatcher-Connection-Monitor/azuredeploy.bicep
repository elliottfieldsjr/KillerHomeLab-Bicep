// set the target scope for this file
targetScope = 'subscription'

@description('Resource Group 1 Name')
param ResourceGroup1Name string

@description('Resource Group 2 Name')
param ResourceGroup2Name string

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

@description('Environment Naming Convention')
param NamingConvention string

@description('Virtual Network 1 Prefix')
param VNet1ID string

@description('Virtual Network 2 Prefix')
param VNet2ID string

@description('Domain Controller1 OS Version')
param VM1OSVersion string

@description('Domain Controller2 OS Version')
param VM2OSVersion string

@description('Domain Controller1 VMSize')
param VM1VMSize string

@description('Domain Controller1 VMSize')
param VM2VMSize string

@description('Location 1 for Resources')
param Location1 string

@description('Location 2 for Resources')
param Location2 string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var vm1lastoctet = '101'
var vm2lastoctet = '101'
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
var WorkSpaceName = '${NamingConvention}-LAW1'
var vm1Name = '${NamingConvention}-vm-01'
var vm1IP = '${VNet1ID}.1.${vm1lastoctet}'
var vm2Name = '${NamingConvention}-vm-02'
var vm2IP = '${VNet2ID}.1.${vm2lastoctet}'
var ManagedIDName = '${NamingConvention}-mi-${uniqueString(subscription().id)}'
var CMName = '${NamingConvention}-cm-${uniqueString(subscription().id)}'
var Contributor = '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'

resource RG1 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroup1Name
  location: Location1
}

resource RG2 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: ResourceGroup2Name
  location: Location2
}

resource NetworkWatcherRG 'Microsoft.Resources/resourceGroups@2021-04-01' existing = {
  name: 'NetworkWatcherRG'
}

module DeployLogAnalyticsWorkspace 'modules/loganalyticsworkspace.bicep' = {
  name: 'DeployLogAnalyticsWorkspace'
  scope: RG1
  params: {
    workspaceName:  WorkSpaceName
    location: 'usgovvirginia'
  }
}

module VNet1 'modules/vnet.bicep' = {
  name: 'VNet1'
  scope: RG1  
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
  scope: RG2  
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

module VNet1ToVNet2Peering 'modules/peering.bicep' = {
  name: 'VNet1ToVNet2Peering'
  scope: RG1                
  params: {
    SourceVNetName: VNet1Name
    TargetVNetName: VNet2Name
    TargetVNetRG:ResourceGroup2Name
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    VNet1
    VNet2
  ]
}

module VNet2ToVNet1Peering 'modules/peering.bicep' = {
  name: 'VNet2ToVNet1Peering'
  scope: RG2               
  params: {
    SourceVNetName: VNet2Name
    TargetVNetName: VNet1Name
    TargetVNetRG: ResourceGroup1Name    
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    VNet1
    VNet2
    VNet1ToVNet2Peering
  ]
}

module BastionHost1 'modules/bastionhost.bicep' = {
  name: 'BastionHost1'
  scope: RG1    
  params: {
    publicIPAddressName: '${VNet1Name}-Bastion-pip'
    AllocationMethod: 'Static'
    vnetName: VNet1Name
    subnetName: 'AzureBastionSubnet'
    location: Location1
  }
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module deployVNet1VM 'modules/1nic-1disk-vm.bicep' = {
  name: 'deployVNet1VM'
  scope: RG1    
  params: {
    computerName: vm1Name
    Nic1IP: vm1IP
    TimeZone: TimeZone1
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsServer'
    Offer: 'WindowsServer'
    OSVersion: VM1OSVersion
    licenseType: WindowsServerLicenseType
    VMSize: VM1VMSize
    vnetName: VNet1Name
    subnetName: VNet1subnet1Name
    adminUsername: adminUsername
    adminPassword: adminPassword
    location: Location1
  }
  dependsOn: [
    VNet1ToVNet2Peering
    VNet2ToVNet1Peering
  ]
}

module DeployVNet1VMNW 'modules/networkwatcher.bicep' = {
  name: 'DeployVNet1VMNW'
  scope: RG1    
  params: {
    computerName: vm1Name
    location: Location1
  }
  dependsOn: [
    deployVNet1VM
  ]
}

module deployVNet2VM 'modules/1nic-1disk-vm.bicep' = {
  name: 'deployVNet2VM'
  scope: RG2    
  params: {
    computerName: vm2Name
    Nic1IP: vm2IP
    TimeZone: TimeZone2
    AutoShutdownEnabled: AutoShutdownEnabled
    AutoShutdownTime: AutoShutdownTime
    AutoShutdownEmail: AutoShutdownEmail    
    Publisher: 'MicrosoftWindowsServer'
    Offer: 'WindowsServer'
    OSVersion: VM2OSVersion
    licenseType: WindowsServerLicenseType
    VMSize: VM2VMSize
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

module InstallIIS 'modules/iis.bicep' = {
  name: 'InstallIIS'
  scope: RG1      
  params: {
    computerName: vm1Name
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
    location: Location2
  }
  dependsOn: [
    deployVNet2VM
  ]
}

module DeployVNet2VMNW 'modules/networkwatcher.bicep' = {
  name: 'DeployVNet2VMNW'
  scope: RG2    
  params: {
    computerName: vm2Name
    location: Location2
  }
  dependsOn: [
    deployVNet2VM
    InstallIIS
  ]
}

module CreateManagedID 'modules/managedidentity.bicep' = {
  name: 'CreateManagedID'
  scope: RG1
  params: {
    ManagedIDName: ManagedIDName
    location: Location1
  }
}

module AssignManagedIDRG1 'modules/roleassignment.bicep' = {
  name: 'AssignManagedIDRG1'
  scope: RG1
  params: {
    PrincipalID: reference('CreateManagedID').outputs.manageduseridentity.value
    RoleDefinitionID: Contributor  
    roleAssignmentHash: 'NetworkWatcher1'
  }
  dependsOn: [
    CreateManagedID
  ]
}

module AssignManagedIDRG2 'modules/roleassignment.bicep' = {
  name: 'AssignManagedIDRG2'
  scope: RG2
  params: {
    PrincipalID: reference('CreateManagedID').outputs.manageduseridentity.value
    RoleDefinitionID: Contributor  
    roleAssignmentHash: 'NetworkWatcher2'
  }
  dependsOn: [
    CreateManagedID
  ]
}

module ConnectVM1 'modules/connectlaw.bicep' = {
  name: 'ConnectVM1'
  scope: RG1
  params: {
    VM: vm1Name
    WorkspaceName: WorkSpaceName
    VMResourceGroupName: ResourceGroup1Name
    WorkspaceResourceGroup: ResourceGroup1Name
    ManagedIDName: ManagedIDName
    ScriptLocation: 'usgovvirginia'
    location: Location1
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
  }
  dependsOn: [
    DeployLogAnalyticsWorkspace
    deployVNet1VM
    DeployVNet1VMNW
    CreateManagedID
    AssignManagedIDRG1
    AssignManagedIDRG2
  ]
}

module ConnectVM2 'modules/connectlaw.bicep' = {
  name: 'ConnectVM2'
  scope: RG2
  params: {
    VM: vm2Name
    WorkspaceName: WorkSpaceName
    VMResourceGroupName: ResourceGroup2Name
    WorkspaceResourceGroup: ResourceGroup1Name
    ManagedIDName: ManagedIDName
    ScriptLocation: 'usgovvirginia'
    location: Location2
    artifactsLocation: artifactsLocation
    artifactsLocationSasToken: artifactsLocationSasToken
  }
  dependsOn: [
    DeployLogAnalyticsWorkspace
    deployVNet2VM
    DeployVNet2VMNW
    CreateManagedID
    AssignManagedIDRG1
    AssignManagedIDRG2
    ConnectVM1
  ]
}

module DeployConnectionMonitor 'modules/connectionmonitor.bicep' = {
  name: 'DeployConnectionMonitor'
  scope: NetworkWatcherRG
  params: {
    CMName: CMName
    VM1ResourceGroupName: ResourceGroup1Name
    VM2ResourceGroupName: ResourceGroup2Name
    SourceVMName: vm1Name
    SourceVMIP: vm1IP
    DestinationVMName: vm2Name
    DestinationVMIP: vm2IP
    location: Location2
  }
  dependsOn: [
    DeployLogAnalyticsWorkspace
    DeployVNet1VMNW
    DeployVNet2VMNW
    CreateManagedID
    AssignManagedIDRG2
    AssignManagedIDRG2
    ConnectVM1
    ConnectVM2
  ]
}


