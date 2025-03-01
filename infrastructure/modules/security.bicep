@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2024-04-13' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource securitydb1Script 'scripts' = {
      name: 'securitydb1Script'
      properties: {
        scriptContent: loadTextContent('SecurityDB/securitydb1.kql')
        continueOnErrors: false
      }
    }

    resource securitydb2Script 'scripts' = {
      name: 'securitydb2Script'
      properties: {
        scriptContent: loadTextContent('SecurityDB/securitydb2.kql')
        continueOnErrors: false
      }
    }

    resource securitydb3Script 'scripts' = {
      name: 'securitydb3Script'
      properties: {
        scriptContent: loadTextContent('SecurityDB/securitydb3.kql')
        continueOnErrors: false
      }
    }
  }
}