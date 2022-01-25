@description('VM Name')
param VM string

@description('Log Analytics Workspace Name')
param WorkspaceName string

@description('Worksapce Resource Group')
param WorkspaceResourceGroup string

@description('VM Resource Group')
param VMResourceGroupName string

@description('ManagedID')
param ManagedIDName string

@description('Region of Resources')
param ScriptLocation string

@description('Region of Resources')
param location string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string

@description('Auto-generated token to access _artifactsLocation')
@secure()
param artifactsLocationSasToken string

var ScriptURL = uri(artifactsLocation, 'Scripts/ConnectToWorkspace.ps1${artifactsLocationSasToken}')

resource ConnectToWorkspace 'Microsoft.Resources/deploymentScripts@2020-10-01' = {
  name: 'ConnectToWorkspace'
  location: ScriptLocation
  kind: 'AzurePowerShell'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId(WorkspaceResourceGroup,  'Microsoft.ManagedIdentity/userAssignedIdentities', ManagedIDName)}': {}
    }
  }
  properties: {
    azPowerShellVersion: '3.0'
    timeout: 'PT1H'
    arguments: ' -VM ${VM} -WorkspaceName ${WorkspaceName} -WorkspaceResourceGroup ${WorkspaceResourceGroup} -VMResourceGroup ${VMResourceGroupName} -Location ${location}'
    primaryScriptUri: ScriptURL
    cleanupPreference: 'OnSuccess'
    retentionInterval: 'P1D'
  }
}
