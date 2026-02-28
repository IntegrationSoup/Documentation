# HTTP Sender (HttpSenderSetting)

Intended readers: AI agents and developers who author/edit Integration Soup workflow JSON._

## Executive summary

The **HTTP Sender** activity (`HttpSenderSetting`) sends the workflow’s current outbound message content to an HTTP endpoint using a configured **URL**, **HTTP method**, **Content-Type**, optional **authentication**, optional **client certificate**, optional **proxy**, and optional **custom headers**. It can run in **two-way mode** (capture and expose the HTTP response as the activity’s response message) or **one-way mode** (do not retain the response body in workflow state).

Key non-obvious behaviors from the code that matter when editing workflow JSON:

- **GET never sends a body**, even if `MessageTemplate` produces content. The outbound message is still logged as “Sent”, which can be misleading.
- **`WaitForResponse` does not make the call asynchronous.** The HTTP call is synchronous either way; `WaitForResponse` only controls whether the response body is retained in workflow state.
- **Response message type is driven by `MessageType`, not `ResponseMessageType`.** This has implications if you try to model “JSON request, CSV response” within this activity.
- **Header values are computed via binding (`DatabaseSettingParameter`) but formatting fields on that object are not applied** for HTTP headers (unlike database parameters).
- **Encoding is applied to request bodies for non-GET** and to response decoding for non-GET; **GET response decoding ignores the configured encoding** unless you use binary mode.

## Activity role and how data flows through it

At runtime the HTTP Sender behaves like a thin “transport adapter” around the workflow’s current message:

- The **request body payload** (POST/PUT/DELETE) is taken from `workflowInstance.Message?.Text`. The HTTP Sender itself does **not** read `MessageTemplate` directly; message construction is handled by the sender pipeline elsewhere in the workflow engine (message template + transformers).
- The **URL** comes from `Server`, with Integration Soup variable placeholders processed at send time (`ServerRuntimeValue()`).
- **Headers** are applied in two layers:
  - Always: `Content-Type` header is added using `ContentType`.
  - Optional: each entry in `Headers` is evaluated and added via `client.Headers.Add(name, value)`.
- The **response body** is read for all methods (because the underlying call is synchronous), then conditionally persisted:
  - Two-way mode: response body becomes the Activity response message text.
  - One-way mode: response body is discarded for workflow purposes (response message text is empty), although the HTTP call still waits for completion.

## Serialized JSON contract for HttpSenderSetting

This section describes the JSON shape corresponding to the serialized `HttpSenderSetting` used in workflow files. Property names match C# property names (PascalCase).

### Canonical JSON shape

This is a “safe-to-author” canonical shape: it includes the keys most often required for correct runtime behavior and cross-environment portability.

```json
{
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "HTTP Sender",
  "Version": 0,

  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "Disabled": false,

  "MessageTemplate": "{ \"patientId\": \"${PatientId}\" }",
  "MessageType": 11,
  "MessageTypeOptions": null,

  "ResponseMessageTemplate": "{ \"status\": \"ok\" }",
  "DifferentResponseMessageType": false,
  "ResponseMessageType": 11,

  "Server": "https://api.example.com/patients/${PatientId}",
  "Method": 0,
  "ContentType": "application/json",

  "WaitForResponse": true,

  "Authentication": false,
  "UserName": "",
  "Password": "",

  "UseAuthenticationCertificate": false,
  "AuthenticationCertificateThumbprint": "",
  "PreAuthenticate": false,

  "UseProxy": 0,
  "ProxyAddress": "",
  "ProxyUserName": "",
  "ProxyPassword": "",

  "TimeoutSeconds": 30,
  "UseDefaultCredentials": false,

  "Headers": [
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromType": 8,
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

  "Encoding": "utf-8"
}
```

### Required vs optional keys

A workflow JSON file may omit keys that have constructor defaults, but “definitive” JSON authoring (especially for AI agents) should prefer explicitness to avoid ambiguity.

**Safe-to-include always (recommended):**
- `Id`, `Name`
- `Server`, `Method`, `ContentType`
- `WaitForResponse`
- `TimeoutSeconds`
- `MessageTemplate` (even for GET; it documents intent, though GET does not send a body)
- `MessageType` (controls response handling and response message creation)
- `Headers` (use `[]` if none)

