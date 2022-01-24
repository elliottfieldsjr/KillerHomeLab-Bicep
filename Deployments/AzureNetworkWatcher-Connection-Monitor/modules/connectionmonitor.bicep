@description('Connection Monitor Name')
param CMName string

@description('VM1 Resource Group')
param VM1ResourceGroupName string

@description('VM2 Resource Group')
param VM2ResourceGroupName string

@description('Source VM Name')
param SourceVMName string

@description('Source VM IP')
param SourceVMIP string

@description('Destination VM Name')
param DestinationVMName string

@description('Destination VM IP')
param DestinationVMIP string

@description('Region of Resources')
param location string

var SourceVMID = resourceId(VM1ResourceGroupName, 'Microsoft.Compute/virtualMachines', SourceVMName)
var NWID_var = 'NetworkWatcher_${location}/${CMName}'
var DestinationVMID = resourceId(VM2ResourceGroupName, 'Microsoft.Compute/virtualMachines', DestinationVMName)
var TestGroupName = '${SourceVMName}-to-${DestinationVMName}'

resource NWID 'Microsoft.Network/networkWatchers/connectionMonitors@2021-05-01' = {
  name: NWID_var
  location: location
  properties: {
    endpoints: [
      {
        name: SourceVMName
        resourceId: SourceVMID
        address: SourceVMIP
      }
      {
        name: DestinationVMName
        resourceId: DestinationVMID
        address: DestinationVMIP
      }
    ]
    testConfigurations: [
      {
        name: 'Web-Traffic'
        testFrequencySec: 30
        protocol: 'Tcp'
        successThreshold: {
          checksFailedPercent: 10
          roundTripTimeMs: 100
        }
        tcpConfiguration: {
          port: 80
          disableTraceRoute: false
        }
      }
    ]
    testGroups: [
      {
        name: TestGroupName
        sources: [
          SourceVMName
        ]
        destinations: [
          DestinationVMName
        ]
        testConfigurations: [
          'Web-Traffic'
        ]
        disable: false
      }
    ]
  }
}
