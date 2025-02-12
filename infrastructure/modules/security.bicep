@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource securitydb1Script 'scripts' = {
      name: 'securitydb1Script'
      properties: {
        scriptContent: loadTextContent('../securitydb1.kql')
        continueOnErrors: false
      }
    }

    resource securitydb2Script 'scripts' = {
      name: 'securitydb2Script'
      properties: {
        scriptContent: loadTextContent('../securitydb2.kql')
        continueOnErrors: false
      }
    }

    resource securitydb3Script 'scripts' = {
      name: 'securitydb3Script'
      properties: {
        scriptContent: loadTextContent('../securitydb3.kql')
        continueOnErrors: false
      }
    }
  }
}