**Conditionally required:**
- If `Authentication = true`: include `UserName` and `Password`
- If `UseAuthenticationCertificate = true`: include `AuthenticationCertificateThumbprint`
- If `UseProxy = 1` (ManualProxy): include `ProxyAddress` (credentials optional depending on environment)

**Often present but not activity-specific:**
- `Filters`, `Transformers`, `Disabled`, `Version`
- `ResponseMessageTemplate`, `DifferentResponseMessageType`, `ResponseMessageType` (primarily used by binding UI; see “Response typing pitfalls”)

## HttpSenderSetting fields and functional meaning

The table below lists **serialized fields** that define HTTP Sender behavior and the most important workflow-level effects.

### HttpSenderSetting fields

| Field | Type | Default | Include in JSON | Behavior in code |
|---|---|---:|---:|---|
| `Server` | string | `null` | required | The target URL. At send time, the engine evaluates placeholders via `workflowInstance.ProcessVariables(Server)`. No URL encoding is applied automatically. |
| `Method` | int enum (`HttpMethods`) | `POST` | required | Controls GET’s `OpenRead()` path vs other verbs’ `UploadData()` path. DELETE uses `UploadData()` with a body (can surprise servers). |
| `ContentType` | string | `"text/plain"` | required | Always added as HTTP header `Content-Type`. This occurs even for GET. |
| `WaitForResponse` | bool | `true` | strongly recommended | If `true`, the response body is retained as the activity response message text. If `false`, response message text is empty (but the HTTP call still runs synchronously). |
| `Authentication` | bool | `false` | optional | If `true`, sets `client.Credentials = new NetworkCredential(UserName, Password)`. |
| `UserName` | string | `null` | conditional | Used only if `Authentication=true`. Not passed through `ProcessVariables` in sender code. |
| `Password` | string | `null` | conditional | Used only if `Authentication=true`. Stored in workflow JSON unless externalized. |
| `UseAuthenticationCertificate` | bool | `false` | optional | Enables attaching a client TLS certificate via `WebClientSupportingCertificates`. |
| `AuthenticationCertificateThumbprint` | string | `null` | conditional | Thumbprint used to locate the certificate. (Certificate lookup details are implemented in the WebClient wrapper; treat this as “must match installed cert thumbprint”.) |
| `PreAuthenticate` | bool | `false` | optional | Passed to the WebClient wrapper. Intended to send auth info without waiting for a challenge. |
| `UseProxy` | int enum (`ProxySettings`) | `UseDefaultProxy` | optional | Controls proxy behavior: default proxy config, manual proxy, or no proxy. |
| `ProxyAddress` | string | `null` | conditional | Required for manual proxy. Treated as URI string. |
| `ProxyUserName` | string | `null` | optional | Manual proxy credential. Stored in JSON. |
| `ProxyPassword` | string | `null` | optional | Manual proxy credential. Stored in JSON. |
| `TimeoutSeconds` | int | `30` | recommended | Request timeout in seconds. Passed to WebClient wrapper as milliseconds (`TimeoutSeconds * 1000`). |
| `UseDefaultCredentials` | bool | `false` | optional | Sets `client.UseDefaultCredentials`. If you also set `Authentication=true`, explicit `Credentials` are assigned afterward. |
| `Headers` | array of `DatabaseSettingParameter` | `null` | optional | Custom headers. Each entry is evaluated and applied. Saved sorted by header name in UI. |
| `Encoding` | string | `null` | optional | Used to encode request body bytes (non-GET) and to decode response bytes (non-GET). If unset, UTF-8 is used. GET response decoding does not use this setting. |

### Inherited sender/activity fields that commonly appear in workflow JSON

These fields are inherited from `SenderWithResponseSetting → SenderSetting → ActivitySetting → Setting`. They strongly influence how the HTTP sender is used in a workflow JSON file even though they are not “HTTP-specific.”

