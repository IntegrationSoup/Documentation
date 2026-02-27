# Database Query (DatabaseSenderSetting)

## Activity role and how data moves through it

The Database Query activity is a **Sender** that executes a SQL statement against a configured database connection. Conceptually it behaves like:

1. **Build outbound message text** from `MessageTemplate` (including variable expansion and any configured transformers).
2. **Execute the SQL** using the selected `DataProvider` and `ConnectionString`.
3. **Bind SQL parameters** from workflow variables and/or from other activities’ messages using `Parameters`.
4. Optionally **return a response message** (as a CSV message) when `ResponseNotAvailable` is `false`.

A database query is *always executed as plain text SQL* (`CommandType.Text`). This matters for:
- Stored procedures (you must call them via text for your provider, e.g. `EXEC ...`, `CALL ...`).
- Multi-statement batches (provider-dependent, may or may not work).
- Multiple result sets (only the first result set is considered, and only the first row is read; see pitfalls).

The activity is effectively a “database command runner” whose outgoing “message” is the SQL itself. In practice, AI agents and JSON authors should treat the outbound message as the **final SQL string** that will be sent to the database.

## Serialized JSON contract for DatabaseSenderSetting

This section describes the **JSON shape** that corresponds to the serialized `DatabaseSenderSetting` in a workflow file. Property names match the C# property names (PascalCase).

### Canonical JSON shape

```json
{
  "Id": "00000000-0000-0000-0000-000000000000",
  "Name": "Database Query",
  "Version": 3,

  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",

  "ConnectionString": "config=MyConnectionStringName",
  "DataProvider": 0,

  "MessageTemplate": "SELECT ... WHERE PatientId = @PatientId",
  "MessageType":  /* SQL enum numeric value */  ,

  "Parameters": [
    {
      "Name": "@PatientId",
      "Value": "${PatientId}",
      "FromType": 8,
      "FromDirection": 2,

      "FromSetting": "00000000-0000-0000-0000-000000000000",

      "Encoding": 0,
      "TextFormat": 0,
      "Truncation": 0,
      "TruncationLength": 50,
      "PaddingLength": 0,
      "Lookup": null,
      "Format": null
    }
  ],

  "ResponseNotAvailable": true,

  "ResponseMessageTemplate": "PatientId,LastName,FirstName,DOB",
  "ResponseMessageType": 5
}
```

### Required vs optional keys

What is truly “required” depends on how your workflow loader instantiates settings, but there is a difference between:

- **“Required for correct behavior”** (the safe set AI should always include)
- **“Required only because UI enforces it”** (UI validation rules)
- **“Optional if you rely on defaults”** (constructor defaults)

**Safe-to-include always (recommended for AI-authored JSON):**
- `Id` (GUID string)
- `Name` (string)
- `ConnectionString` (string)
- `DataProvider` (integer enum)
- `MessageTemplate` (string)
- `Parameters` (array; can be empty)
- `ResponseNotAvailable` (boolean)

**Conditionally required:**
- If `ResponseNotAvailable` is `false` (you expect a usable response), then include:
  - `ResponseMessageTemplate` (string)
  - `ResponseMessageType` (must be CSV = `5`)
- If `Parameters[i].FromDirection` is not `2` (variable), include:
  - `Parameters[i].FromSetting` (GUID string)

**Often present in real workflow JSON, but not DatabaseQuery-specific:**
- `Version`
- `Filters`
- `Transformers`

### Notes about defaulting behavior

`DatabaseSenderSetting` sets defaults in its constructor that commonly reduce what you *must* put in JSON:

- `MessageType` defaults to **SQL**
- `ResponseMessageType` defaults to **CSV**
- `ResponseNotAvailable` defaults to `true`
- `Parameters` defaults to `[]`

For AI agents generating JSON, the practical guidance is:
- If your workflow loader calls the constructor and then applies JSON values, omitting `MessageType` and `ResponseMessageType` is typically safe.
- If your workflow loader uses a “raw POCO” populate approach without constructor defaults, you must include them.

Because workflows vary, a “definitive” JSON authoring strategy is: **always include `ResponseNotAvailable`, `DataProvider`, `ConnectionString`, and `MessageTemplate`; include response fields only when you expect a response**.

## DatabaseSenderSetting fields and their functional meaning

### ConnectionString

**Type:** string

This value is processed through workflow variable expansion at runtime, so it can contain `${variables}`.

It also supports a special indirection form:

- If the string starts with `config=` (case-insensitive), the remainder is treated as a **named connection string** that must exist in the running application’s configuration (`<connectionStrings>`). Example:

```json
"ConnectionString": "config=MainDb"
```

Important operational implication: the lookup occurs in the configuration of the **process executing the workflow**. For Integration Host this is usually the server component configuration, not the UI client.

