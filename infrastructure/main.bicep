@description('Location for all resources')
param location string = resourceGroup().location

@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the sku')
param skuName string

@description('Tier of the sku')
param skutier string

@description('# of nodes')
@minValue(1)
@maxValue(1000)
param skuCapacity int

@description('Name of the security database')
param securitydatabaseName string

// Deploy the base cluster and database
module clusterDeploy 'modules/cluster.bicep' = {
  name: 'clusterDeploy'
  params: {
    location: location
    ADXClusterName: ADXClusterName
    skuName: skuName
    skutier: skutier
    skuCapacity: skuCapacity
    securitydatabaseName: securitydatabaseName
  }
}

// Deploy ASIM scripts in batches
module asimBatch1 'modules/asim-batch1.bicep' = {
  name: 'asimBatch1Deploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    clusterDeploy
  ]
}

module asimBatch2 'modules/asim-batch2.bicep' = {
  name: 'asimBatch2Deploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    asimBatch1
  ]
}

module asimBatch3 'modules/asim-batch3.bicep' = {
  name: 'asimBatch3Deploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    asimBatch2
  ]
}

module asimBatch4 'modules/asim-batch4.bicep' = {
  name: 'asimBatch4Deploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    asimBatch3
  ]
}

module asimBatch5 'modules/asim-batch5.bicep' = {
  name: 'asimBatch5Deploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    asimBatch4
  ]
}

// Deploy security scripts last
module securityScripts 'modules/security.bicep' = {
  name: 'securityScriptsDeploy'
  params: {
    ADXClusterName: ADXClusterName
    securitydatabaseName: securitydatabaseName
  }
  dependsOn: [
    asimBatch5
  ]
}