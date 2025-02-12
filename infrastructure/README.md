# Azure Data Explorer (ADX) Cluster Deployment Guide

This documentation provides detailed information about deploying an Azure Data Explorer (ADX) cluster using Bicep templates. The deployment includes a cluster with a security database and associated KQL scripts.

## File Structure

- `main.bicep` - Main deployment template
- 
- `parameters.json` - Deployment parameters
- `securitydb1.kql`, `securitydb2.kql`, `securitydb3.kql` - KQL scripts for database configuration

## Parameters

### Common Parameters

| Parameter            | Description                   | Default Value           | Constraints       |
| -------------------- | ----------------------------- | ----------------------- | ----------------- |
| location             | Azure region for deployment   | Resource group location | -                 |
| ADXClusterName       | Name of the ADX cluster       | -                       | Required          |
| skuName              | SKU name for the cluster      | Standard_D12_v2         | -                 |
| tier                 | Pricing tier                  | Basic                   | -                 |
| skuCapacity          | Number of cluster nodes       | 2                       | Min: 1, Max: 1000 |
| securitydatabaseName | Name of the security database | security                | -                 |

### Parameters File Values

The `parameters.json` file contains the following deployment-specific values:

```json
{
  "location": "australiasoutheast",
  "ADXResourceGroup": "rg-adx",
  "ADXClusterName": "securitylogs"
}
```

## Resource Configuration

The deployment creates:

1. An ADX Cluster with:
   
   - System-assigned managed identity
   - Specified SKU and capacity
   - Located in the specified Azure region

2. A Security Database with:
   
   - ReadWrite access
   - Three KQL scripts for database configuration
   - Automated script execution during deployment

## Deployment Instructions

### Prerequisites

1. Install the Azure CLI
2. Log in to Azure
3. Install Bicep tools

### Deployment Steps

1. **Login to Azure**:
   
   ```powershell
   az login
   ```

2. **Set your subscription**:
   
   ```powershell
   az account set --subscription "<subscription-id>"
   ```

3. **Create Resource Group** (if it doesn't exist):
   
   ```powershell
   az group create --name rg-adx --location australiasoutheast
   ```

4. **Deploy the Bicep template**:
   
   ```powershell
   az deployment group create `
     --resource-group rg-adx `
     --template-file main.bicep `
     --parameters parameters.json
   ```

### Deployment Validation

To validate the deployment before executing:

```powershell
az deployment group what-if `
  --resource-group rg-adx `
  --template-file main.bicep `
  --parameters parameters.json
```

## Post-Deployment

After deployment, the ADX cluster will be created with:

- A system-assigned managed identity
- The security database
- Executed KQL scripts for database configuration

You can access the cluster through:

- Azure Portal
- ADX Web UI
- Kusto Explorer

## Important Notes

1. The deployment uses system-assigned managed identity for security
2. KQL scripts are executed in order (securitydb1 → securitydb2 → securitydb3)
3. Script execution errors will halt the deployment (continueOnErrors: false)
4. The Basic tier is used by default - consider your performance requirements
5. Default node count is 2 - adjust based on your workload needs

## Monitoring Deployment

Monitor the deployment progress in:

- Azure Portal
- Azure CLI:
  
  ```powershell
  az deployment group show `
    --name <deployment-name> `
    --resource-group rg-adx
  ```