| Field | Type | Default | Include in JSON | Notes |
|---|---|---:|---:|---|
| `Id` | GUID | unspecified | required | Activity identifier used throughout bindings (`FromSetting`) and `${ActivityId inbound/outbound}` placeholders. |
| `Name` | string | unspecified | required | Display name; used in UI and readability. |
| `Version` | int | unspecified | recommended | Used for upgrade logic when importing workflows. Documented here as “present”, but treat current behavior as latest version. |
| `Filters` | GUID | `00000000-...` | optional | Filter setting applied before send (workflow pipeline). |
| `Transformers` | GUID | `00000000-...` | optional | Transformer setting executed before send (workflow pipeline). |
| `Disabled` | bool | `false` | optional | Disabled settings can exist even when invalid. |
| `MessageTemplate` | string | unspecified | recommended | Outbound message template used by the sender pipeline to construct `workflowInstance.Message?.Text`. For GET requests, the HTTP sender will not transmit a body, but the template may still populate the binding tree. |
| `MessageType` | int enum (`MessageTypes`) | unspecified | required | Critically: this controls response decoding and response message creation in HTTP Sender runtime. |
| `MessageTypeOptions` | object/null | `null` | optional | Opaque message-type-specific options used when creating the response message object. (Exact schema depends on message type options classes, not included here.) |
| `ResponseMessageTemplate` | string | unspecified | optional | Used as a sample/shape of expected response for bindings and tooling. Not consumed by HTTP sender runtime. |
| `DifferentResponseMessageType` | bool | `false` | optional | Used by binding UI to interpret inbound/response typing. Runtime does not apply this to decoding. |
| `ResponseMessageType` | int enum (`MessageTypes`) | unspecified | optional | Used by binding UI if `DifferentResponseMessageType=true`. Runtime HTTP sender uses `MessageType` for response creation. |

## Headers and binding objects in JSON

Custom HTTP headers are represented using the reusable `DatabaseSettingParameter` object (even though it originates from the database sender setting model). For HTTP Sender, treat each entry as **one header**.

### Canonical header object shape

This is the minimal, runtime-relevant subset:

```json
{
  "Name": "Authorization",
  "Value": "Bearer ${AccessToken}",
  "FromDirection": 2,
  "FromSetting": "00000000-0000-0000-0000-000000000000",
  "FromType": 8
}
```

### `DatabaseSettingParameter` fields and what HTTP Sender actually uses

**HTTP Sender runtime uses only:**
- `Name`
- `Value`
- `FromDirection`
- `FromSetting`

It does **not** apply the formatting fields (Encoding/TextFormat/Truncation/Lookup/etc.) to headers.

That means these fields may appear in JSON (because the object type supports them), but they are **ignored for HTTP headers** unless the broader workflow engine applies formatting elsewhere.

#### Full field list for header objects (DatabaseSettingParameter)

| Field | Type | Default | Include in JSON | HTTP Sender effect |
|---|---|---:|---:|---|
| `Name` | string | none | required | Header name. Empty/whitespace names are ignored. |
| `Value` | string | none | required | Header value source expression. |
| `FromDirection` | int enum (`MessageSourceDirection`) | `2` | recommended | Controls variable vs activity-message binding. |
| `FromSetting` | GUID | `00000000-...` | conditional | Required for inbound/outbound binding; should be empty for variable-based headers. |
| `FromType` | int enum (`MessageTypes`) | `TextWithVariables` | recommended | Primarily a UI/type hint. Keep consistent for stable binding-editing; runtime header resolution does not pass this to the value resolver. |
| `FromNamespaces` | object | null | optional | Namespace context (primarily XML). HTTP sender passes `null` namespaces to the value resolver anyway. |
| `Encoding` | int enum | `0` | optional | Formatting field (ignored by HTTP sender for headers). |
| `TextFormat` | int enum | `0` | optional | Formatting field (ignored by HTTP sender for headers). |
| `Truncation` | int enum | `0` | optional | Formatting field (ignored by HTTP sender for headers). |
| `TruncationLength` | int | `50` | optional | Formatting field (ignored by HTTP sender for headers). |
| `PaddingLength` | int | `0` | optional | Formatting field (ignored by HTTP sender for headers). |
| `Lookup` | string/null | null | optional | Formatting field (ignored by HTTP sender for headers). |
| `Format` | string/null | null | optional | Formatting field (ignored by HTTP sender for headers). |
| `AllowBinding` | bool | `true` | optional | UI convenience. |
| `IsValid` | bool | `true` | optional | UI validation state; do not author manually. |

### Binding semantics for header values

Header values are resolved through:

