# Security Database Schema Guide

This directory contains the schema definitions for security tables used in the Azure Data Explorer (ADX) Security Data Lake solution. This guide provides information on how to add new tables and extend the schema collection.

## Schema Architecture Overview

The security database schema follows a consistent pattern:

1. **Raw Tables**: Store original data in dynamic format (e.g., `AADSignInLogsRaw`)
2. **Expand Functions**: Transform raw data to normalized format (e.g., `AADSignInLogsExpand`)
3. **Expanded Tables**: Store normalized data with defined schema (e.g., `AADSignInLogs`)
4. **Update Policies**: Automatically populate expanded tables from raw data

This architecture enables:

- Preservation of original data
- Standardized query interface
- Efficient storage and query optimization
- Flexibility for schema evolution

## Adding New Tables and Schemas

Adding a new table to the security database requires several steps:

### 1. Generate Schema from Source System

The most reliable way to generate an accurate schema is to extract it directly from the source system using KQL. The following script (from [Creating ADX Table Schemas](https://www.laurierhodes.info/node/189)) provides a systematic approach:

```kql
// Query to extract a table schema from source system
let aztable = "EmailUrlInfo"; 
table(aztable)
| getschema
| extend Command=strcat(ColumnName, ': ', ColumnType)
| summarize mylist = make_list(Command)
| extend strCommand = tostring(mylist)
| extend strCommand = replace_string(strCommand, '"', '')
| extend strCommand = replace_string(strCommand, '[', '')
| extend strCommand = replace_string(strCommand, ']', '')
// Split the operation into parts to inject the aztable variable value
| extend strCommand = strcat(".create-merge table ", aztable, " (", strCommand, ')')
| project strCommand
```

This script will generate KQL required for the table type.

### 2. Implementing the Schema in ADX

Once you have generated the schema, follow these steps:

1. **Create a KQL Script**: Save the generated code to a new `.kql` file in this directory, using an existing kql file as a template.
2. **Review and Customize**: Adjust field mappings as needed, especially for nested properties

### 3. Working with Array Data - Important Considerations

When creating expand functions, you'll notice these lines in existing kql files:

```kql
//| extend events = records
| mv-expand events = records
```

These lines handle how array data is processed:

- **extend events**: Use when the incoming data has a single object per record
- **mv-expand events**: Use when the incoming data has arrays of objects that need to be expanded

You will need to choose the appropriate option based on your data source:

```kql
// Example with mv-expand (for array data)
.create-or-alter function AADNonInteractiveUserSignInLogsExpand {
  AADNonInteractiveUserSignInLogsRaw
  | mv-expand events = records
  | project
      TimeGenerated = todatetime(events.TimeGenerated),
      // Additional field mappings...
}

// Example with extend (for non-array data)
.create-or-alter function CustomSecurityLogsExpand {
  CustomSecurityLogsRaw
  | extend events = records
  | project
      TimeGenerated = todatetime(events.TimeGenerated),
      // Additional field mappings...
}
```

It's common to need to test both approaches with your specific data source to determine which is correct.

## Manual Work and Iterative Development

> **Important**: Creating effective expand functions requires manual work and iterative refinement.

The expand functions provided in this project are based on best available information and testing, but may need adjustments for your specific data:

1. **Field Mapping**: You may need to adjust field mappings based on the exact format of your data
2. **Type Conversions**: Some fields may require special handling for type conversion
3. **Nested Properties**: Deep nested properties often need custom extraction logic
4. **Array Handling**: Array fields may need specialized handling with `mv-expand`
5. **Data Validation**: Some fields may require validation or default values

As you work with larger datasets and more diverse log sources, you should continuously improve these expand functions to handle edge cases and ensure data quality.

## Microsoft Log Sources

The tables included in this example project are derived from Microsoft products that push logs directly to Azure Data Explorer, including:

- Azure Active Directory (Entra ID) logs
- Microsoft Defender logs
- Microsoft 365 logs

For these sources, the provided schemas should work with minimal modification.

## Log Analytics Export Integration

Tables exported from Log Analytics (Sentinel) generally retain their existing schema, making them relatively straightforward to incorporate:

1. Create a raw table to receive the exported data
2. Create a simple expand function that maps fields 1:1
3. Configure the update policy

The schema should match what you see in Log Analytics for consistent querying.

## Third-Party Integration

For third-party log sources, consult the Microsoft public repository for guidance on schema normalization:

[Azure-Sentinel Solutions Repository](https://github.com/Azure/Azure-Sentinel/tree/master/Solutions)

This repository provides parser examples and schema guidance for many common security products, which can be adapted for use with ADX.

## ASIM Parsers

For advanced integration, Advanced Security Information Model (ASIM) parsers are included in this project.

## Examples

The existing schema files in this directory provide examples of:

- Simple table schemas
- Complex nested property handling
- Array field processing
- Update policy configuration
- Type conversion logic

Use these as templates for your new table schemas.
