@description('Time Zone')
param TimeZone1 string

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

@description('Sub DNS Domain Name Example:  DC=sub2,DC=sub1, must include COMMA AT END')
param SubDNSBaseDN string

@description('NetBios Parent Domain Name')
param NetBiosDomain string

@description('NetBios Parent Domain Name')
param InternalDomain string

@description('Internal Top-Level Domain Name')
param InternalTLD string

@description('External DNS Domain')
param ExternalDomain string

@description('External Top-Level Domain Name')
param ExternalTLD string

@description('VNet1 Prefix')
param VNet1ID string

@description('DNS Reverse Lookup Zone1 Prefix')
param ReverseLookup1 string

@description('Domain Controller1 OS Version')
param DC1OSVersion string

@description('Workstation1 OS Version')
param WK1OSVersion string

@description('Domain Controller1 VMSize')
param DC1VMSize string

@description('Workstation1 VMSize')
param WK1VMSize string

@description('The location of resources, such as templates and DSC modules, that the template depends on')
param artifactsLocation string = deployment().properties.templateLink.uri

@description('Auto-generated token to access _artifactsLocation. Leave it blank unless you need to provide your own value.')
@secure()
param artifactsLocationSasToken string = ''

var VNet1Name = '${NamingConvention}-VNet1'
var VNet1Prefix = '${VNet1ID}.0.0/16'
var VNet1subnet1Name = '${NamingConvention}-VNet1-Subnet1'
var VNet1subnet1Prefix = '${VNet1ID}.1.0/24'
var VNet1BastionsubnetPrefix = '${VNet1ID}.253.0/24'
var dc1name = '${NamingConvention}-dc-01'
var dc1IP = '${VNet1ID}.4.${dc1lastoctet}'
var dc1lastoctet = '100'
var wk1name = '${NamingConvention}-wk-01'
var wk1IP = '${VNet1ID}.7.${wk1lastoctet}'
var wk1lastoctet = '100'
var InternaldomainName = '${SubDNSDomain}${InternalDomain}.${InternalTLD}'
var ExternaldomainName = '${ExternalDomain}.${ExternalTLD}'
var BaseDN = '${SubDNSBaseDN}DC=${InternalDomain},DC=${InternalTLD}'
var SRVOUPath = 'OU=Servers,${BaseDN}'
var WKOUPath = 'OU=Windows 10,OU=Workstations,${BaseDN}'

module VNet1 'linkedtemplates/vnet.bicep' = {
  name: 'VNet1'
  params: {
    vnetName: VNet1Name
    vnetprefix: VNet1Prefix
    subnet1Name: VNet1subnet1Name
    subnet1Prefix: VNet1subnet1Prefix
    subnet2Name: VNet1subnet2Name
    subnet2Prefix: VNet1subnet2Prefix    
    BastionsubnetPrefix: VNet1BastionsubnetPrefix
    location: resourceGroup().location
  }
}