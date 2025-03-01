# Architecture Overview

This document provides a detailed overview of the Azure Data Explorer Security Data Lake architecture, explaining the design decisions, components, and integration patterns.

## Architectural Principles

The architecture of this solution follows several key principles:

1. **Scalability**: Designed to handle petabyte-scale security data volumes
2. **Performance**: Optimized for fast query response even with massive datasets
3. **Cost Efficiency**: Structured to minimize storage and compute costs
4. **Security**: Engineered with security best practices throughout
5. **Integration**: Seamlessly connects with the Microsoft security ecosystem
6. **Standardization**: Aligns with industry standards like ASIM for portability

## High-Level Architecture

The following diagram illustrates the high-level architecture of the Azure Data Explorer Security Data Lake:

```
                                   ┌───────────────────┐
                                   │                   │
                                   │  Azure Data       │
                                   │  Explorer Cluster │
                                   │                   │
                                   └─────────┬─────────┘
                                             │
                                   ┌─────────▼─────────┐
                                   │                   │
                                   │ Security Database │
                                   │                   │
                                   └─────────┬─────────┘
                                             │
                      ┌────────────┬─────────┴─────────┬────────────┐
                      │            │                   │            │
             ┌────────▼─────┐ ┌────▼───────────┐ ┌────▼────┐ ┌─────▼──────┐
             │              │ │                │ │         │ │            │
             │ Raw Tables   │ │ ASIM Parsers   │ │ Policies│ │ Functions  │
             │              │ │                │ │         │ │            │
             └──────────────┘ └────────────────┘ └─────────┘ └────────────┘
                      ▲            ▲                  ▲            ▲
                      │            │                  │            │
┌─────────────────────┴────────────┴──────────────────┴────────────┴───────────────────┐
│                                                                                       │
│                              Data Sources                                             │
│                                                                                       │
│  ┌──────────────┐ ┌───────────────┐ ┌────────────────┐ ┌────────────┐ ┌────────────┐ │
│  │              │ │               │ │                │ │            │ │            │ │
│  │ Log Analytics│ │ Event Hubs    │ │ Azure Storage │ │ Sentinel   │ │ Direct API │ │
│  │              │ │               │ │                │ │            │ │            │ │
│  └──────────────┘ └───────────────┘ └────────────────┘ └────────────┘ └────────────┘ │
│                                                                                       │
└───────────────────────────────────────────────────────────────────────────────────────┘
```

## Core Components

### Azure Data Explorer Cluster

The ADX cluster is the primary infrastructure component that provides:

- Compute resources for data processing and query execution
- Storage for data tables and associated schema
- Query engine for executing KQL queries
- APIs for data ingestion and query execution

### Security Database

The security database within the ADX cluster contains:

- Raw tables for storing original security logs
- Expanded tables with parsed and normalized data
- Functions for data normalization (ASIM parsers)
- Update policies for automated data transformation
- Retention policies for data lifecycle management

Database configuration:

- Read/Write access mode
- Automated schema creation
- Optimized retention settings

### ASIM Parsers

The ASIM (Advanced Security Information Model) parsers are KQL functions that:

- Normalize security data from different sources
- Apply consistent field naming conventions
- Standardize data types and formats
- Enable cross-source analysis and correlation
- Align with Microsoft Sentinel's normalization schema

Parsers included:

- Authentication events
- Network sessions
- DNS activities
- Process events
- File events
- Audit events
- DHCP events
- Registry operations

### Table Schema

The table schema is designed for security data optimization:

- Efficient column data types to minimize storage
- Strategic column selection for commonly queried fields
- Optimized for high-volume, high-cardinality security data
- Aligned with ASIM schema for normalized analysis

## Deployment Architecture

The deployment process follows a modular approach:

```
┌───────────────────┐
│                   │
│ Main Bicep        │
│ Template          │
│                   │
└────────┬──────────┘
         │
         ▼
┌────────────────────┐
│                    │
│ Cluster Module     │
│                    │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│                    │
│ Security Database  │
│                    │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│                    │
│ ASIM Parser        │
│ Batches (1-5)      │
│                    │
└────────┬───────────┘
         │
         ▼
┌────────────────────┐
│                    │
│ Security Scripts   │
│                    │
└────────────────────┘
```

The deployment architecture intentionally:

1. Creates resources in the correct dependency order
2. Breaks ASIM parsers into manageable batches to avoid template size limits
3. Uses system-assigned managed identity for security
4. Employs parameter files for flexible configuration

## Data Flow Architecture

The typical data flow through the system follows this pattern:

1. **Ingestion**: Security data from various sources enters the system
2. **Storage**: Raw data is stored in source-specific raw tables
3. **Expansion**: Update policies populate expanded normalized tables
4. **Query**: Users access normalized data through KQL queries
5. **Retention**: Data is managed according to retention policies

```
┌──────────┐    ┌───────────┐   ┌────────────┐
│          │    │           │   │            │
│ Ingestion├───►│ Raw Tables├──►│ Expanded   │
│          │    │           │   │ Tables     │
└──────────┘    └───────────┘   └──────┬─────┘
                                       │
  ┌─────────────────────┐              │
  │                     │              │
  │ User Queries/Access │◄─────────────┘
  │                     │
  └─────────────────────┘
```

## Security Architecture

The security architecture for Azure Data offers several layers of protection:

1. **Identity**: System-assigned managed identities for secure authentication
2. **Network**: Configurable private endpoints for network isolation
3. **Data**: Column-level security and row-level security options
4. **Access Control**: Role-based access control for data and resources
5. **Monitoring**: Activity logs and diagnostic settings for security visibility

## Integration Architecture

The solution should be considered for integratation with multiple security systems:

1. **Microsoft Sentinel**: For security alerting 
2. **Log Analytics**: For data source integration (via Event Hubs)
3. **Event Hubs**: For real-time data ingestion

## Further Reading

For more detailed information about specific aspects of the architecture:

- [Deployment Guide](./deployment-guide.md) - For deployment architecture details
- [Schema Documentation](./schema.md) - For data architecture details
- [Performance Optimization](./performance.md) - For performance architecture
- [Security Integration](./security-integration.md) - For integration patterns

## References

- [Azure Data Explorer Architecture](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/concepts/)
- [ASIM Parser Architecture](https://docs.microsoft.com/en-us/azure/sentinel/normalization)
- [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166)
