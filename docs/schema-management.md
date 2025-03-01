# Schema Management in ADX Security Data Lake

This document provides an in-depth explanation of the schema management approach used in the Azure Data Explorer (ADX) Security Data Lake solution. It describes the schema architecture, generation process, and best practices for maintaining and extending the schema.

## Schema Architecture

The schema in this solution follows a dual-layer approach:

### 1. Raw Tables

Raw tables store original, unmodified security log data as it arrives from various sources. These tables have a simple schema:

```kql
.create-merge table <LogType>Raw (records:dynamic)
```

This approach offers several advantages:

- Preserves original log format and fields
- Accommodates schema changes without table modifications
- Provides an audit trail of original data
- Enables re-processing if normalization logic changes

### 2. Expanded Tables (Microsoft Azure Monitor Schemas)

Expanded tables contain the normalized, structured version of the data with proper column types:

```kql
.create-merge table <LogType>(
    TimeGenerated:datetime,
    EventType:string,
    SourceIpAddress:string,
    // Additional typed columns
)
```

Benefits of expanded tables:

- Improved query performance through column typing
- Consistent schema for cross-source analysis
- Optimized storage through appropriate data types
- Better integration with visualization and analytics tools

### Transformation Process

The transformation from raw to expanded tables happens through:

1. **Expansion Functions**: KQL functions that parse the raw dynamic data
2. **Update Policies**: Configuration that automatically applies the functions

```kql
.create-or-alter function <LogType>Expand {
    <LogType>Raw
    | mv-expand events = records
    | project
        TimeGenerated = todatetime(events.time),
        EventType = tostring(events.type),
        // Additional field mappings
}

.alter table <LogType> policy update @'[{
    "Source": "<LogType>Raw", 
    "Query": "<LogType>Expand()", 
    "IsEnabled": "True", 
    "IsTransactional": true
}]'
```

## Best Practices for Schema Management

### Adding New Data Sources

To add a new data source, create a folder with the same name as the target table (including _CL if required)_).  Copy an existing kql file as a template.

1. **Create Raw Table Structure**:
   
   ```kql
   .create-merge table NewLogTypeRaw (records:dynamic)
   
   .create-or-alter table NewLogTypeRaw ingestion json mapping 'NewLogTypeRawMapping' 
   '[{"column":"records","Properties":{"path":"$.records"}}]'
   ```

2. **Create a data connector**:

See [Adding data streams to Azure Data Explorer](https://www.laurierhodes.info/node/165) for more details.

Once you start ingesting data you can experiment with expanding a nd projecting data into your desired structure.

3. **Define Expanded Table**:
   
   Where possible, derive the intended table format:
   
   - [Creating ADX table Schemas](https://www.laurierhodes.info/node/154)
   
   ```kql
   .create-merge table NewLogType(
       TimeGenerated:datetime,
       // Data-specific columns
   )
   ```

4. **Experiment with expanding the Raw table data**:

You can experiment with KQL to extract the right column data and values.

```kql
    NewLogTypeRaw
    | take 5
    | mv-expand events = records
    | project
        TimeGenerated = todatetime(events.time),
        // Field mapping
}
```

5. **Create Expansion Function**:
   
   When you are satisfield with the data expansion, wrap the query in a function.
   
   ```kql
   .create-or-alter function NewLogTypeExpand {
       NewLogTypeRaw
       | mv-expand events = records
       | project
           TimeGenerated = todatetime(events.time),
           // Field mapping
   }
   ```

6. **Configure Update Policy**:

```kql
.alter table NewLogType policy update @'[{
    "Source": "NewLogTypeRaw", 
    "Query": "NewLogTypeExpand()", 
    "IsEnabled": "True", 
    "IsTransactional": true
}]'
```

## References

For more information on schema design principles and implementation details, refer to these resources:

- [Creating ADX table Schemas](https://www.laurierhodes.info/node/154)
- [ASIM Integration with Azure Data Explorer](https://laurierhodes.info/node/176)
- [Microsoft ASIM Schema Documentation](https://docs.microsoft.com/en-us/azure/sentinel/normalization-schema)
- [Azure Data Explorer Schema Best Practices](https://docs.microsoft.com/en-us/azure/data-explorer/kusto/management/best-practices)
