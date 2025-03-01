# ADX Database Configuration

This document describes the database tables and configurations that are created as part of the ADX cluster deployment.

## Database Overview

The deployment creates a security-focused database with multiple tables designed to store and analyze various security logs and events from Azure and other sources.

KQL files are generated from the schema folder of this project which is designed to be added to as different tables are added to this project.

## Table Structure

### Table Structure Pattern

Each log type follows a consistent pattern:

1. Raw Table (`*Raw`)
   
   - Contains a single column `records` of type `dynamic`
   - Used for initial data ingestion
   - Has a JSON mapping for data ingestion

2. Processed Table
   
   - Contains properly typed columns
   - Receives data from the raw table through an update policy
   - Includes standardized fields like:
     - TenantId
     - TimeGenerated
     - Type
     - SourceSystem
     - Resource information

3. Processing Function
   
   - Named `*Expand`
   - Transforms data from raw to processed format
   - Handles data type conversion
   - Applies business logic where needed

## Data Processing Flow

1. Data is first ingested into the raw tables using JSON mapping
2. Update policies automatically process the raw data using the Expand functions
3. Processed data is stored in the main tables with proper column types
4. All transformations are transactional to ensure data consistency

## Schema Conventions

All tables follow these conventions:

1. Timestamp fields use `datetime` type
2. IDs and names use `string` type
3. Numeric metrics use appropriate numeric types (`int`, `long`, `real`)
4. Boolean flags use `bool` type
5. Complex data structures use `dynamic` type
6. Consistent naming for common fields across tables

## Important Notes

1. All tables have update policies enabled
2. Raw tables are optimized for ingestion
3. Processed tables are optimized for querying