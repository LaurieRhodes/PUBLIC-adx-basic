# Schema Documentation

This document provides detailed information about the data schemas used in the Azure Data Explorer Security Data Lake solution. Understanding these schemas is crucial for effective data ingestion, querying, and analysis.

## Schema Design Philosophy

The schema design for this security data lake follows several key principles:

1. **Normalization**: Common fields across different log sources are normalized to standard names
2. **Efficiency**: Data types are chosen to minimize storage requirements
3. **Performance**: Schema optimized for common security query patterns
4. **Compatibility**: Aligned with industry standards like ASIM
5. **Flexibility**: Accommodates both raw and normalized data structures

## Schema Components

The schema consists of three main components:

### 1. Raw Tables

Raw tables store the original, unmodified security log data as it arrives. These tables:

- Preserve all original fields and values
- Use a dynamic schema to accommodate different log formats
- Serve as the source of truth for data lineage
- Support direct querying when needed

### 2. Expanded Tables

Expanded tables contain normalized and enriched data derived from raw tables. These tables:

- Apply standardized field names and data types
- Extract relevant security information into dedicated columns
- Optimize storage and query performance
- Follow the ASIM schema conventions

### 3. ASIM Parsers

ASIM parsers are KQL functions that transform raw data into normalized format. These parsers:

- Map source-specific fields to standard ASIM fields
- Validate and convert data types
- Apply business logic for field normalization
- Generate expanded tables via update policies

## Advanced Security Information Model (ASIM)

This solution fully implements Microsoft's Advanced Security Information Model (ASIM), which provides:

- Standardized field naming conventions
- Consistent data types and formats
- Normalized schemas across security log sources
- Compatibility with Microsoft Sentinel analytics

### ASIM Schema Categories

The ASIM parsers in this solution cover these core event categories:

| Schema Category | Description | Table Name |
|-----------------|-------------|------------|
| Authentication | User and service authentication events | ASimAuthenticationEventLogs |
| Audit | System and application audit events | ASimAuditEventLogs |
| DNS | DNS queries and responses | ASimDnsActivityLogs |
| File | File creation, modification, and deletion | ASimFileEventLogs |
| Network | Network connection and session data | ASimNetworkSessionLogs |
| Process | Process creation and termination | ASimProcessEventLogs |
| Registry | Registry modifications | ASimRegistryEventLogs |
| DHCP | DHCP lease events | ASimDhcpEventLogs |
| Web | Web session activities | ASimWebSessionLogs |

## Schema Structure

### Common Fields

The following fields are common across ASIM schemas:

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| TimeGenerated | datetime | Time when event was generated | 2023-01-15T08:23:15.123Z |
| EventProduct | string | Product that generated the event | "Microsoft Defender for Endpoint" |
| EventVendor | string | Vendor of the product | "Microsoft" |
| EventType | string | Type of event (normalized) | "Process" |
| EventResult | string | Outcome of the event | "Success" |
| EventSeverity | string | Severity level | "Informational" |
| DvcHostname | string | Device hostname | "workstation01.contoso.com" |
| DvcIpAddr | string | Device IP address | "10.1.2.3" |
| EventOriginalUid | string | Original event ID | "0x8d00e12a55" |

### Schema-Specific Fields

Each ASIM schema category includes specialized fields relevant to its domain. For example:

#### Authentication Events

```
ASimAuthenticationEventLogs
| where TimeGenerated > ago(1d)
| project
    TimeGenerated,
    TargetUsername,   // The user being authenticated
    TargetUsernameType,  // Type of username (UPN, email, etc.)
    SrcIpAddr,        // Source IP of authentication attempt
    EventResult,      // Success or Failure
    LogonMethod,      // Authentication method used
    EventResultDetails  // Detailed result information
```

#### Process Events

```
ASimProcessEventLogs
| where TimeGenerated > ago(1d)
| project
    TimeGenerated,
    ActingProcessName,    // Process name
    ActingProcessId,      // Process ID
    ActingProcessCommandLine,  // Command line
    ActorUsername,        // User who executed the process
    TargetProcessName,    // Target process (if applicable)
    ParentProcessName     // Parent process name
```

## Table Schemas

### Raw Tables

Raw tables use a standardized naming convention with "Raw" suffix:

```kql
.create table AADSignInLogsRaw (records:dynamic)
```

These tables typically have a simple schema with dynamic columns to accommodate varying input formats.

### Expanded Tables

Expanded tables follow the ASIM naming convention:

```kql
.create table ASimAuthenticationEventLogs(
    TenantId:string,
    TimeGenerated:datetime,
    EventProduct:string,
    EventVendor:string,
    EventType:string,
    EventResult:string,
    TargetUsername:string,
    TargetUserId:string,
    SrcIpAddr:string,
    LogonMethod:string,
    EventResultDetails:string,
    // Additional fields as defined in ASIM schema
)
```

## Update Policies

Update policies automatically transform data from raw to expanded tables using ASIM parsers:

```kql
.alter table ASimAuthenticationEventLogs policy update 
@'[{
    "Source": "AADSignInLogsRaw", 
    "Query": "ASimAuthenticationEventLogsExpand()", 
    "IsEnabled": "True",
    "IsTransactional": true
}]'
```

## Working with Schema

### Querying Normalized Data

To query normalized data, use the ASIM tables directly:

```kql
ASimAuthenticationEventLogs
| where TimeGenerated > ago(1d)
| where EventResult == "Failure"
| summarize FailureCount=count() by SrcIpAddr, TargetUsername
| order by FailureCount desc
```

### Cross-Source Correlation

ASIM schemas enable seamless correlation across different data sources:

```kql
// Find a failed authentication followed by a successful one from the same IP
let failures = ASimAuthenticationEventLogs
| where TimeGenerated > ago(1d)
| where EventResult == "Failure";

let successes = ASimAuthenticationEventLogs
| where TimeGenerated > ago(1d)
| where EventResult == "Success";

failures
| join kind=inner successes on SrcIpAddr, TargetUsername
| where failures.TimeGenerated < successes.TimeGenerated
| project
    FailureTime = failures.TimeGenerated,
    SuccessTime = successes.TimeGenerated,
    TimeDelta = successes.TimeGenerated - failures.TimeGenerated,
    TargetUsername,
    SrcIpAddr
| where TimeDelta between (0min .. 30min)
```

### Extending the Schema

To extend the schema for custom needs:

1. Create a new table that includes the ASIM base fields
2. Add additional fields specific to your requirements
3. Create update policies or direct ingestion methods

Example:

```kql
.create table CustomAuthenticationLogs (
    // Include all ASIM Authentication fields
    TenantId:string,
    TimeGenerated:datetime,
    // Add custom fields
    CustomField1:string,
    CustomField2:int
)
```

## Schema Management

### Schema Versioning

The ASIM schema follows versioning conventions:

```kql
// In ASIM parsers
EventSchemaVersion = "0.1.0"
```

When the schema changes:
- Major version changes indicate breaking changes
- Minor version changes indicate non-breaking additions
- Patch version changes indicate bug fixes

### Schema Documentation

Schema is documented in multiple locations:

1. KQL files in the repository
2. Comments within the code
3. This schema documentation

## References

- [ASIM Schema Documentation](https://docs.microsoft.com/en-us/azure/sentinel/normalization-schema)
- [Azure Data Explorer Schema Best Practices](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/best-practices)
- [Deriving the Log Analytics Table Schema](https://laurierhodes.info/node/161)
