# HTTP Sender (HttpSenderSetting)

## Executive summary

The **HTTP Sender** activity (`HttpSenderSetting`) transmits the workflow’s current message content to an HTTP endpoint. It is configured with a **URL**, **HTTP method** (GET/POST/PUT/DELETE), **Content-Type**, optional **authentication/certificates/proxy**, and optional custom **headers**. In two-way mode, the HTTP response is captured and returned as the activity’s response message; in one-way mode, the response body is discarded (though the call still blocks). 

This guide focuses *solely on JSON-level configuration*: the properties persisted in workflow JSON and their intended effects. It avoids implementation details. 

## Assumptions & conventions

- We assume the serializer follows **System.Text.Json** rules: public `get; set;` properties are serialized unless explicitly ignored.  
- Any inherited setting fields not provided above (like `Id`, `Name`, `Version`, etc.) are **assumed present** in the JSON. They should be documented as well.  
- Provided **MessageTypes** numeric mapping is used (see below). Numeric values not given are **unspecified**.  
- If a base class property isn’t shown in the code above, but typically appears in workflows (e.g., `Filters`, `Transformers`, `Disabled`, etc.), we mark it as *assumed inherited serialized field*.  
- **Only JSON-level concerns** are described: e.g., a boolean field’s effect on response vs. no-response. We do *not* describe code execution paths or internal calls.

## Canonical JSON schema and fields

A canonical `HttpSenderSetting` object (as JSON) might look like this:

```json
{
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "PostPatientData",
  "Version": 1,
  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "Disabled": false,

  "MessageTemplate": "{ \"id\": \"${PatientId}\", \"name\": \"${Name}\" }",
  "MessageType": 11,
  "MessageTypeOptions": null,

  "ResponseMessageTemplate": "{ \"status\": \"accepted\" }",
  "DifferentResponseMessageType": false,
  "ResponseMessageType": 11,

  "Server": "https://api.example.com/patients",
  "Method": 0,
  "ContentType": "application/json",
  "Encoding": "utf-8",
  "WaitForResponse": true,

  "Authentication": true,
  "UserName": "apiuser",
  "Password": "secretpassword",

  "UseAuthenticationCertificate": false,
  "AuthenticationCertificateThumbprint": "",
  "PreAuthenticate": false,

  "UseProxy": 0,
  "ProxyAddress": "",
  "ProxyUserName": "",
  "ProxyPassword": "",

  "TimeoutSeconds": 30,

  "Headers": [
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromSetting": "00000000-0000-0000-0000-000000000000",
      "FromType": 8,
      "Encoding": 0,
      "TextFormat": 0,
      "Truncation": 0,
      "TruncationLength": 50,
      "PaddingLength": 0,
      "Lookup": null,
      "Format": null
    }
  ]
}
```

Key points from this example:

- **Assumed inherited fields:** `Id`, `Name`, `Version`, `Filters`, `Transformers`, `Disabled`.
- **Sender fields:** `MessageTemplate`, `MessageType`, `MessageTypeOptions`, `ResponseMessageTemplate`, `DifferentResponseMessageType`, `ResponseMessageType`.
- **HTTP Sender fields:** `Server`, `Method`, `ContentType`, `Encoding`, `WaitForResponse`, `Authentication` (and related fields), `UseProxy` (and proxy fields), `TimeoutSeconds`, `Headers`.

### Fields reference

Below is a complete list of serialized fields (including inherited) for `HttpSenderSetting`. The **Type** and **default** are based on constructors and attributes. We note if a field is typically **required** or conditionally required:

| Field                       | Type           | Default                | Required/Notes                                                                                 |
|-----------------------------|---------------|-----------------------|------------------------------------------------------------------------------------------------|
| **(Inherited)** `Id`        | GUID           | –                     | _Required identifier_.                                                                       |
| **(Inherited)** `Name`      | string         | –                     | _Required display name_.                                                                     |
| **(Inherited)** `Version`   | int            | –                     | Should be set to `1` or higher; controls upgrade behavior.                                     |
| **(Inherited)** `Filters`   | GUID           | `00000000-0000-...`   | Filter set ID. Default is empty GUID (no filter).                                             |
| **(Inherited)** `Transformers` | GUID        | `00000000-0000-...`   | Transformer set ID. Default is empty GUID (no transformers).                                  |
| **(Inherited)** `Disabled`  | bool           | `false`               | If `true`, sender is disabled (no send).                                                     |

