**Database Query (DatabaseSenderSetting)**

## Introduction

The Database Sender is a core activity in the Integration Soup (HL7 Soup) platform, enabling workflows to interact with databases by executing SQL queries. It is configured exclusively through the `DatabaseSenderSetting` class, which defines the connection details, query structure, parameters, and response handling. This setting is serialized directly into workflow files (JSON or XML) and controls the activity’s behavior at runtime.

### Purpose
- **Primary Function**: Executes SQL queries (SELECT, INSERT, UPDATE, DELETE, or stored procedures via CommandType.Text) against a wide range of databases as part of any integration workflow.
- **Integration Context**: Ideal for healthcare integrations (e.g., HL7/FHIR workflows that query patient records or log events) and any data-driven process. Parameters bind dynamically from workflow variables or fields in messages from other activities, and results (when requested) become a CSV message for downstream use.
- **Key Features**:
  - Broad database provider support: SQL Server (modern & legacy), Oracle, MySQL, PostgreSQL, SQLite, OLE DB, and ODBC.
  - Fully parameterized queries for security and flexibility.
  - Variable substitution in connection strings, SQL templates, and parameter values.
  - Optional first-row response as CSV (with base64 for binary columns).
  - Provider-aware parameter naming (e.g., `@` or `:` prefixes).
  - Config-file connection strings for environment portability.
- **Platform Notes**: Fully supported in the visual workflow designer with live validation, auto-detection of parameters from SQL text, and provider-specific UI hints. Official tutorials on integrationsoup.com demonstrate common patterns with SQL Server, while the same configuration works unchanged for MySQL, PostgreSQL, SQLite, and Oracle.

This documentation covers only the public `DatabaseSenderSetting` and its properties, with functionality derived from how the platform processes the setting.

## Functionality Enabled by DatabaseSenderSetting

The setting tells the platform exactly how to connect, what SQL to run, which values to bind, and whether to return data. At runtime the platform:

- Resolves the connection string (with variables and `config=` support).
- Builds a provider-specific connection and command.
- Substitutes variables in the SQL template.
- Adds parameters with values from variables, HL7 paths, XPath, JSONPath, CSV paths, or literals (with optional formatting).
- Executes the query.
- For queries that return rows, formats the first row as a quoted CSV string (binary fields automatically base64-encoded).
- Logs the executed SQL + parameter values and any response.
- Makes the response available as a CSV message for transformers or later activities.

**Security**: Parameterization prevents SQL injection. Use integrated security or config-based strings to keep credentials out of workflows.

**Provider-Specific Notes**:
- Parameter prefix: `@` for SQL Server, MySQL, PostgreSQL, SQLite, OLE DB, ODBC; `:` for Oracle.
- Oracle automatically sets BindByName=true for named parameters.
- All providers support the same `ResponseNotAvailable` and CSV-response logic.

## DatabaseSenderSetting Properties

Properties are serialized to JSON (enums as numeric values).

| Property                  | Type                          | Description                                                                 | Default          | Notes |
|---------------------------|-------------------------------|-----------------------------------------------------------------------------|------------------|-------|
| **ConnectionString**      | string                        | Full connection string. Supports `${Variable}` substitution and `config=Name` lookup from app.config/web.config. | ""               | Required. UI validates common placeholder examples. |
| **DataProvider**          | DataProviders (enum)          | Database provider. Numeric in JSON: 0=SqlClient, 1=OracleClient, 2=OleDb, 3=Odbc, 4=SqlClientOld, 5=MySql, 6=PostgreSql, 7=Sqlite. | SqlClient (0)    | Determines connection/command/parameter factories and parameter prefix. |
| **Parameters**            | List<DatabaseSettingParameter>| SQL parameters for the query (see table below).                             | Empty list       | Ordered alphabetically in UI. |
| **MessageTemplate**       | string                        | SQL query. Supports `${Var}` and full-message bindings (`${ActivityGuid Inbound}`). | ""               | Required. MessageType must be SQL (13). |
| **ResponseMessageTemplate**| string                       | Comma-separated column names for the response (no spaces). Example: `PatientId,LastName,FirstName,DOB` | ""               | Only used when ResponseNotAvailable = false. |
| **ResponseMessageType**   | MessageTypes (enum)           | Response type (5 = CSV).                                                    | CSV (5)          | Fixed for database responses. |
| **ResponseNotAvailable**  | bool                          | true = no response expected (INSERT/UPDATE); false = return first row as CSV. | true             | Set false for SELECT queries. |
| **MessageType**           | MessageTypes (enum)           | Outbound type (13 = SQL).                                                   | SQL (13)         | Fixed. |
| **InboundMessageNotAvailable** | bool (read-only)         | Always true – use parameters instead of direct inbound binding.             | true             | Fixed. |
| **DifferentResponseMessageType** | bool (read-only)      | Always true – response is CSV, not SQL.                                     | true             | Fixed. |
| **Id**                    | Guid                          | Unique activity identifier in the workflow.                                 | Generated        | Used in bindings and references. |
| **Name**                  | string                        | Display name in designer.                                                   | "Database Query" | Customizable, e.g., “Log HL7 to MySQL”. |
| **Filters**               | Guid                          | Associated filters (workflow-specific).                                     | N/A              | — |
| **Transformers**          | Guid                          | Associated transformers.                                                    | N/A              | Applied before/after query. |

