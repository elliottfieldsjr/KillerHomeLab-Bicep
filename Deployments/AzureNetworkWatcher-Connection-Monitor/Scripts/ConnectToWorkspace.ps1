param(
    [string] [Parameter(Mandatory=$true)] $VM,
    [string] [Parameter(Mandatory=$true)] $WorkspaceName,
    [string] [Parameter(Mandatory=$true)] $WorkspaceResourceGroup,
    [string] [Parameter(Mandatory=$true)] $VMResourceGroup,
    [string] [Parameter(Mandatory=$true)] $Location
    )

$Workspace =  Get-AzOperationalInsightsWorkspace -ResourceGroupName $WorkspaceResourceGroup -Name $WorkspaceName
$WorkspaceID = $Workspace.CustomerId
$workspaceKey = (Get-AzOperationalInsightsWorkspaceSharedKey -ResourceGroupName $WorkspaceResourceGroup -Name $Workspace.Name).PrimarySharedKey
Set-AzVMExtension -ResourceGroupName $VMResourceGroup -VMName $VM -Name 'MicrosoftMonitoringAgent' -Publisher 'Microsoft.EnterpriseCloud.Monitoring' -ExtensionType 'MicrosoftMonitoringAgent' -TypeHandlerVersion '1.0' -Location $location -SettingString "{'workspaceId':  '$workspaceId'}" -ProtectedSettingString "{'workspaceKey': '$workspaceKey' }"