@description('Computer Name')
param computerName string

@description('Region of Resources')
param location string

resource computerName_AzureNetworkWatcherExtension 'Microsoft.Compute/virtualMachines/extensions@2021-07-01' = {
  name: '${computerName}/AzureNetworkWatcherExtension'
  location: location
  properties: {
    autoUpgradeMinorVersion: true
    publisher: 'Microsoft.Azure.NetworkWatcher'
    type: 'NetworkWatcherAgentWindows'
    typeHandlerVersion: '1.4'
  }
}