| **(Sender)** `MessageTemplate`  | string  | –         | Template for outgoing message body. Required for POST/PUT/DELETE (ignored for GET).          |
| **(Sender)** `MessageType`      | int enum (`MessageTypes`) | – | Required. Controls how the _response_ message is created (and influences template editor UI). |
| **(Sender)** `MessageTypeOptions` | object/null | `null` | Optional. Message-type-specific options (e.g. CSV delimiter).                                |
| **(Sender)** `ResponseMessageTemplate` | string | – | Optional. Sample of expected response structure (for UI/binding only, not used at send time).  |
| **(Sender)** `DifferentResponseMessageType` | bool | `false` | Optional. UI hint to allow different response message type. HTTP sender code ignores this. |
| **(Sender)** `ResponseMessageType` | int enum (`MessageTypes`) | – | Optional. UI hint for response type if `DifferentResponseMessageType=true`. Not used at send time. |

| **Server**               | string         | –                     | **Required URL** (may include `${var}` placeholders). No `config=` syntax supported.        |
| **Method**               | int enum (`HttpMethods`) | `0` (POST) | Required. `0=POST`, `1=GET`, `2=PUT`, `3=DELETE`.                                           |
| **ContentType**          | string         | `"text/plain"`        | Required. Sets the HTTP `Content-Type` header for all methods.                              |
| **Encoding**             | string         | –                     | Optional. Encoding for request/response. (Default UTF-8). Format names like `"utf-8"`.      |
| **WaitForResponse**      | bool           | `true`                | Required. If `true`, response is saved; if `false`, activity’s response message is empty.  |

| **Authentication**             | bool      | `false`               | Optional. If `true`, uses `UserName`/`Password` for basic auth.                              |
| **UserName**                   | string    | `null`                | Required if `Authentication=true`.                                                         |
| **Password**                   | string    | `null`                | Required if `Authentication=true`. Stored in JSON (plaintext).                              |
| **UseAuthenticationCertificate** | bool    | `false`               | Optional. If `true`, attach a client certificate.                                          |
| **AuthenticationCertificateThumbprint** | string | `null`      | Required if client cert is used. Certificate thumbprint.                                   |
| **PreAuthenticate**            | bool      | `false`               | Optional. Hint to send auth credentials preemptively (UI only; applies at send time).      |

| **UseProxy**           | int enum (`ProxySettings`) | `0` (UseDefaultProxy) | Optional. `0=UseDefaultProxy`, `1=ManualProxy`, `2=None`.                    |
| **ProxyAddress**       | string     | `null`                | Required if `UseProxy=1`.                                                               |
| **ProxyUserName**      | string     | `null`                | Optional (only for manual proxy credentials).                                          |
| **ProxyPassword**      | string     | `null`                | Optional (manual proxy). Stored in JSON (plaintext).                                    |

| **TimeoutSeconds**     | int        | `30`                  | Request timeout in seconds. `30` means 30s.                                            |

| **Headers**            | array of DatabaseSettingParameter objects | `null` | Optional. Custom headers. (Empty list or omit if none.) |

#### Notes on defaults and requirements

- If a property has no user-supplied value, the code’s default or the attribute default applies. 
- For GET (`Method=1`), the `MessageTemplate` is **not sent**; but it’s still persisted (generally harmless). 
- Removing optional entries (`Headers`, `Authentication=false`, etc.) uses the defaults as shown. 

## Enumerations and binding parameters

### HTTP Enums in JSON

- **HttpMethods (Method):** `0=POST`, `1=GET`, `2=PUT`, `3=DELETE`.  
- **ProxySettings (UseProxy):** `0=UseDefaultProxy`, `1=ManualProxy`, `2=None`.  

These appear as integers in JSON under `Method` and `UseProxy`.

### MessageTypes enum (for MessageType, ResponseMessageType)

Using the provided mapping (others unspecified):

| Numeric | MessageTypes (JSON value) | Meaning                              |
|-------:|--------------------------|---------------------------------------|
| `1`    | HL7                     | HL7v2 message (treated as text).      |
| `4`    | XML                     | XML message.                          |
| `5`    | CSV                     | CSV message.                          |
| `8`    | TextWithVariables       | Text (used for variable-binding).     |
| `11`   | JSON                    | JSON message (includes FHIR).         |
| `13`   | Text                    | Plain text message.                   |
| `14`   | Binary                  | Binary message (handled as base64).   |

