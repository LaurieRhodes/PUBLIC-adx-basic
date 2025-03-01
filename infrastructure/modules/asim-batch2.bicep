@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource ASIM6Script 'scripts' = {
      name: 'ASIM6Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM6.kql')
        continueOnErrors: false
      }
    }

    resource ASIM7Script 'scripts' = {
      name: 'ASIM7Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM7.kql')
        continueOnErrors: false
      }
    }

    resource ASIM8Script 'scripts' = {
      name: 'ASIM8Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM8.kql')
        continueOnErrors: false
      }
    }

    resource ASIM9Script 'scripts' = {
      name: 'ASIM9Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM9.kql')
        continueOnErrors: false
      }
    }

    resource ASIM10Script 'scripts' = {
      name: 'ASIM10Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM10.kql')
        continueOnErrors: false
      }
    }
  }
}