# Security Integration Guide

This guide covers integrating various security data sources with the Azure Data Explorer (ADX) Security Data Lake solution. It provides detailed information on configuring data connectors, transformation pipelines, and ensuring proper schema alignment.

## Integration Overview

The ADX Security Data Lake is designed to ingest security data from multiple sources. This integration provides:

- Centralized collection of security telemetry
- Long-term data retention capabilities
- High-performance query access on vast amounts of data.

## Supported Data Sources

This example solution supports the following data source types:

### Microsoft Sources

| Data Source                     | Integration Method     | Schema                                      |
| ------------------------------- | ---------------------- | ------------------------------------------- |
| Microsoft Sentinel              | Direct Query or Export | Multiple ASIM schemas                       |
| Microsoft Defender for Endpoint | Log Analytics Export   | Process Events, File Events, Network Events |
| Microsoft Defender for Cloud    | Log Analytics Export   | Security Alerts, Security Assessments       |
| Azure Active Directory          | REST API, Event Hub    | Authentication Events                       |
| Azure Activity Logs             | Event Hub, Export      | Audit Events                                |
| Microsoft 365                   | Log Analytics Export   | Email Events, Identity Events               |

### Third-Party Sources

Any number of new sources may be incorporated into the Security Data Warehouse.  The preferred ingestion method is through Azure Event Hubs and may typicxally use Azure Function Apps for retrieving data.





## References

- [Azure Data Explorer Data Ingestion Overview](https://docs.microsoft.com/en-us/azure/data-explorer/ingest-data-overview)
- [Microsoft Sentinel Normalization Schema](https://docs.microsoft.com/en-us/azure/sentinel/normalization-schema)
- [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166)
- [ADX Continuous Export to Blob / Data Lake](https://www.laurierhodes.info/node/158)
