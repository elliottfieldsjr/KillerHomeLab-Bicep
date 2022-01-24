@description('Managed ID Name')
param PrincipalID string

@description('Managed ID Name')
param RoleDefinitionID string

@description('A new GUID used to identify the role assignment')
param roleAssignmentGuid string

resource roleAssignmentGuid_resource 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
  name: roleAssignmentGuid
  scope: resourceGroup()
  properties: {
    roleDefinitionId: RoleDefinitionID
    principalId: PrincipalID
    principalType: 'ServicePrincipal'
  }
}
