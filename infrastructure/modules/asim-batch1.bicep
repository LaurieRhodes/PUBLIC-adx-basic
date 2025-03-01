@description('ADX Cluster Name')
param ADXClusterName string

@description('Name of the security database')
param securitydatabaseName string

resource cluster 'Microsoft.Kusto/clusters@2022-02-01' existing = {
  name: ADXClusterName

  resource kustoDb 'databases' existing = {
    name: securitydatabaseName

    resource ASIM1Script 'scripts' = {
      name: 'ASIM1Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM1.kql')
        continueOnErrors: false
      }
    }

    resource ASIM2Script 'scripts' = {
      name: 'ASIM2Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM2.kql')
        continueOnErrors: false
      }
    }

    resource ASIM3Script 'scripts' = {
      name: 'ASIM3Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM3.kql')
        continueOnErrors: false
      }
    }

    resource ASIM4Script 'scripts' = {
      name: 'ASIM4Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM4.kql')
        continueOnErrors: false
      }
    }

    resource ASIM5Script 'scripts' = {
      name: 'ASIM5Script'
      properties: {
        scriptContent: loadTextContent('Asim/ASIM5.kql')
        continueOnErrors: false
      }
    }
  }
}