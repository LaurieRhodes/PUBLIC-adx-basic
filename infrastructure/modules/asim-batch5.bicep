@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource ASIM21Script 'scripts' = {
      name: 'ASIM21Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM21.kql')
        continueOnErrors: false
      }
    }

    resource ASIM22Script 'scripts' = {
      name: 'ASIM22Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM22.kql')
        continueOnErrors: false
      }
    }

    resource ASIM23Script 'scripts' = {
      name: 'ASIM23Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM23.kql')
        continueOnErrors: false
      }
    }

    resource ASIM24Script 'scripts' = {
      name: 'ASIM24Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM24.kql')
        continueOnErrors: false
      }
    }

    resource ASIM25Script 'scripts' = {
      name: 'ASIM25Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM25.kql')
        continueOnErrors: false
      }
    }

    resource ASIM26Script 'scripts' = {
      name: 'ASIM26Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM26.kql')
        continueOnErrors: false
      }
    }
  }
}