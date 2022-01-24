@description('Specifies the name of the workspace.')
param workspaceName string

@description('Specifies the location in which to create the workspace.')
param location string

resource workspaceName_resource 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    features: {
      searchVersion: 1
    }
  }
}
