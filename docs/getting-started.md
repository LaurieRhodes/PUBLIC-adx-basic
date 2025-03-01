# Getting Started with Azure Data Explorer Security Data Lake

This guide will help you get started with deploying and configuring the Azure Data Explorer (ADX) security data lake solution. It covers the essential steps to understand the project, deploy the infrastructure, and begin using the solution for security data management.

## Understanding the Solution

The Azure Data Explorer Security Data Lake is a comprehensive solution for centralizing, storing, and analyzing security log data at scale. It leverages Azure Data Explorer's powerful query capabilities and cost-effective storage to create a security-optimized data repository that aligns with Microsoft's Advanced Security Information Model (ASIM).

Key components of this solution include:

1. **Azure Data Explorer Cluster**: The core infrastructure providing compute and storage
2. **Security Database**: A dedicated database for security telemetry
3. **ASIM Parsers**: Normalization functions that align with Microsoft's security schema
4. **Table Definitions**: Optimized table structures for security data
5. **Deployment Automation**: Infrastructure-as-Code (IaC) for consistent setup

## Pre-Deployment Checklist

Before deploying the solution, ensure you have:

- [ ] An Azure subscription with required permissions
- [ ] Azure CLI installed (version 2.40.0 or newer)
- [ ] Bicep CLI installed (version 0.9.0 or newer)
- [ ] PowerShell 7.0 or newer
- [ ] Git client installed
- [ ] Decided on deployment parameters (region, cluster size, etc.)
- [ ] Identified security log sources that will feed into the data lake

## Deployment Steps

Follow these steps to deploy the solution:

1. **Clone the repository**
   
   ```bash
   git clone https://github.com/LaurieRhodes/PUBLIC-adx-basic.git
   cd PUBLIC-adx-basic
   ```

2. **Review and customize parameters**
   
   Edit the `infrastructure/parameters.json` file to specify your deployment settings:
   
   - Cluster location
   - Cluster name
   - VM size (SKU)
   - Number of instances
   - Database name

3. **Execute deployment script**
   
   ```powershell
   cd infrastructure
   .\deploy.ps1 -resourceGroupName "rg-security-adx"
   ```

4. **Verify deployment**
   
   After deployment completes:
   
   - Navigate to the Azure Portal
   - Go to your ADX cluster
   - Verify that the security database exists
   - Check that ASIM functions have been created

## Next Steps

After successful deployment, refer to these guides for further configuration:

- [Deployment Guide](./deployment-guide.md) for detailed deployment information
- [Schema Documentation](./schema.md) for understanding data structure
- [Security Integration](./security-integration.md) for connecting data sources
- [Operations Guide](./operations.md) for day-to-day management

## Troubleshooting

### Common Deployment Issues

#### Resource Quota Limitations

If you encounter quota limitations, you may need to request a quota increase or deploy in a different region.

#### Authorisation Failures

Ensure you have the correct permissions (Contributor or higher) on the subscription or resource group.

#### Failed ASIM Parser Deployment

The ASIM parsers are deployed in batches to overcome Bicep template size limitations. If parser deployment fails:

1. Check Azure deployment logs
2. Try deploying the KQL scripts manually using the Azure Data Explorer web UI
3. Review the logs for specific error messages
