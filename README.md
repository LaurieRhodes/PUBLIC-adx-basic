# Azure Data Explorer Security Data Lake

## Overview

This repository provides a complete solution for deploying and configuring an Azure Data Explorer (ADX) cluster designed specifically for security log centralisation, aligned with Microsoft's Advanced Security Information Model (ASIM) schema. The project serves as a reference implementation for organizations seeking to build a scalable, cost-effective security data lake using Azure Data Explorer.

Azure Data Explorer provides an ideal foundation for security data retention with:

- Petabyte-scale data storage capabilities
- High-performance query engine with the Kusto Query Language (KQL)
- Cost-effective long-term data retention mechanisms
- Native integration with the Microsoft security ecosystem
- Advanced compliance and security features

## Key Features

- **Complete IaC Deployment**: Automated deployment using Bicep and PowerShell
- **ASIM Schema Integration**: Full implementation of Microsoft's Advanced Security Information Model
- **Security-Optimized Configuration**: Storage, performance, and security settings tailored for security data
- **Production-Ready**: Engineered for enterprise security operations requirements
- **Extensible Framework**: Easily customizable for specific organizational needs

## Documentation

Detailed documentation for this project can be found in the [docs](./docs/) directory:

- [Getting Started Guide](./docs/getting-started.md)
- [Architecture Overview](./docs/architecture.md)
- [Deployment Guide](./docs/deployment-guide.md)
- [Schema Documentation](./docs/schema.md)
- [Security Integration](./docs/security-integration.md)
- [Performance Optimization](./docs/performance.md)
- [Operational Guide](./docs/operations.md)

## Project Structure

```plaintext
PUBLIC-ADX-Basic/
├── docs/                 # Comprehensive documentation
├── infrastructure/       # Deployment and configuration resources
│   ├── modules/          # Modular Bicep deployment components
│   ├── ASIM*.kql         # ASIM parser function definitions
│   ├── securitydb*.kql   # Security database table definitions
│   ├── main.bicep        # Main deployment template
│   ├── parameters.json   # Deployment parameters
│   └── deploy.ps1        # Deployment automation script
└── schema/               # Schema definitions and utilities
    ├── ASIM/             # Advanced Security Information Model schemas
    └── securitydb/       # Security database schemas
```

## Prerequisites

- Azure Subscription with Contributor permissions
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) (2.40.0+)
- [Bicep CLI](https://docs.microsoft.com/en-us/azure/azure-resource-manager/bicep/install) (0.9.0+)
- [PowerShell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell) (7.0+)
- [Git](https://git-scm.com/) (2.30.0+)

## Quick Start

1. Clone the repository
   
   ```bash
   git clone https://github.com/LaurieRhodes/PUBLIC-adx-basic.git
   cd PUBLIC-adx-basic
   ```

2. Deploy the infrastructure
   
   ```powershell
   cd infrastructure
   .\deploy.ps1 -resourceGroupName "<your resource group name>"
   ```

3. Verify deployment and configure data ingestion as described in the [deployment guide](./docs/deployment-guide.md).

## Related Blog Posts

This project builds on concepts discussed in the following blog posts:

- [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166)
- [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176)
- [ADX Continuous Export to Blob / Data Lake](https://www.laurierhodes.info/node/187)
- [Creating ADX table Schemas](https://www.laurierhodes.info/node/189)
- [PowerShell - Writing Data Directly to Azure Data Explorer with REST](https://www.laurierhodes.info/node/159)
- [Querying ADX with PowerShell and REST](https://laurierhodes.info/node/160)

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

This project is intended as an example for others to start experimenting with ADX data warehouse capabilities and is not intended (at this stage) to be actively developed. If you do wish to collaborate, or have general questions, you can find contact details for me at [https://laurierhodes.info](https://laurierhodes.info/)
