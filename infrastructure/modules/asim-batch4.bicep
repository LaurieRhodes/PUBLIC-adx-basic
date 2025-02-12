@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource ASIM16Script 'scripts' = {
      name: 'ASIM16Script'
      properties: {
        scriptContent: loadTextContent('../ASIM16.kql')
        continueOnErrors: false
      }
    }

    resource ASIM17Script 'scripts' = {
      name: 'ASIM17Script'
      properties: {
        scriptContent: loadTextContent('../ASIM17.kql')
        continueOnErrors: false
      }
    }

    resource ASIM18Script 'scripts' = {
      name: 'ASIM18Script'
      properties: {
        scriptContent: loadTextContent('../ASIM18.kql')
        continueOnErrors: false
      }
    }

    resource ASIM19Script 'scripts' = {
      name: 'ASIM19Script'
      properties: {
        scriptContent: loadTextContent('../ASIM19.kql')
        continueOnErrors: false
      }
    }

    resource ASIM20Script 'scripts' = {
      name: 'ASIM20Script'
      properties: {
        scriptContent: loadTextContent('../ASIM20.kql')
        continueOnErrors: false
      }
    }
  }
}