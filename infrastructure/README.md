# Azure Data Explorer (ADX) Security Infrastructure

This directory contains the infrastructure components for the Azure Data Explorer Security Data Lake solution. The infrastructure is defined using Bicep templates and KQL scripts, designed for automated deployment and configuration.

## Infrastructure Architecture

The deployment architecture follows a modular approach:

```
main.bicep
   │
   ├── modules/cluster.bicep
   │       └── Azure Data Explorer Cluster
   │
   ├── modules/asim-batch1.bicep ... asim-batch5.bicep
   │       └── ASIM Parser Functions (deployed in batches)
   │
   └── modules/security.bicep
           └── Security Database Configuration
```

The design uses batched deployment of ASIM parsers to overcome template size limitations while maintaining deployment reliability.

## Key Components

### Azure Data Explorer Cluster

Defined in `modules/cluster.bicep`, this component provisions:

- ADX Cluster with specified SKU and capacity
- System-assigned managed identity
- Security database with ReadWrite access

### ASIM Parser Deployment

The ASIM parsers are split across multiple batch modules:

- `asim-batch1.bicep`: Authentication and Audit parsers
- `asim-batch2.bicep`: Network and DNS parsers
- `asim-batch3.bicep`: Process and File parsers
- `asim-batch4.bicep`: Registry and DHCP parsers
- `asim-batch5.bicep`: Web and other specialized parsers

Each batch references the corresponding ASIM*.kql scripts for the actual parser definitions.

### Security Database Configuration

The `securitydb*.kql` scripts define:

- Table schemas for various security log types
- Ingestion mappings for raw data
- Functions for data expansion
- Update policies for automated processing

## Deployment Parameters

Configuration parameters are defined in `parameters.json`:

| Parameter            | Description   | Default              | Notes                                    |
| -------------------- | ------------- | -------------------- | ---------------------------------------- |
| location             | Azure region  | australiasoutheast   | Choose a region close to your operations |
| ADXClusterName       | Cluster name  | adx-security-cluster | Must be globally unique                  |
| skuName              | VM SKU        | Standard_D12_v2      | Defines compute capabilities             |
| skutier              | Pricing tier  | Standard             | Standard tier recommended                |
| skuCapacity          | Node count    | 2                    | Scale based on data volume               |
| securitydatabaseName | Database name | security             | Name for the security database           |

## Deployment Process

The deployment is orchestrated by the `deploy.ps1` script, which:

1. Authenticates to Azure
2. Creates the resource group if it doesn't exist
3. Deploys the main Bicep template
4. Handles error reporting and validation

The deployment sequence is controlled in `main.bicep` to ensure proper dependency management:

1. ADX Cluster deployment
2. ASIM parser batch 1
3. ASIM parser batch 2
4. ASIM parser batch 3
5. ASIM parser batch 4
6. ASIM parser batch 5
7. Security scripts deployment

## KQL Scripts Overview

### ASIM Parser Scripts (ASIM*.kql)

These scripts define the ASIM parser functions that normalize different log sources to the standard ASIM schema. For example:

- `ASIM1.kql`: Core ASIM parser functions
- `ASIM2.kql` - `ASIM26.kql`: Source-specific parser implementations

### Security Database Scripts (securitydb*.kql)

These scripts define the security database structure:

- `securitydb1.kql`: Core table definitions for AAD, Alert, and ASIM tables
- `securitydb2.kql`: Additional security table definitions
- `securitydb3.kql`: Remaining table definitions and update policies

 

## References

- [Comprehensive Documentation](../docs/README.md)
- [Deployment Guide](../docs/deployment-guide.md)
- [Architecture Overview](../docs/architecture.md)
- [ADX Continuous Export to Blob / Data Lake](https://www.laurierhodes.info/node/158)
- [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176)
