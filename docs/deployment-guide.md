# Deployment Guide

This guide provides detailed instructions for deploying the Azure Data Explorer Security Data Lake solution to your Azure environment.

## Deployment Overview

The deployment process uses Infrastructure as Code (IaC) through Bicep templates and PowerShell automation to create and configure all necessary resources. The deployment is designed to be repeatable, consistent, and adaptable to different environments.

## Prerequisites

Before deploying, ensure you have:

1. **Required Tools**:
   
   - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (2.40.0+)
   - [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (0.9.0+)
   - [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (7.0+)
   - [Git](https://git-scm.com/) (2.30.0+)

2. **Azure Permissions**:
   
   - Azure subscription with Contributor access
   - Permission to create and manage resource groups
   - Ability to create service principals (if using CI/CD pipelines)

3. **Resource Requirements**:
   
   - Sufficient quota for ADX cluster resources (check subscription limits)
   - Available capacity in your target region

## Deployment Parameters

The main parameters for deployment are defined in `infrastructure/parameters.json`:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "location": {
      "value": "australiasoutheast"
    },
    "ADXClusterName": {
      "value": "adx-security-cluster"
    },
    "skuName": {
      "value": "Standard_D12_v2"
    },
    "skutier": {
      "value": "Standard"
    },
    "skuCapacity": {
      "value": 2
    },
    "securitydatabaseName": {
      "value": "security"
    }
  }
}
```

The example parameter file in this repository 

### Parameter Descriptions

| Parameter            | Description                            | Recommendations                                      |
| -------------------- | -------------------------------------- | ---------------------------------------------------- |
| location             | Azure region for deployment            | Choose a region close to your security operations    |
| ADXClusterName       | Name of the ADX cluster                | Use a descriptive name that identifies purpose       |
| skuName              | Virtual machine size for cluster nodes | Standard_D12_v2 for medium workloads                 |
| skutier              | Pricing tier (Standard or Basic)       | Standard provides better performance                 |
| skuCapacity          | Number of cluster nodes                | Start with 2 for testing, scale based on data volume |
| securitydatabaseName | Name of the security database          | Use a simple name like "security"                    |

## Deployment Process

### 1. Clone the Repository

```bash
git clone https://github.com/YourUsername/PUBLIC-adx-basic.git
cd PUBLIC-adx-basic
```

### 2. Customize Parameters

Modify the `infrastructure/parameters.json` file to match your requirements:

```powershell
# Example: Edit parameters.json to set a different region
(Get-Content -Path .\infrastructure\parameters.json) -replace '"australiasoutheast"', '"eastus"' | Set-Content -Path .\infrastructure\parameters.json
```

### 3. Execute Deployment

Run the deployment script with your resource group name:

```powershell
cd infrastructure
.\deploy.ps1 -resourceGroupName "rg-security-adx"
```

The script will:

1. Verify Azure authentication
2. Create the resource group if it doesn't exist
3. Deploy the ADX cluster and security database
4. Configure ASIM parsers and security database schemas

> **Note**: The deployment typically takes 15-20 minutes to complete.

### 4. Verify Deployment

After deployment completes, you can verify the resources:

```powershell
# Check resource group deployment status
az group deployment list --resource-group "rg-security-adx" --query "[].{Name:name, ProvisioningState:properties.provisioningState}" -o table

# View the ADX cluster details
az kusto cluster show --name <your-cluster-name> --resource-group "rg-security-adx"
```

You can also verify through the Azure Portal:

1. Navigate to your resource group

2. Confirm the ADX cluster is running

3. Open the Data Explorer web UI

4. Verify the security database exists

5. Check that ASIM functions are deployed using this KQL:
   
   ```
   .show database security functions
   | where Name startswith "ASim"
   ```

## Deployment Components

The deployment consists of the following key components:

### 1. Resource Group

A container for all deployment resources, created if it doesn't exist.

### 2. ADX Cluster

The core infrastructure deployed with:

- System-assigned managed identity
- Specified VM size and count
- Network configuration

### 3. Security Database

A dedicated database for security data with:

- Read/write configuration
- Database-level access control

### 4. ASIM Parsers

Functions that normalize security data:

- Deployed in batches to overcome template size limits
- Configured for supported log types

### 5. Table Schemas

Predefined table structures for security data:

- Raw tables for ingestion
- Mapping configurations
- Update policies

## Deployment Customizations

### Network Configuration

To deploy with private endpoints:

1. Add network parameters to `parameters.json`:
   
   ```json
   "enablePrivateEndpoints": {
     "value": true
   },
   "subnetId": {
     "value": "/subscriptions/{sub-id}/resourceGroups/{rg}/providers/Microsoft.Network/virtualNetworks/{vnet}/subnets/{subnet}"
   }
   ```

2. Modify `modules/cluster.bicep` to include private endpoint resources (see Azure docs for details)

### Custom Sizing

For larger environments:

1. Increase node count in `parameters.json`:
   
   ```json
   "skuCapacity": {
     "value": 4
   }
   ```

2. Choose a larger VM size:
   
   ```json
   "skuName": {
     "value": "Standard_D14_v2"
   }
   ```

## CI/CD Pipeline Integration

To integrate with CI/CD pipelines:

### Azure DevOps

1. Create a YAML pipeline file in your repository:
   
   ```yaml
   trigger:
     branches:
       include:
         - main
   
   pool:
     vmImage: 'ubuntu-latest'
   
   steps:
   - task: AzureCLI@2
     inputs:
       azureSubscription: 'YourServiceConnection'
       scriptType: 'bash'
       scriptLocation: 'inlineScript'
       inlineScript: |
         az deployment group create --resource-group $(resourceGroupName) --template-file infrastructure/main.bicep --parameters infrastructure/parameters.json
   ```

2. Configure service connection and variables in Azure DevOps

### GitHub Actions

Create a workflow file in `.github/workflows/`:

```yaml
name: Deploy ADX Security Data Lake

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Azure Login
        uses: azure/login@v1
        with:
          creds: ${{ secrets.AZURE_CREDENTIALS }}

      - name: Deploy Bicep
        uses: azure/arm-deploy@v1
        with:
          resourceGroupName: ${{ secrets.RESOURCE_GROUP }}
          template: ./infrastructure/main.bicep
          parameters: ./infrastructure/parameters.json
```

## Troubleshooting

### Common Deployment Issues

#### Resource Naming Conflicts

**Symptom**: Deployment fails with a conflict error

**Solution**: Change the cluster name in parameters.json to a unique value

#### Quota Limitations

**Symptom**: Deployment fails with quota exceeded error

**Solution**: Request a quota increase or reduce the VM size/count

#### ASIM Parser Deployment Failures

**Symptom**: Cluster deploys but ASIM functions are missing

**Solution**: 

1. Check Azure deployment logs
2. Try deploying the ASIM*.kql scripts manually via the ADX web UI
3. Ensure you have the latest version of the repository files

#### Permission Issues

**Symptom**: Deployment fails with authorization errors

**Solution**: Ensure your account has Contributor role on the subscription or resource group

## Post-Deployment Steps

After successful deployment:

1. Configure data connections
2. Set up database permissions
3. Verify ingestion with test data
4. Configure monitoring and alerts

See the [Operations Guide](./operations.md) for these steps.

## References

- [Azure Data Explorer Deployment Documentation](https://docs.microsoft.com/en-us/azure/data-explorer/create-cluster-database-bicep)
- [Bicep Documentation](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/overview)
- [Azure Resource Manager Templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/)