### DataProvider

**Type:** integer enum (`DataProviders`)

Selects both:
- Which DB client library is used (SqlClient vs Oracle vs MySQL vs PostgreSQL vs SQLite, etc.)
- Certain provider-specific behaviors, notably **Oracle parameter normalization** and platform limits (OleDb on non-Windows).

### MessageTemplate

**Type:** string

Contains the SQL command text to execute. The engine will ultimately execute the runtime outbound message text as SQL.

AI guidance:
- Prefer writing SQL with parameters (e.g. `WHERE PatientId = @PatientId`) and supply values through `Parameters`.
- You can embed `${variables}` directly in SQL, but this makes correctness and safety more brittle compared to parameters.

### MessageType

**Type:** integer enum (`MessageTypes`)

For Database Query this should be **SQL**. Many workflows can omit it because the constructor sets it.

### Parameters

**Type:** array of `DatabaseSettingParameter`

Defines SQL parameters and where each value comes from.

This list is used at runtime to:
1. Resolve each param’s value from a variable or another activity’s message
2. Apply formatting rules
3. Add a `DbParameter` to the command

### ResponseNotAvailable

**Type:** boolean

This is the single most important flag for query behavior:

- `true` means “this activity does **not** produce a response message” and the command is executed via `ExecuteNonQuery()`.
- `false` means “this activity produces a response message” and the command is executed via `ExecuteReader()` and the first row becomes the response.

This naming is intentionally inverted (it is not “ReturnResponse”), which is a common source of mistakes for JSON authors. AI agents should treat:

- `ResponseNotAvailable = false` as **“Return a response”**

### ResponseMessageTemplate

**Type:** string

Required by UI when `ResponseNotAvailable` is `false`.

For Database Query, this string represents **the expected result column names** in the order you want to treat them in downstream binding. The UI enforces a strict format:

- Comma-separated
- No spaces
- Example: `"PatientId,LastName,FirstName,DOB"`

Even though the runtime response text is raw CSV values, workflow tooling often relies on this template to interpret CSV paths or to allow bindings by column name.

### ResponseMessageType

**Type:** integer enum (`MessageTypes`)

For Database Query responses, this should be **CSV**, and in JSON it must be:

- `5` = CSV

Only include when `ResponseNotAvailable` is `false` (i.e., you expect a response).

## Parameter binding contract and formatting

Each entry in `Parameters` is a `DatabaseSettingParameter`.

### Canonical parameter object shape

```json
{
  "Name": "@PatientId",
  "Value": "${PatientId}",
  "FromType": 8,
  "FromDirection": 2

  /* FromSetting only when binding to another activity: */
  /* "FromSetting": "22222222-2222-2222-2222-222222222222", */

  /* Optional formatting knobs */
  /* "Encoding": 0, */
  /* "TextFormat": 0, */
  /* "Truncation": 0, */
  /* "TruncationLength": 50, */
  /* "PaddingLength": 0, */
  /* "Lookup": "MyLookupTable", */
  /* "Format": "yyyy-MM-dd" */
}
```

### Name

**Type:** string

The SQL parameter name, including the prefix character used in the SQL query:

- Most providers use `@ParamName`
- Oracle uses `:ParamName` in SQL text

**Oracle-specific nuance:** the runtime logic normalizes Oracle parameter names so that the actual `DbParameter.ParameterName` does **not** include the leading `:`. Therefore:
- In your SQL text: use `:ParamName`
- In JSON `Name`: use `:ParamName`
- The engine will transform it to `ParamName` when creating the parameter object.

If you mistakenly use `@ParamName` with Oracle, you will likely get a parameter mismatch at runtime.

### Value

**Type:** string

Represents either:
- literal text with `${variables}` (when `FromType` indicates text/variables)
- a path expression into the source message (HL7 path, XPath, CSVPath, JSONPath), depending on `FromType`

Examples:
- Variable/literal: `"${PatientId}"`
- HL7 V2 path: `"PID-5.1"`
- XPath: `"/Patient/Name/Family/text()"`
- CSV path: (product-specific CSV path syntax)
- JSON path: (product-specific JSON path syntax)

### FromDirection

**Type:** integer enum (`MessageSourceDirection`)

Defines *where the source value comes from*:

- `0` = inbound (message received by the source setting)
- `1` = outbound (message sent/written by the source setting)
- `2` = variable (workflow variables / literal with variables)

Critical behavior notes:
- If the source setting is a **Receiver**, you normally use `FromDirection = 0` because a receiver’s “outbound” is not meaningful in the same way.
- If the source setting is a **Sender**, `FromDirection = 0` often means “the response we got back”, while `FromDirection = 1` means “the outbound message we sent”.