```text
headerValue = TransformerAction.GetTheValue(workflowInstance, param.Value, param.FromSetting, param.FromDirection, null)
```

Practical authoring rules:

- If `FromDirection = 2` (variable/text):
  - `Value` is treated as literal text with `${VariableName}` placeholders.
  - `FromSetting` should be empty/omitted (or `00000000-...`).
- If `FromDirection = 0` (inbound) or `1` (outbound):
  - `FromSetting` must be the GUID of the activity you are binding from.
  - `Value` must be a valid path expression for that activity’s message type (HL7 path, XPath, CSV index syntax, JSON path syntax as supported by Integration Soup).

Important nuance for AI agents: in the implementations shown, `GetTheValue` does not receive `FromType`, so **runtime value extraction is message-driven** (source message type determines how it interprets the path). `FromType` is best treated as a **persisted UI hint** that should be consistent so that subsequent UI edits keep the correct path editor mode.

## Enum reference for workflow JSON authors

All enums serialize as integers in workflow JSON.

### HttpMethods

| Numeric | Name |
|---:|---|
| `0` | `POST` |
| `1` | `GET` |
| `2` | `PUT` |
| `3` | `DELETE` |

### ProxySettings

| Numeric | Name | Meaning |
|---:|---|---|
| `0` | `UseDefaultProxy` | Use the process/app default proxy configuration (commonly from app.config defaultProxy). |
| `1` | `ManualProxy` | Use `ProxyAddress` (+ optional `ProxyUserName`/`ProxyPassword`). |
| `2` | `None` | Set proxy to null (direct connection). |

### MessageSourceDirection

`DatabaseSettingParameter.FromDirection` uses this mapping:

| Numeric | Name | Meaning |
|---:|---|---|
| `0` | `inbound` | Bind to the inbound/received message of the source activity (for senders, often the response). |
| `1` | `outbound` | Bind to the outbound/sent message of the source activity. |
| `2` | `variable` | Treat `Value` as text with `${...}` placeholders. |

### MessageTypes

This guide lists only the MessageTypes that are clearly relevant to HTTP Sender and consistently referenced across the provided code and documentation patterns. Other internal MessageTypes exist (including path helper types like XPath/JSONPath/HL7Path), but their exact numeric values are not enumerated here.

| Numeric | Name | HTTP Sender impact |
|---:|---|---|
| `1` | HL7 | Response is treated as text; the message object is created as HL7-type for downstream pathing. |
| `4` | XML | Response is treated as text; message object created as XML-type. |
| `5` | CSV | Response is treated as text; message object created as CSV-type. |
| `8` | TextWithVariables | Used primarily as a binding hint for parameters/headers that are variable-based text. |
| `11` | JSON | Response is treated as text; message object created as JSON-type. |
| `13` | Text | Response is treated as text; message object created as plain text. |
| `14` | Binary | Response bytes are base64-encoded into the message text; message object created as binary-type. |

If you need to use path-specific MessageTypes (e.g., XPath/JSONPath/HL7V2Path) in JSON: treat their numeric values as **implementation-controlled** and prefer authoring via the UI or a known-good workflow template because those values are not stable from the code shown here.

## Runtime behavior, pitfalls, and “gotchas” that matter in JSON

### What actually gets sent

- For `POST`/`PUT`/`DELETE`:
  - Payload comes from `workflowInstance.Message?.Text`.
  - Payload bytes are produced via:
    - UTF-8 by default
    - or `Encoding.GetEncoding(Encoding)` if `Encoding` is configured
- For `GET`:
  - No payload is sent (hard rule in the code).
  - Even if `MessageTemplate` produces a message, it will not be transmitted.

**Gotcha:** outbound message logging occurs regardless of method. The activity logs `workflowInstance.Message?.Text` as “Sent” even when the method is GET (where no body is transmitted). This can confuse troubleshooting if you assume the logged “Sent” content was delivered as a GET body.

### How headers are applied

1. `Content-Type` header is always added using `ContentType`.
2. Each header in `Headers` is evaluated and added using `client.Headers.Add(name, value)`.

Practical implications:

- If you add your own `Content-Type` header in `Headers`, you can end up with duplicates or conflicts (behavior depends on underlying WebClient header handling).
- Certain restricted headers may throw exceptions or be silently managed differently by WebClient. There is no local try/catch around header assignment; errors will fail the send.

