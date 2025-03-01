# ASIM Implementation in Azure Data Explorer

This document provides detailed information about the Advanced Security Information Model (ASIM) implementation in the Azure Data Explorer Security Data Lake solution, with specific references to concepts covered in Laurie Rhodes' blog articles.

## Introduction to ASIM

The Advanced Security Information Model (ASIM) is a standardized schema framework for security events that enables consistent analysis across multiple security data sources. As highlighted in [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176), implementing ASIM in ADX provides several key benefits:

1. Normalized data format across security sources
2. Consistent field naming and data types
3. Simplified cross-source correlation and analysis
4. Compatibility with Microsoft Sentinel detection rules
5. Scalable approach for long-term security data management

## ASIM and ADX

As discussed in [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166), Azure Data Explorer serves as an ideal platform for implementing ASIM because:

> "Storing hundreds of Terabytes or Petabytes in Log Analytics for years isn't a technical option and the costs would be on par with the GDP of a small nation! The only Microsoft technology that meets this security need is Azure Data Explorer - and it's spectacular in this role."

The columnar storage architecture of ADX and its Kusto Query Language (KQL) capabilities align perfectly with ASIM's schema design and the analytical needs of security operations.

## Implementation Architecture

This solution creates a Secutity Data Warehouse in ADX using a standardised structure:

### 1. Raw / Native Tables

Raw tables store original, unmodified security data as it arrives from various sources and "Expand" functions transform this data to standard Azure Monitor scemas.

### 2. ASIM Parser Functions

ASIM parsers are KQL functions that transform raw data into normalized ASIM format:

```kql
.create-or-alter function ASimAuthenticationEventLogsExpand {
    AADSignInLogsRaw
    | mv-expand events = records
    | project
        TimeGenerated = todatetime(events.TimeGenerated),
        EventProduct = tostring("Azure Active Directory"),
        EventVendor = tostring("Microsoft"),
        TargetUsername = tostring(events.properties.userPrincipalName),
        // Additional field mappings
}
```

ASIM Parsers are available directly from Microsoft's Sentinel Github Repo.

These parsers handle:

- Field mapping from source to ASIM format
- Data type conversions
- Normalization logic
- Field extraction and processing

## ASIM Schemas Implemented

This solution includes parsers for the core ASIM schemas:

| Schema         | Purpose           | Example Sources                 |
| -------------- | ----------------- | ------------------------------- |
| Authentication | Auth events       | Azure AD, Windows, SAML, OAuth  |
| Audit          | Admin activities  | Azure Activity, O365, ADFS      |
| DNS            | DNS activity      | DNS logs, network monitors      |
| File           | File operations   | Endpoint security, file servers |
| Network        | Network sessions  | Firewalls, proxies, VPN logs    |
| Process        | Process execution | EDR solutions, Windows events   |
| Registry       | Registry changes  | Endpoint protection, Windows    |
| Web            | Web sessions      | WAF, proxies, web servers       |

## Example: Authentication Schema Implementation

The Authentication schema is implemented following [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176) principles:

## Cross-Source Querying Examples

One of the key benefits of ASIM implementation is the ability to query across different log sources using the same field names and data structures:

```kql
// Find authentication failures across all sources
ASimAuthenticationEventLogs
| where TimeGenerated > ago(1d)
| where EventResult == "Failure"
| summarize FailureCount = count() by SrcIpAddr, TargetUsername, bin(TimeGenerated, 1h)
| where FailureCount > 5
```

This approach enables security analysts to write queries once and apply them to multiple data sources.  Utilising ASIM parsers allows for advanced automation with function apps remotely querying data as described in [Querying ADX with PowerShell and REST](https://laurierhodes.info/node/160). 

## 

## References

- [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176)
- [ADX's Role in Large Data Retention for Security](https://www.laurierhodes.info/node/166)
- [ADX Continuous Export to Blob / Data Lake](https://www.laurierhodes.info/node/158)
- [Deriving the Log Analytics Table Schema](https://laurierhodes.info/node/161)
- [PowerShell - Writing Data Directly to Azure Data Explorer with REST](https://www.laurierhodes.info/node/159)
- [Querying ADX with PowerShell and REST](https://laurierhodes.info/node/160)
- [Microsoft ASIM Schema Documentation](https://docs.microsoft.com/en-us/azure/sentinel/normalization-schema)