This distinction matters when the parameter value is sourced from the response of a prior sender (e.g., using an ACK-like response, HTTP response payload, etc.).

### FromSetting

**Type:** GUID string

Required when `FromDirection` is `0` or `1`.

Represents the **activity ID** (GUID) of the setting whose message you’re extracting from.

AI authoring guidance:
- Do not guess GUIDs. Use the actual activity IDs from the workflow.
- If you copy/paste activities and generate new IDs, every `FromSetting` reference must be updated to point at the correct new activity ID, or bindings will silently break.

### FromType

**Type:** integer enum (`MessageTypes` used as “path type” selector)

This field is critical for editing and validation because it tells the system what *kind* of expression is in `Value`.

Supported values for parameters are explicitly constrained to:

- `8` = TextWithVariables
- `9` = HL7V2Path
- `10` = XPath
- `11` = CSVPath
- `12` = JSONPath

Practical rules:
- If `FromType = 8`, then `Value` is treated as literal text and/or `${variables}` (not a path).
- If `FromType != 8`, then `Value` must be a valid path expression for the underlying message type and message content.

### Formatting properties

After a raw value is obtained, the activity applies formatting via a shared formatting engine (`Variable.ProcessFormat(value, param)`).

These formatting properties exist so the workflow can enforce predictable parameter shape before it enters SQL execution, especially for external system requirements like fixed-length identifiers or constrained DB fields.

Common patterns:
- Encode or normalize text before insert
- Upper/lower casing
- Truncation to avoid DB column overflow
- Padding to meet fixed-width requirements
- Lookups (e.g., mapping local codes to external codes)
- Provider-independent formatting (if possible)

Because these are product-specific enums, JSON authors should generally prefer:
- leaving them at defaults unless you have a known requirement
- using them consistently across related parameters so downstream behavior is stable

## Enum reference for JSON authors

All enums serialize as **numbers** in workflow JSON (not strings).

### DataProviders

The numeric values follow enum declaration order:

```json
{
  "DataProviders": {
    "0": "SqlClient",
    "1": "OracleClient",
    "2": "OleDb",
    "3": "Odbc",
    "4": "SqlClientOld",
    "5": "MySql",
    "6": "PostgreSql",
    "7": "Sqlite"
  }
}
```

Operational notes that matter in JSON:
- `SqlClientOld` uses the legacy .NET SQL client (`System.Data.SqlClient`).
- `SqlClient` uses the newer SQL client (`Microsoft.Data.SqlClient`).
- Workflows upgraded from older versions may remap `SqlClient` to `SqlClientOld` during `Upgrade()` when `Version < 3`, so AI agents editing older workflow JSON must not assume that “0 always means old SQL client”.

### MessageSourceDirection

```json
{
  "MessageSourceDirection": {
    "0": "inbound",
    "1": "outbound",
    "2": "variable"
  }
}
```

### MessageTypes values that are explicitly known from this activity

Two distinct uses appear in this activity’s settings:

**Response message type:**
- `5` = CSV (required when returning a response)

**Parameter “FromType” path selector values:**
- `8` = TextWithVariables
- `9` = HL7V2Path
- `10` = XPath
- `11` = CSVPath
- `12` = JSONPath

If you include `MessageType` for the activity itself, it must be the product’s numeric value for **SQL**. Many JSON authors omit it because the activity constructor sets it to SQL automatically.

## Response shaping and consumption rules

When `ResponseNotAvailable` is `false`, the activity:

- Executes the command with `ExecuteReader()`
- Reads **only the first row** (`reader.Read()` once)
- Writes **all fields in that row** into a single CSV row string
- Wraps each field in double quotes and escapes internal quotes (`"` becomes `""`)
- If a field is detected as `byte[]`, it is base64-encoded and quoted in the CSV output

Implications for downstream workflows:
- You cannot directly get multi-row results. If you need multi-row semantics, you must:
  - return a single-row, aggregated representation (JSON, XML, delimited string) from SQL, or
  - redesign to call a stored procedure that returns a single “payload” row, or
  - use a different activity/approach that supports multi-row consumption.
- The response is a **CSV message**, so downstream extraction should use CSV-aware pathing and/or `ResponseMessageTemplate` to attach column meaning.
- If your `SELECT` returns columns in an order that doesn’t match `ResponseMessageTemplate`, bindings may resolve the wrong values without obvious errors (depending on how CSV paths and templates are interpreted downstream).

## Pitfalls and non-obvious outcomes for AI agents and JSON authors

### Only the first row of the first result set is returned
Even if your SQL returns:
- 0 rows: response becomes an empty CSV string
- many rows: only row 1 is returned
- multiple result sets: only the first result set is considered, and only its first row

This is the most common “surprise” when users try to do lookups that might match multiple records.

### Parameters are always bound as strings
Every parameter value is constructed as a string and assigned directly to `DbParameter.Value`.

