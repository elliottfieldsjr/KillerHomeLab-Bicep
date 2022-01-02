@description('Computer Name')
param computerName string

@description('Network Card 1 IP Address')
param ComputerIP1 string

@description('Time Zone')
param TimeZone string

@description('Enable or Disable Auto-Shutdown')
param AutoShutdownEnabled string

@description('Time to Shutdown VM')
param AutoShutdownTime string

@description('Notification Email for Auto-Shutdown')
param AutoShutdownEmail string

@description('Image Publisher')
param Publisher string

@description('Image Publisher Offer')
param Offer string

@description('OS Version')
param OSVersion string

@description('License Type (Windows_Server or None)')
param licenseType string

@description('Data Disk Name 1')
param DataDisk1Name string

@description('VMSize')
param VMSize string

@description('Existing VNET Name that contains the domain controller')
param vnetName string

@description('Existing subnet name that contains the domain controller')
param subnetName string

@description('The name of the Administrator of the new VM and Domain')
param adminUsername string

@description('The password for the Administrator account of the new VM and Domain')
@secure()
param adminPassword string

@description('Region of Resources')
param location string

var storageAccountType = 'Premium_LRS'
var DataDiskSize = 50
var subnetId = resourceId(resourceGroup().name, 'Microsoft.Network/virtualNetworks/subnets', ${vnetName}, ${subnetName})
var VMId = resourceId(resourceGroup().name, 'Microsoft.Compute/virtualMachines', ${computerName})
var NicName_var = '${computerName}-nic'
var VMName_var = ${computerName}
var NIC1ip = ${ComputerIP1}

resource NicName 'Microsoft.Network/networkInterfaces@2018-11-01' = {
  name: NicName_var
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Static'
          privateIPAddress: Nic1IP
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource VMName 'Microsoft.Compute/virtualMachines@2019-03-01' = {
  name: VMName_var
  location: location
  properties: {
    licenseType: licenseType
    hardwareProfile: {
      vmSize: VMSize
    }
    osProfile: {
      computerName: VMName_var
      adminUsername: adminUsername
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: Publisher
        offer: Offer
        sku: OSVersion
        version: 'latest'
      }
      osDisk: {
        name: '${VMName_var}_OSDisk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: storageAccountType
        }
      }
      dataDisks: [
        {
          name: '${VMName_var}_${DataDisk1Name}'
          caching: 'None'
          diskSizeGB: DataDiskSize
          lun: 0
          createOption: 'Empty'
          managedDisk: {
            storageAccountType: storageAccountType
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: NicName.id
        }
      ]
    }
  }
}

resource shutdown_computevm_computerName 'microsoft.devtestlab/schedules@2018-09-15' = if (AutoShutdownEnabled == 'Yes') {
  name: 'shutdown-computevm-${computerName}'
  location: location
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: AutoShutdownTime
    }
    timeZoneId: TimeZone
    notificationSettings: {
      status: 'Enabled'
      timeInMinutes: 30
      emailRecipient: AutoShutdownEmail
      notificationLocale: 'en'
    }
    targetResourceId: VMId
  }
  dependsOn: [
    VMName
  ]
}