### URL processing and variable expansion

The URL is computed using `ServerRuntimeValue(workflowInstance)`, which calls `workflowInstance.ProcessVariables(Server)`.

Implications:

- You can embed `${VariableName}` in `Server`.
- You can embed activity-message placeholders (the same family of `${ActivityId inbound/outbound}` placeholders used in message templates), depending on what `ProcessVariables` supports in your environment.
- Variable insertion is **not URL-encoded**. If variables contain spaces, `&`, `/`, `?`, or non-ASCII characters, you should supply already-encoded values or ensure safe character sets.

### Authentication, proxy, and credentials behavior

- If `Authentication=true`, the sender sets `client.Credentials = new NetworkCredential(UserName, Password)`.
  - `UserName` and `Password` are taken as literal strings at send time; they are not passed through `ProcessVariables` in this sender code path.
- `UseDefaultCredentials` is applied before explicit credentials. If you set both, explicit credentials are assigned afterward; the practical expectation is that explicit credentials will apply, but avoid ambiguous configs.

Proxy rules:

- `UseProxy=0` uses default proxy configuration (commonly controlled by the running process).
- `UseProxy=1` builds a manual proxy using `ProxyAddress` and optional credentials.
- `UseProxy=2` disables proxy usage entirely.

### Response handling and how the response message is created

The sender always waits for a response at the network layer (synchronous request). The significant behavior difference is whether the response is retained.

- The raw response bytes are read:
  - GET: via `OpenRead(url)` and streaming read
  - Non-GET: via `UploadData(url, method, data)` returning byte[]
- If `MessageType` is **Binary (14)**:
  - Response is converted to base64 text and stored in the response message.
- Otherwise:
  - Non-GET: response bytes are decoded into string using `Encoding` (or UTF-8 default).
  - GET: response stream is read via `StreamReader(stream)` (default encoding behavior), not the configured `Encoding` string.

Retention rules:
- If `WaitForResponse = true`:
  - Response text becomes the activity’s response message text.
- If `WaitForResponse = false`:
  - Response message text is empty (but the HTTP request still runs and a response is still read internally).

**Crucial typing rule:** the response message object is created using:

```text
GetFunctionMessage(responseData, Setting.MessageType, Setting.MessageTypeOptions)
```

So for correct downstream pathing/parsing of the response, you must set:
- `MessageType` to the intended response type (JSON/XML/CSV/Text/Binary)
- `MessageTypeOptions` appropriately (if used in your environment)

### Error and logging behavior

- The sender logs “Sent” and “Response” events to the Message Log.
- There is an early log call that records an empty response before the request is made, and then a later log call that records the real response. In environments where message logs are used for auditing, this “double response log entry” can look like a response was empty and then later changed.

Error handling:
- `WebException` is handled specially: if an HTTP response body exists, it is read as the error message; otherwise the exception message is used.
- Any error causes the activity to mark itself errored and fails the workflow execution path unless the workflow engine is configured to continue on error.

TLS/certificate notification behavior:
- If internal certificate pinning/unpinning logic populates a “certificate message” for the resolved URL, the sender creates a workflow notification indicating the HTTPS destination certificate has changed and clears that message. This can surface in production as “unexpected” notifications even when the call succeeds.

### One-way vs two-way mode clarification

`WaitForResponse=false` is “one-way” only in terms of *workflow state retention*. It is **not** a fire-and-forget request.

If you need true async/off-thread delivery semantics, this activity does not provide them directly at the code level shown; you would enforce it operationally (e.g., by calling a queue endpoint, or by having the service respond quickly and do work later).

## Examples and patterns

These examples focus on JSON authoring patterns that match how the code behaves.

### POST JSON body with variable expansion and bearer token header

```json
{
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "POST Patient JSON",
  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",

  "MessageTemplate": "{ \"patientId\": \"${PatientId}\", \"name\": \"${LastName}, ${FirstName}\" }",
  "MessageType": 11,
  "MessageTypeOptions": null,

  "Server": "https://api.example.com/patients",
  "Method": 0,
  "ContentType": "application/json; charset=utf-8",
  "Encoding": "utf-8",

  "WaitForResponse": true,

  "Headers": [
    {
      "Name": "Authorization",
      "Value": "Bearer ${AccessToken}",
      "FromDirection": 2,
      "FromType": 8,
      "FromSetting": "00000000-0000-0000-0000-000000000000"
    },
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromType": 8
    }
  ]
}
```