*Unknown/Unspecified:* values for SQL, DICOM, JSONPath, etc., are not documented here.

### MessageSourceDirection (for parameter/header binding)

This enum governs how header/parameter values bind to other messages:

| Numeric | Name     | Meaning                                 |
|-------:|---------|-----------------------------------------|
| `0`    | inbound  | Bind to the **inbound** message of the source activity. |
| `1`    | outbound | Bind to the **outbound** message of the source activity. |
| `2`    | variable | Treat `Value` as literal text (with `${...}` expansion). |

These appear in JSON as `FromDirection` in header objects (see below).

### Header/parameter object fields

Custom headers use a `DatabaseSettingParameter` object. Relevant serialized fields:

| Field          | Type           | Default/Notes                                                      |
|---------------|---------------|---------------------------------------------------------------------|
| `Name`        | string        | **Required.** Header name (e.g. `"Accept"`).                        |
| `Value`       | string        | **Required.** Value expression or literal.                          |
| `FromDirection` | int enum (`MessageSourceDirection`) | `2` (variable) by default. 0 or 1 for activity binding. |
| `FromSetting` | GUID          | Required if `FromDirection` is 0 or 1 (specify source activity ID). |
| `FromType`    | int enum (`MessageTypes`) | Normally the source message type (or `8` for variables). UI hint. |
| `FromNamespaces` | object    | (Optional) Namespace mappings (typically not used by HTTP sender). |
| `AllowBinding` | bool         | `true` (UI hint).                                                   |
| **Formatting fields (ignored by HTTP):** <br>`Encoding`, `TextFormat`, `Truncation`, `TruncationLength`, `PaddingLength`, `Lookup`, `Format` | various | Present in JSON schema but not used by HTTP sender. They control formatting in other contexts but are **ignored** for HTTP headers. |

**Important:** HTTP Sender runtime only uses `Name`, `Value`, `FromDirection`, and `FromSetting`. The other fields may appear in JSON but do not affect the HTTP request. In JSON, you should still include `FromType` for consistency, but it is not passed to the HTTP binding logic.

## Connection/URL placeholders and security

- **Server URL:** The `Server` string can include `${VarName}` placeholders. These are expanded at runtime (workflow variable syntax). There is **no special `config=` syntax** for HTTP Sender; use plain variables or activity message bindings.
- **Credentials in JSON:** `UserName`, `Password`, `ProxyUserName`, `ProxyPassword` are stored in JSON. They are **plaintext** fields. Do not assume secrecy in the workflow file.
- **Encoding field:** The `Encoding` property in JSON sets the character encoding (e.g. `"utf-8"`). This is *only* a persisted setting; see *Response handling* below for when it is applied.

## Response handling and two-way mode

- **WaitForResponse:** A boolean that dictates whether the response body is kept. If `true`, the response is returned as the activity’s message; if `false`, the response is discarded (response message text will be empty).
- **MessageType (for response):** The `MessageType` (enum) also determines how to parse/format the response message in the workflow. For example, if `MessageType=11` (JSON), the response text is treated as JSON. If `MessageType=14` (Binary), the raw bytes are Base64-encoded in the response message text.
- **DifferentResponseMessageType / ResponseMessageType:** These fields exist in JSON for UI/binding purposes. If `DifferentResponseMessageType=true`, it tells the UI to allow a different response type (given by `ResponseMessageType`). **However, the HTTP Sender’s code always uses `MessageType` for the actual response.** In practice, always set `MessageType` to the desired response type (and leave `DifferentResponseMessageType` false) to match runtime behavior.

## UI behaviors and JSON persistence

- **Header sorting:** In the UI, headers are saved sorted by `Name`. In JSON, you may see them ordered alphabetically by header name.
- **SwapActivityIds:** When workflow IDs change, the engine updates `FromSetting` GUIDs in headers/parameters automatically based on the `SwapActivityIds` logic. This ensures bindings stay correct. (No other JSON renames happen at save time.)
- **Upgrade/Version:** The `Version` field can trigger defaulting behavior (e.g. setting `TimeoutSeconds=30` if missing in old files). For JSON authors, always include sensible defaults explicitly (as shown above) and you can usually omit upgrade concerns unless migrating old workflows.

## Pitfalls and security concerns

