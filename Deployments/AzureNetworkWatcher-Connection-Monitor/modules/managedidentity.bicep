@description('Managed ID Name')
param ManagedIDName string

@description('Region of Resources')
param location string

resource ManagedIDName_resource 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: ManagedIDName
  location: location
}

output manageduseridentity string = reference(resourceId(resourceGroup().name, 'Microsoft.ManagedIdentity/userAssignedIdentities', ManagedIDName)).principalId