Consequences that matter in practice:
- Numeric/date comparisons may behave differently than expected if the DB performs implicit conversions.
- Locale-specific date strings can break queries depending on server settings.
- Index usage and query plan stability can be impacted when types are inferred differently by the database.

If you need a non-string type reliably, you typically need to:
- `CAST(@Param AS INT)` / `CONVERT(...)` patterns in SQL (provider-specific), or
- format the string to the database’s expected canonical form (via the parameter formatting properties).

### OleDb is Windows-only in modern runtime contexts
When running on non-Windows environments, attempting to use `DataProvider = OleDb` can throw at runtime.

This matters for Integration Host deployments on Linux containers/servers.

### Oracle parameter prefix handling is special
Oracle uses `:` in query text, but the actual parameter name bound to the command must exclude the leading `:`. The engine normalizes this automatically.

AI agents must still ensure:
- SQL uses `:Param`
- JSON `Name` uses `:Param`

### Parameter ordering may matter for some providers even if names exist
Some drivers (commonly ODBC/OleDb) behave positionally. If a provider binds by position, then:
- The order of parameters in the command’s parameter collection must match placeholder order in the SQL text.

However, the UI code strongly implies parameters may be sorted (e.g., alphabetically) when persisted. If the underlying provider is positional, a workflow that “looks correct” may bind values to the wrong placeholders.

If you must use ODBC/OleDb and your driver is positional:
- Avoid reusing the same parameter placeholder multiple times.
- Ensure the persisted `Parameters` list order matches SQL placeholder order (and verify runtime behavior with logging).

### ResponseMessageTemplate mismatch can cause silent binding errors
UI enforces `ResponseMessageTemplate` formatting for a reason: it’s the schema contract for downstream CSV interpretation.

If the query returns:
- fewer columns than the template lists, downstream field access may read missing values or shift indices.
- more columns than the template lists, downstream field selection might ignore extras or misalign.

### Logging can expose sensitive data
The activity logs:
- The SQL text being executed
- A “Parameters:” block with values (values truncated for logging display, but still present)

In healthcare integrations, this can capture PII/PHI directly into logs if not carefully controlled.

## Examples and patterns

### Insert/update without a response

Use this for writes where downstream activities do not need a DB-returned value.

```json
{
  "Id": "8f65d3f2-6b5f-4d8b-8b02-8b82c4c2b8cb",
  "Name": "Insert Patient",
  "ConnectionString": "config=MainDb",
  "DataProvider": 0,

  "MessageTemplate": "INSERT INTO Patients (PatientId, LastName) VALUES (@PatientId, @LastName)",
  "Parameters": [
    {
      "Name": "@PatientId",
      "Value": "${PatientId}",
      "FromType": 8,
      "FromDirection": 2
    },
    {
      "Name": "@LastName",
      "Value": "PID-5.1",
      "FromType": 9,
      "FromDirection": 0,
      "FromSetting": "22222222-2222-2222-2222-222222222222"
    }
  ],

  "ResponseNotAvailable": true
}
```

### Single-row lookup with response

Use this when you are certain the query returns **at most one row** (or you accept “first row wins”).

```json
{
  "Id": "6c0d3c3c-7b28-4b65-8f73-5a07a8dc1e64",
  "Name": "Lookup Patient",
  "ConnectionString": "config=MainDb",
  "DataProvider": 0,

  "MessageTemplate": "SELECT PatientId, LastName, FirstName FROM Patients WHERE PatientId = @PatientId",
  "Parameters": [
    {
      "Name": "@PatientId",
      "Value": "${PatientId}",
      "FromType": 8,
      "FromDirection": 2
    }
  ],

  "ResponseNotAvailable": false,
  "ResponseMessageTemplate": "PatientId,LastName,FirstName",
  "ResponseMessageType": 5
}
```

### Oracle parameter example

```json
{
  "Id": "b8b2fba2-45b4-49a0-a215-6aa9d4b62c9c",
  "Name": "Oracle Insert",
  "ConnectionString": "config=OracleDb",
  "DataProvider": 1,

  "MessageTemplate": "INSERT INTO PATIENTS (PATIENT_ID) VALUES (:PatientId)",
  "Parameters": [
    {
      "Name": ":PatientId",
      "Value": "${PatientId}",
      "FromType": 8,
      "FromDirection": 2
    }
  ],

  "ResponseNotAvailable": true
}
```

## External resources

- [Send HL7 To a Database With Activities](https://www.integrationsoup.com/hl7tutorialaddpatienttodatabasewithactivities.html)  
- [Integration Soup Tutorials](https://www.integrationsoup.com/tutorials.html)  
- [HL7 Interfacer Blog](https://hl7interfacer.blogspot.com/)