- **Storing secrets:** Do not store confidential credentials in plain JSON if security is a concern. Use variables or externalized configurations if possible, because `Password` and proxy passwords are readable in workflow files.
- **Header tokens:** If you use `${...}` in headers (e.g. `Value: "Bearer ${Token}"`), ensure the variable or bound message doesn’t inadvertently expose sensitive data in logs or audit trails.
- **GET method:** Remember that `MessageTemplate` is ignored for GET. If you put JSON in `MessageTemplate` when `Method=1`, it will not be sent, even though the JSON might be logged or seem to appear in UI.
- **Content-Type header:** The `ContentType` property always adds a `Content-Type` header. If you also add a `Content-Type` in `Headers`, you could get duplicates or errors. 
- **Encoding mismatches:** If you set `Encoding` to a value not supported (e.g. a typo), the sender will fail at runtime. Also, note: `Encoding` **does not affect GET responses** (which use UTF-8 by default), so getting binary data via GET still requires `MessageType=14`.
- **DELETE with body:** The code sends a body even on DELETE (if `MessageTemplate` is set). Many HTTP servers disallow bodies on DELETE. Use with caution.

## JSON examples

Below are concise JSON configurations for common scenarios (only key fields shown):

- **POST JSON body, Bearer auth header:**
  ```json
  {
    "Name": "SendPatientUpdate",
    "Server": "https://api.example.com/patients",
    "Method": 0,
    "ContentType": "application/json",
    "WaitForResponse": true,
    "MessageTemplate": "{ \"id\": \"${PatientId}\", \"status\": \"${Status}\" }",
    "MessageType": 11,
    "Headers": [
      {
        "Name": "Authorization",
        "Value": "Bearer ${AccessToken}",
        "FromDirection": 2,
        "FromType": 8
      }
    ]
  }
  ```

- **GET with query parameter placeholder:**
  ```json
  {
    "Name": "FetchPatient",
    "Server": "https://api.example.com/patients/${PatientId}?details=true",
    "Method": 1,
    "ContentType": "application/json",
    "WaitForResponse": true,
    "MessageType": 11
  }
  ```

- **POST binary payload (body treated as plain text):**
  ```json
  {
    "Name": "UploadData",
    "Server": "https://api.example.com/upload",
    "Method": 0,
    "ContentType": "application/octet-stream",
    "WaitForResponse": true,
    "MessageTemplate": "${BinaryData}", 
    "MessageType": 13,
    "Encoding": "us-ascii"
  }
  ```
  *(Here the payload in `${BinaryData}` is sent as text bytes. HTTP Sender does not auto-decode base64 for outgoing payload.)*

- **Header bound to another activity’s message:**
  ```json
  {
    "Name": "CallerAuthHeader",
    "Value": "[1]",
    "FromSetting": "dddddddd-dddd-dddd-dddd-dddddddddddd",
    "FromDirection": 0,
    "FromType": 11
  }
  ```
  *(This binds the value of header name `"CallerAuthHeader"` to the inbound message of activity with ID `dddd...`, which must be JSON because `FromType`=11.)*

## Mermaid flowchart (JSON-level overview)

```mermaid
flowchart TD
    A[Construct outbound message (MessageTemplate + variables)] --> B[Expand Server URL with ${vars}]
    B --> C[Build HTTP request object from JSON fields (Method, ContentType, Headers)]
    C --> D{WaitForResponse?}
    D -->|true| E[Send request, receive response]
    D -->|false| E
    E --> F{Is response captured?}
    F -- yes --> G[Set response text using MessageType for formatting]
    F -- no --> H[Set empty response]
    G --> I[Activity completes (response available)]
    H --> I
```

This flow omits internal calls; it illustrates how JSON fields map to send/receive actions and final response availability.

## External Resources

- Integration Soup workflow sender documentation (IntegrationSoup.com)  
- HL7 Interfacer blog (HL7Interfacer.blogspot.com)  
- [Send HL7 to a Database with Activities (IntegrationSoup tutorial)](https://www.integrationsoup.com/hl7tutorialaddpatienttodatabasewithactivities.html)  
- [Integration Host Workflow Designer overview (IntegrationSoup)](https://www.integrationsoup.com/hl7tutorialintegrationhostworkflowdesigner.html)  
- [Securing HL7 messages with HTTPS (IntegrationSoup)](https://www.integrationsoup.com/hl7tutorialsecuringhl7messageswithhttpoverssl.html)