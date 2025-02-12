@description('Location for all resources')
param location string

@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the sku')
param skuName string

@description('Tier of the sku')
param skutier string

@description('# of nodes')
param skuCapacity int

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' = {
  name: ADXClusterName
  location: location
  sku: {
    name: skuName
    tier: skutier
    capacity: skuCapacity
  }
  identity: {
    type: 'SystemAssigned'
  }

  resource kustoDb 'databases' = {
    name: securitydatabaseName
    location: location
    kind: 'ReadWrite'
  }
}