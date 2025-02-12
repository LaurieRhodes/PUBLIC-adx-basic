@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource ASIM11Script 'scripts' = {
      name: 'ASIM11Script'
      properties: {
        scriptContent: loadTextContent('../ASIM11.kql')
        continueOnErrors: false
      }
    }

    resource ASIM12Script 'scripts' = {
      name: 'ASIM12Script'
      properties: {
        scriptContent: loadTextContent('../ASIM12.kql')
        continueOnErrors: false
      }
    }

    resource ASIM13Script 'scripts' = {
      name: 'ASIM13Script'
      properties: {
        scriptContent: loadTextContent('../ASIM13.kql')
        continueOnErrors: false
      }
    }

    resource ASIM14Script 'scripts' = {
      name: 'ASIM14Script'
      properties: {
        scriptContent: loadTextContent('../ASIM14.kql')
        continueOnErrors: false
      }
    }

    resource ASIM15Script 'scripts' = {
      name: 'ASIM15Script'
      properties: {
        scriptContent: loadTextContent('../ASIM15.kql')
        continueOnErrors: false
      }
    }
  }
}