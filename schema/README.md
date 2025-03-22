# Schema Directory for Azure Data Explorer Security Data Lake

This directory contains the schemas, parsers, and supporting scripts necessary to create a comprehensive security data lake in Azure Data Explorer (ADX). The schemas are designed to align with Microsoft's Advanced Security Information Model (ASIM) for normalized security log analysis.

## Directory Structure

```
schema/
├── ASIM/                # Advanced Security Information Model parsers
│   ├── dependency/      # Parser dependencies
│   ├── functions/       # Helper functions
│   ├── Parsers/         # Source-specific parsers
│   │   ├── ASimAuditEvent/           # Audit event parsers
│   │   ├── ASimAuthentication/       # Authentication event parsers
│   │   ├── ASimDhcpEvent/            # DHCP event parsers
│   │   ├── ASimDns/                  # DNS activity parsers
│   │   ├── ASimFileEvent/            # File event parsers
│   │   ├── ASimNetworkSession/       # Network session parsers
│   │   ├── ASimProcessEvent/         # Process event parsers
│   │   ├── ASimRegistryEvent/        # Registry event parsers
│   │   ├── ASimUserManagement/       # User management parsers
│   │   └── ASimWebSession/           # Web session parsers
│   └── ASIM*.kql        # Consolidated ASIM parser files
├── securitydb/          # Security database table definitions
│   ├── AADManagedIdentitySignInLogs/  # AAD Managed Identity Sign In table schema
│   ├── AADNonInteractiveUserSignInLogs/ # AAD Non-Interactive Sign In table schema
│   ├── ...              # Other security log table schemas
│   └── securitydb*.kql  # Consolidated security table scripts
├── CreateASIMSchema.ps1 # Script to generate consolidated ASIM parser files
└── CreateTableSchema.ps1 # Script to generate consolidated security table files
```

## Overview

This schema repository serves several important purposes:

1. **Table Definitions**: Provides standardized table structures for security logs
2. **ASIM Parsers**: Includes normalizers for consistent security data schema
3. **Schema Generation**: Offers automation for deployment-ready KQL scripts

## ASIM Parsers

The Advanced Security Information Model (ASIM) parsers normalise security logs from various sources into a consistent schema, enabling cross-source correlation and analysis. Each parser converts source-specific data into standardised fields according to the ASIM schema.

Key aspects of ASIM parsers:

- **Normalization**: Standard field names across sources
- **Type Conversion**: Consistent data types
- **Correlation**: Common schema for cross-source analysis
- **Compatibility**: Alignment with Microsoft Sentinel's detection rules

Example of an ASIM parser:

```kql
.create-or-alter function ASimAuthentication(disabled:bool=False) {
    let DisabledParsers=...
    union isfuzzy=true
        vimAuthenticationEmpty,    
        ASimAuthenticationAADSigninLogs(...),
        ASimAuthenticationMicrosoftWindowsEvent(...),
        ...
}
```

## Security Database Tables

The `securitydb` directory contains table definitions for various security log types, structured to optimize storage and query performance in Azure Data Explorer.

Each security log type includes:

1. **Raw Table**: Stores original data in dynamic format
2. **Mapping**: JSON mapping for ingestion
3. **Expanded Table**: Structured table with typed columns
4. **Expansion Function**: KQL function to transform raw to expanded format
5. **Update Policy**: Configuration for automatic transformation

Example table structure:

```kql
.create-merge table AADManagedIdentitySignInLogsRaw (records:dynamic)

.create-or-alter table AADManagedIdentitySignInLogsRaw ingestion json mapping 'AADManagedIdentitySignInLogsRawMapping' '[{"column":"records","Properties":{"path":"$.records"}}]'

.create-merge table AADManagedIdentitySignInLogs(
    TenantId:string,
    TimeGenerated:datetime,
    ...
)
```

## Schema Generation Scripts

Two PowerShell scripts automate the generation of deployment-ready KQL files:

### `CreateASIMSchema.ps1`

This script processes ASIM parser files from subdirectories and creates consolidated output files (ASIM1.kql, ASIM2.kql, etc.) that are suitable for ADX deployment. The script:

1. Recursively traverses the ASIM directory structure
2. Reads individual KQL parser files
3. Combines them into larger files within a character limit (110,000 chars)
4. Maintains the logical organization of parsers

### `CreateTableSchema.ps1`

Similar to the ASIM script, this one processes security database table definitions and creates consolidated output files (securitydb1.kql, securitydb2.kql, etc.) that are suitable for ADX deployment. The script:

1. Recursively traverses the securitydb directory structure
2. Reads individual KQL table definition files
3. Combines them into larger files within a character limit (110,000 chars)
4. Ensures proper sequencing of table creation commands

## Usage

The schema generation scripts are designed to be run as part of a deployment pipeline or manually before deployment:

```powershell
# Generate consolidated ASIM parser files
./CreateASIMSchema.ps1

# Generate consolidated security table files
./CreateTableSchema.ps1
```

The outputs of these scripts are referenced by the deployment templates in the `infrastructure` directory.

## Extending the Schema

To add a new log source for your security database:

1. Create a directory under `securitydb` with the table name
2. Add a `kqlcommands.kql` file with the table definition
3. Run `CreateTableSchema.ps1` to update the consolidated files

To add a new ASIM parser:

1. Add the parser file to the appropriate subdirectory under `ASIM/Parsers`
2. Run `CreateASIMSchema.ps1` to update the consolidated files



# 



## Deployment Considerations

The consolidated KQL files are designed to work around ADX deployment limitations:

- **Size Limits**: ADX has limits on command and script sizes
- **Sequencing**: Tables must be created before policies are applied
- **Dependencies**: Parsers may depend on other parsers or functions

The batching approach in these scripts ensures reliable deployment by:

- Limiting file sizes to below ADX thresholds
- Preserving correct command ordering
- Handling dependencies appropriately

## References

- [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176)
- [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166)
- [Creating ADX table Schemas for Defender, Entra and Microsoft Sentinel](https://www.laurierhodes.info/node/189)
- [Microsoft ASIM Schema Documentation](https://docs.microsoft.com/en-us/azure/sentinel/normalization-schema)