### GET with query parameters (no request body)

```json
{
  "Id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "Name": "GET Patient",
  "MessageTemplate": "This will not be sent for GET",
  "MessageType": 11,

  "Server": "https://api.example.com/patients/${PatientId}?include=appointments",
  "Method": 1,
  "ContentType": "application/json",

  "WaitForResponse": true,

  "Headers": [
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromType": 8
    }
  ]
}
```

Operational note: ensure `${PatientId}` is safe for URL inclusion. If it can contain characters requiring encoding, supply an already-encoded variable or encode upstream.

### “Binary” response handling (store response bytes as base64)

Use this when the endpoint returns a PDF/image/other binary stream and you want the workflow to carry it forward as base64 text.

```json
{
  "Id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
  "Name": "GET Binary Payload",
  "MessageType": 14,

  "Server": "https://api.example.com/reports/${ReportId}/pdf",
  "Method": 1,
  "ContentType": "application/octet-stream",

  "WaitForResponse": true
}
```

### Handling response as CSV or JSON

Because HTTP Sender uses `MessageType` for response message creation, you decide the response handling by setting `MessageType`:

- JSON response: `"MessageType": 11`
- CSV response: `"MessageType": 5`
- Plain text: `"MessageType": 13`

If you try to set different response typing via `ResponseMessageType`, note that (in the provided runtime code) it will not change how the response is decoded or typed.

### Custom header bound to another activity’s message

This pattern is used when a previous activity produced a token or correlation ID as part of its outbound or inbound message.

```json
{
  "Name": "X-Correlation-Id",
  "Value": "${CorrelationId}",
  "FromDirection": 2,
  "FromType": 8
}
```

Or, binding directly from another activity (GUID must match the workflow’s activity ID):

```json
{
  "Name": "X-Correlation-Id",
  "Value": "[1]",
  "FromDirection": 0,
  "FromSetting": "dddddddd-dddd-dddd-dddd-dddddddddddd",
  "FromType": 5
}
```

## Mermaid runtime flow diagram

```mermaid
flowchart TD
  A[Start HTTP Sender] --> B[MessageTemplate + transformers build outbound message text]
  B --> C[Expand variables in Server URL]
  C --> D[Create WebClient wrapper with timeout, cert, pre-auth]
  D --> E[Apply proxy + credentials + default credentials]
  E --> F[Add Content-Type header]
  F --> G[Evaluate Headers: bind each value and add to request]
  G --> H{Method == GET?}
  H -- yes --> I[OpenRead(url): read response stream]
  H -- no --> J[UploadData(url, method, payloadBytes): read response bytes]
  I --> K[Decode response as base64 if Binary else StreamReader]
  J --> L[Decode response as base64 if Binary else Encoding.GetString]
  K --> M{WaitForResponse?}
  L --> M
  M -- true --> N[Set responseData = decoded response]
  M -- false --> O[Set responseData = empty string]
  N --> P[Create ResponseMessage from MessageType + options]
  O --> P
  P --> Q[Write MessageLog entries + completed status]
  Q --> R[If SSL certificate notification pending: create workflow notification]
  R --> S[End]
```

## External resources

Useful supporting pages (IntegrationSoup.com and HL7 Interfacer) that align with common HTTP Sender use cases and configuration topics:

- [Sending DICOM Tags to a Web API or REST Service](https://www.integrationsoup.com/dicomtutorialsendtorestapi.html)  
- [Securing HL7 messages with HTTPS over SSL/TLS](https://www.integrationsoup.com/hl7tutorialsecuringhl7messageswithhttpoverssl.html)  
- [Integration Host Workflow Designer Tutorial](https://www.integrationsoup.com/hl7tutorialintegrationhostworkflowdesigner.html)  
- [What’s new in HL7 Soup v3](https://www.integrationsoup.com/whatsnewinv3.1.html)  
- [HL7 Tutorials index](https://www.integrationsoup.com/hl7tutorials.html)  
- [HL7 Interfacer blog](https://hl7interfacer.blogspot.com/)