### DatabaseSettingParameter Properties
Each parameter in the `Parameters` list.

| Property           | Type                    | Description                                                                 | Default     | Notes |
|--------------------|-------------------------|-----------------------------------------------------------------------------|-------------|-------|
| **Name**           | string                  | Parameter name with provider prefix (e.g., `@PatientID` or `:PatientID`).   | ""          | Required; UI auto-detects from SQL. |
| **Value**          | string                  | Source: `${Variable}`, path (HL7, XPath, etc.), or literal.                 | ""          | Resolved at runtime. |
| **FromType**       | MessageTypes (enum)     | 8=TextWithVariables, 9=HL7V2Path, 10=XPath, 11=CSVPath, 12=JSONPath.        | 8           | Numeric in JSON. |
| **FromDirection**  | MessageSourceDirection (enum) | 0=inbound, 1=outbound, 2=variable.                                      | 2           | Numeric in JSON. |
| **FromSetting**    | Guid                    | Source activity GUID (omit for variables/literals).                         | Empty       | — |
| **Encoding**       | Encodings (enum)        | Optional (e.g., Base64).                                                    | None        | — |
| **TextFormat**     | TextFormats (enum)      | Optional (e.g., UpperCase).                                                 | None        | — |
| **Truncation**     | Truncation (enum)       | Optional (e.g., Trim).                                                      | None        | Use with TruncationLength. |
| **TruncationLength**| int                     | Length limit for truncation.                                                | 50          | — |
| **PaddingLength**  | int                     | Padding length.                                                             | 0           | — |
| **Replace** / **ReplaceWith** | string               | Find/replace in value.                                                      | ""          | — |
| **Remove**         | string                  | String to remove.                                                           | ""          | — |
| **Lookup**         | string                  | Lookup table key.                                                           | ""          | — |
| **Format**         | string                  | .NET format string (e.g., `yyyy-MM-dd`).                                    | ""          | — |

## Workflow File Definition Example

```json
{
  "Activities": [
    {
      "Id": "12345678-1234-1234-1234-123456789abc",
      "Name": "Query Patient in PostgreSQL",
      "Type": "DatabaseSender",
      "ConnectionString": "Host=localhost;Database=healthdb;Username=myuser;Password=mypass;",
      "DataProvider": 6,               // PostgreSql
      "MessageTemplate": "SELECT patient_id, last_name, first_name FROM patients WHERE mrn = @MRN",
      "MessageType": 13,
      "ResponseMessageTemplate": "patient_id,last_name,first_name",
      "ResponseMessageType": 5,
      "ResponseNotAvailable": false,
      "Parameters": [
        {
          "Name": "@MRN",
          "Value": "PID-3.1",
          "FromType": 9,
          "FromDirection": 0,
          "FromSetting": "87654321-4321-4321-4321-87654321dcba"
        }
      ]
    }
  ]
}
```

## Common Usage Examples

1. **HL7 Trigger → MySQL Lookup**  
   Inbound ADT message → query patient demographics.  
   `DataProvider`: 5 (MySQL)  
   `MessageTemplate`: `SELECT * FROM patients WHERE mrn = @MRN`  
   Parameter: `@MRN` bound to `PID-3.1` (HL7 path)  
   `ResponseNotAvailable`: false → CSV response for next transformer.

2. **FHIR → PostgreSQL Insert**  
   Inbound JSON resource → audit log insert.  
   `DataProvider`: 6 (PostgreSql)  
   `MessageTemplate`: `INSERT INTO audit (event, timestamp) VALUES (@Event, @Ts)`  
   Parameters use JSONPath and `${Now}` variable.

3. **SQLite Local Cache**  
   Lightweight local database for offline processing.  
   `ConnectionString`: `Data Source=cache.db;`  
   `DataProvider`: 7 (Sqlite)  
   Simple INSERT/SELECT with variable bindings.

4. **Oracle Enterprise Query**  
   Legacy EHR system.  
   `DataProvider`: 1 (OracleClient)  
   Parameters use `:ParamName` (UI automatically shows `:`).  
   Connection: `Data Source=orcl;User Id=...;Password=...;`

5. **Bulk Logging via OLE DB / ODBC**  
   Connect to any ODBC data source (Excel, Access, legacy systems) using the same parameter and response model.

These patterns are used daily in production HL7 Soup workflows and are fully supported in the visual designer with live connection testing and parameter auto-detection.

## Additional Resources
- Official Help: [integrationsoup.com/help/database-sender](https://www.integrationsoup.com/help/database-sender)
- Video Tutorials: Search “HL7 Soup Database Sender” on YouTube (covers binding, responses, and common patterns).

This is the definitive, up-to-date reference for the Database Sender based on the current `DatabaseSenderSetting`.