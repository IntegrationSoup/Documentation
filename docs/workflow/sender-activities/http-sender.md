# HTTP Sender (HttpSenderSetting)

## Executive summary

The **HTTP Sender** activity (`HttpSenderSetting`) executes an outbound HTTP request using a configured **URL**, **method**, **headers**, and (for non-GET methods) a **payload** derived from the workflow’s outbound message content. It optionally records and exposes the HTTP response back to the workflow when `WaitForResponse` is enabled. Integration Soup promotes HTTP as a first-class way to call REST services (including FHIR endpoints), to send JSON/XML/CSV/text/binary payloads, and to secure traffic over TLS. citeturn6view2turn6view0turn6view3

Important non-obvious points for JSON authors (from the provided code):

- `WaitForResponse` primarily controls **whether response content is retained** as the activity’s response message. It does **not** make the HTTP call asynchronous; the underlying call still waits for completion or timeout.
- `MessageType` is used in **response handling** (binary vs text decode) and in how a response message object is created. `ResponseMessageType` exists on the base class but is **not** used by the HTTP sender runtime shown.
- Custom headers are stored using `DatabaseSettingParameter` objects; these support binding to variables or other activities’ messages, but **header value formatting fields** on `DatabaseSettingParameter` are **not applied** by the HTTP sender runtime.
- Secrets (HTTP auth password, proxy password) are stored in JSON as plain strings unless you externalize them via variables/secret mechanisms.

Assumptions (explicit, as requested):

- **Serialization model**: treat workflow JSON as if **System.Text.Json default contract** is used (public `get; set;` is serialized unless marked `[System.Text.Json.Serialization.JsonIgnore]`).  
- **Missing base**: the `Setting` base class is not provided here; base fields like `Id`, `Name`, and `Version` are **assumed** via `ISetting`.  
- **MessageTypes numeric mapping**: use the “provided mapping” values and explicitly mark anything else as **unspecified** due to missing enum source. (See enums section.)

## Canonical JSON schema and object shapes

### Canonical HttpSenderSetting JSON

This is a **canonical** “safe-to-author” JSON example. It includes the sender’s core HTTP fields plus the commonly persisted base sender/activity fields.

```json
{
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Call REST API",
  "Version": 2,

  "Disabled": false,
  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "FiltersNotAvailable": false,
  "TransformersNotAvailable": false,
  "DisableNotAvailable": false,

  "MessageTemplate": "{ \"patientId\": \"${PatientId}\" }",
  "MessageType": 11,
  "MessageTypeOptions": null,

  "ResponseMessageTemplate": "{ \"id\": \"example\" }",
  "DifferentResponseMessageType": false,
  "ResponseMessageType": 11,

  "Server": "https://api.example.com/patients",
  "Method": 0,
  "ContentType": "application/json",

  "WaitForResponse": true,

  "Authentication": true,
  "UserName": "${ApiUser}",
  "Password": "${ApiPassword}",

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
      "FromSetting": "00000000-0000-0000-0000-000000000000"
    }
  ],

  "Encoding": "utf-8"
}
```

Notes tied to product behavior:

- Integration Soup positions HTTP Sender as a way to call REST services and to send JSON and other formats; it also highlights secure sending over SSL/TLS. citeturn6view2turn6view0
- HTTP sender headers and timeout configurability were introduced/enhanced in the v3.3-era feature set. citeturn6view1

### Canonical header object schema (DatabaseSettingParameter)

HTTP headers use `DatabaseSettingParameter` objects (originally designed for database parameters). As used by HTTP Sender, interpret each object as:

- `Name` = header name
- `Value` + binding fields (`FromDirection`, `FromSetting`) drive how the header value is produced

Minimal, variable-based header:

```json
{
  "Name": "Authorization",
  "Value": "Bearer ${AccessToken}",
  "FromDirection": 2,
  "FromType": 8
}
```

Header bound to another activity’s message:

```json
{
  "Name": "X-Correlation-Id",
  "Value": "[1]",
  "FromDirection": 0,
  "FromType": 5,
  "FromSetting": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
}
```

### Complete serialized fields list

This section lists **all public get/set properties** that are likely to serialize under the requested System.Text.Json assumption (excluding explicit `[JsonIgnore]`). Fields are grouped by declaring type.

#### HttpSenderSetting fields

| Field | Type | Constructor default | Required | Notes |
|---|---|---:|---:|---|
| `Server` | string | `null` | yes | URL of the endpoint. Runtime calls `workflowInstance.ProcessVariables(Server)` before sending. |
| `Method` | enum `HttpMethods` (int) | `POST` | yes | Controls GET vs UploadData path and whether payload is sent. |
| `ContentType` | string | `"text/plain"` | yes | Always added as `Content-Type` header, even for GET. |
| `WaitForResponse` | bool | `true` | strongly recommended | Controls whether response content is preserved (`ResponseNotAvailable` computed). Does not make call async. |
| `Authentication` | bool | `false` | optional | If true, sets `client.Credentials = new NetworkCredential(UserName, Password)`. |
| `UserName` | string | `null` | conditional | Used only when `Authentication=true`. No variable-expansion is applied automatically. |
| `Password` | string | `null` | conditional | Used only when `Authentication=true`. Stored in JSON unless externalized. |
| `UseAuthenticationCertificate` | bool | `false` | optional | Enables client cert usage via `WebClientSupportingCertificates`. |
| `AuthenticationCertificateThumbprint` | string | `null` | conditional | Used only when `UseAuthenticationCertificate=true`. |
| `PreAuthenticate` | bool | `false` | optional | Passed into WebClient wrapper; affects credential pre-send logic. |
| `UseProxy` | enum `ProxySettings` (int) | `UseDefaultProxy` | optional | `UseDefaultProxy`, `ManualProxy`, or `None`. |
| `ProxyAddress` | string | `null` | conditional | Only used when proxy is manual. |
| `ProxyUserName` | string | `null` | conditional | Only used when proxy is manual. |
| `ProxyPassword` | string | `null` | conditional | Only used when proxy is manual. Stored in JSON unless externalized. |
| `TimeoutSeconds` | int | `30` | recommended | Used as milliseconds in WebClient wrapper (`* 1000`). |
| `UseDefaultCredentials` | bool | `false` | optional | Sets `client.UseDefaultCredentials`. Can conflict conceptually with explicit `Credentials`. |
| `Headers` | `List<DatabaseSettingParameter>` | `null` | optional | If null, no custom headers are added. UI persists sorted by name. |
| `Encoding` | string | `null` | optional | If set, used for payload bytes and non-GET response decoding. Name must be valid for `Encoding.GetEncoding(...)`. |

#### Inherited (SenderWithResponseSetting → SenderSetting → ActivitySetting → Setting)

The following are **serialized** under the stated System.Text.Json assumption, but some are not defined in the provided “Setting” base code. They are still important to workflow JSON authors.

**Assumed from `Setting` / `ISetting` (base not provided):**

| Field | Type | Default | Required | Notes |
|---|---|---:|---:|---|
| `Id` | GUID | unspecified | yes | Primary activity identifier; referenced by bindings (`FromSetting`). |
| `Name` | string | unspecified | yes | Activity display name. |
| `Version` | int | unspecified | recommended | Drives `Upgrade()` behavior in derived settings. |

**From `ActivitySetting`:**

| Field | Type | Default | Required | Notes |
|---|---|---:|---:|---|
| `Filters` | GUID | `Guid.Empty` | recommended | Enables filters for the activity. |
| `Transformers` | GUID | `Guid.Empty` | recommended | Transformers applied by the base Sender pipeline (implementation not shown here). |
| `FiltersNotAvailable` | bool | unspecified | optional | UI/state flag; often `false`. |
| `TransformersNotAvailable` | bool | unspecified | optional | UI/state flag; often `false`. |
| `DisableNotAvailable` | bool | unspecified | optional | UI/state flag; often `false`. |
| `Disabled` | bool | `false` | recommended | Disabled settings may be saved even when invalid. |
| `Sender` (obsolete) | GUID | `Guid.Empty` | avoid | Legacy field; do not author unless required for legacy compatibility. |

**From `SenderSetting`:**

| Field | Type | Default | Required | Notes |
|---|---|---:|---:|---|
| `MessageTemplate` | string | unspecified | conditional | Payload source for non-GET methods. For GET, payload is ignored by runtime. |
| `MessageType` | enum `MessageTypes` (int) | unspecified | yes | Used to interpret response (binary vs text) and to create the response message object. |
| `MessageTypeOptions` | `IMessageTypeOptions` or null | null | optional | Passed into `GetFunctionMessage` for response construction. Schema is implementation-specific. |
| `InboundMessageNotAvailable` | bool | `false` | optional | UI/state flag; not an HTTP field. |
| `UserCanEditTemplate` | bool | `true` | no | Marked `[JsonIgnore]` in provided code; do not serialize. |

**From `SenderWithResponseSetting`:**

| Field | Type | Default | Required | Notes |
|---|---|---:|---:|---|
| `ResponseMessageTemplate` | string | unspecified | optional | Used primarily for binding/UI sample of response. Not used in HTTP runtime shown. |
| `DifferentResponseMessageType` | bool | unspecified | optional | Used by binding UI logic when binding to a sender’s inbound message. Runtime HTTP sender does not use `ResponseMessageType`. |
| `ResponseMessageType` | enum `MessageTypes` (int) | unspecified | optional | Present in JSON, but runtime HTTP sender uses `MessageType` for response message creation. |
| `ResponseNotAvailable` | bool | computed (override) | avoid authoring | In `HttpSenderSetting`, `ResponseNotAvailable` is computed from `WaitForResponse` and not a stable JSON field to author. |

## Enums and binding semantics

### MessageTypes numeric mapping (provided)

This is the mapping you requested to be treated as authoritative for JSON authoring. Values not listed are **unspecified** here due to missing enum source.

| Numeric | Meaning | Notes for HTTP Sender |
|---:|---|---|
| `1` | HL7 | Used when you want the response interpreted as HL7 (and for HL7 path binding modes in other tools). |
| `4` | XML | Response is treated as text and then interpreted as XML by downstream tooling. |
| `5` | CSV | Response is treated as text and then interpreted as CSV. |
| `11` | JSON | Response is treated as text and then interpreted as JSON (FHIR commonly uses JSON over REST). citeturn6view2turn6view4 |
| `13` | Text | Plain text response handling (label inferred; mapping text was inconsistent, so treat this as “Text” and confirm in your codebase if needed). |
| `14` | Binary | Response bytes are base64-encoded into the response message text. |

Unspecified MessageTypes (exist in code references but numeric values not provided here): `SQL`, `DICOM`, `FHIR`, `HL7V3`, `Unknown`, and the various “Path” pseudo-types used by editors (e.g., `XPath`, `JSONPath`, etc.). When editing workflow JSON, treat these numeric values as **unknown** unless you can access the definitive enum list in your codebase.

### MessageSourceDirection mapping (for header bindings)

Used by `DatabaseSettingParameter.FromDirection`:

| Numeric | Name | Meaning |
|---:|---|---|
| `0` | inbound | Bind from the **inbound/received** message of the source activity. For a sender, “inbound” commonly means the sender’s response. |
| `1` | outbound | Bind from the **outbound/sent** message of the source activity. |
| `2` | variable | Treat `Value` as literal text with `${...}` expansions (no `FromSetting` needed). |

### HttpMethods numeric mapping

Enum order is declaration order:

| Numeric | Method | Runtime behavior |
|---:|---|---|
| `0` | POST | Sends payload using `UploadData`. |
| `1` | GET | No payload is sent; reads response via `OpenRead`. |
| `2` | PUT | Sends payload using `UploadData`. |
| `3` | DELETE | Sends payload using `UploadData` (note: some servers do not accept DELETE bodies). |

### ProxySettings numeric mapping

Enum order is declaration order:

| Numeric | Setting | Meaning |
|---:|---|---|
| `0` | `UseDefaultProxy` | Uses the process default proxy configuration (typically from app.config). |
| `1` | `ManualProxy` | Uses `ProxyAddress` + `ProxyUserName/ProxyPassword`. |
| `2` | `None` | Sets proxy to null (direct connection). |

### Header binding rules

Headers are evaluated at send time as follows:

- Each header entry contributes one call to `client.Headers.Add(headerName, headerValue)`.
- `headerName` is taken directly from `DatabaseSettingParameter.Name` (no normalization).
- `headerValue` is produced by `TransformerAction.GetTheValue(workflowInstance, param.Value, param.FromSetting, param.FromDirection, null)`.

Rules for JSON authors:

- If `FromDirection = 2` (variable):
  - Omit `FromSetting` (or set to `00000000-0000-0000-0000-000000000000`).
  - Use `Value` like `"Bearer ${AccessToken}"`.
  - Set `FromType` to the enum value representing **TextWithVariables** if known; otherwise set it consistently with your tooling’s expectations.
- If `FromDirection = 0` or `1`:
  - `FromSetting` must be a valid activity GUID in the workflow.
  - `Value` must be a path expression that the source message type understands (HL7 path / XPath / CSV index path / JSONPath-like).
  - In practice, `FromType` is a **UI-validation hint** and should match the message type of the source activity (or the sender-response type if `DifferentResponseMessageType` is in play).

Two critical nuances:

- The HTTP sender runtime **does not apply** `Variable.ProcessFormat(value, param)` to headers (unlike the Database Sender). This means `Encoding`, `TextFormat`, `Truncation`, `Lookup`, etc. on `DatabaseSettingParameter` generally **do not affect headers** (unless `GetTheValue` itself applies formatting, which is not visible here).
- The runtime passes `null` namespaces for value extraction. If you rely on XPath with explicit namespaces, header value extraction may not behave as expected.

## Runtime behavior and response formation

### URL and variable expansion

- `Server` is processed at runtime via `ServerRuntimeValue(workflowInstance)`, which calls `workflowInstance.ProcessVariables(Server)`.
- There is **no `config=...` indirection** for HTTP sender URLs in the provided code (unlike database connection strings).

Operational implication: values inserted into the URL are **not URL-encoded** automatically. If `${Variable}` contains spaces, `&`, `?`, or other reserved characters, you must pre-encode or ensure a safe value.

### Request construction

For each send:

- A `WebClientSupportingCertificates` is created with:
  - `TimeoutSeconds * 1000` milliseconds,
  - optional client certificate usage (`UseAuthenticationCertificate`, `AuthenticationCertificateThumbprint`),
  - and `PreAuthenticate`.
- Proxy is applied using `UseProxy`, `ProxyAddress`, `ProxyUserName`, and `ProxyPassword`.
- `UseDefaultCredentials` is applied to the client.
- A `Content-Type` header is always added with `ContentType`.
- Custom headers (if any) are added afterward.

Authentication:

- If `Authentication=true`, credentials are set using `UserName` and `Password`.
- These fields are **not** processed via variable expansion in the sender runtime shown; if you put `${Password}` in JSON, it is sent literally unless your broader system resolves it earlier.

### Payload/body handling

- For `GET`:
  - No payload is sent.
  - Response is read from `OpenRead(url)`.
- For `POST`, `PUT`, `DELETE`:
  - Payload is taken from `workflowInstance.Message?.Text`.
  - It is converted to bytes using:
    - `Encoding.UTF8` by default, OR
    - `Encoding.GetEncoding(Setting.Encoding)` if `Encoding` is provided.

### Response handling, message creation, and binary behavior

Response handling depends on two flags:

- `WaitForResponse` (controls whether response content is retained)
- `MessageType` (controls binary vs text decode)

Behavior:

- The HTTP call always returns a response (or throws) because WebClient methods are synchronous.
- The response bytes are converted into a string `result`:
  - If `MessageType` is `Binary`:
    - `result` becomes a **base64 string** of the response bytes.
  - Else:
    - For non-GET: response bytes are decoded to string using the chosen encoding.
    - For GET: response is read through a default `StreamReader(stream)` (which uses UTF-8 by default), ignoring `Setting.Encoding`.

If `WaitForResponse=true`:
- `responseData` is set to `result`, stored/logged, and becomes the activity’s response message text.

If `WaitForResponse=false`:
- `responseData` remains an empty string, and the activity response message becomes a message created from an empty string.

Message object creation:

- The response message object is created with:
  - `FunctionHelpers.GetFunctionMessage(responseData, Setting.MessageType, Setting.MessageTypeOptions)`
- This uses `MessageType`, not `ResponseMessageType`.

This matters for workflows that want “send JSON but parse CSV response”: the **HTTP sender runtime shown does not support using a different type for response** via `ResponseMessageType`.

### Error and logging behavior

Logs/messages:

- The sent payload (`workflowInstance.Message?.Text`) is recorded in Message Logs as “Sent”.
- `responseData` is recorded as “Response” (which may be empty if `WaitForResponse=false`).
- Debug logs include “Sent” payload and “Received” response (again, possibly empty in one-way mode).

Errors:

- `WebException` is handled by attempting to read `ex.Response` body; if none, uses the exception message (and inner exception message if present).
- Other exceptions call a generic error handler.

TLS/certificate change notification:

- If the certificate validator tracks a “certificate changed/unpinned” message for this URL, a workflow notification is created noting the HTTPS destination certificate update and the message is cleared.

## UI persistence, normalization, and migration behavior

### UI behaviors that shape persisted JSON

The HTTP sender editor influences JSON in ways that AI agents should anticipate:

- **Headers list is saved sorted by header name**. In the UI, `Headers = Parameters.OrderBy(i => i).ToList()`. This makes ordering stable but means you cannot rely on authoring order being preserved in JSON.
- GET method hides the outbound template editor in UI, but the JSON still carries `MessageTemplate` and `ContentType`. Runtime still sets `Content-Type` header even for GET.
- Encoding selection UI offers a limited set of encodings and attempts to default to UTF-8; however, the save path uses `"uft-8"` if the encoding combobox text is empty. This is a non-obvious hazard for JSON authors (see pitfalls).
- For new settings created in the UI, the MessageTemplate is auto-bound to the workflow root inbound message using the `${<RootSettingId> inbound}` pattern (GUID-based binding).

### Upgrade and Version behavior

`HttpSenderSetting.Upgrade()` contains one explicit migration:

- If `Version < 2`, it forces `TimeoutSeconds = 30` before calling base upgrade.

This aligns with the product’s historical evolution where HTTP sender timeout became adjustable. citeturn6view1

### SwapActivityIds behavior

When a workflow is imported or IDs are remapped, `HttpSenderSetting.SwapActivityIds(...)` explicitly:

- rewrites activity references inside `MessageTemplate` via `FunctionHelpers.ReplaceActivity(...)`
- then defers to base behavior (`base.SwapActivityIds(...)`)

Non-obvious consequence:

- Only `MessageTemplate` is explicitly rewritten here. If your `Server` URL or header `Value` strings embed activity references (e.g., `${<SomeGuid> inbound}`), they may not be rewritten unless the base class handles them. For robust portability, prefer:
  - workflow variables, or
  - header bindings using structured `FromSetting` GUID fields (which are reliably rewritable by tooling)

## Non-obvious pitfalls and security concerns

### `WaitForResponse` does not make HTTP “fire-and-forget”

Even with `WaitForResponse=false`, the sender uses synchronous WebClient calls (`OpenRead`, `UploadData`) and therefore still blocks until completion or timeout. The practical effect is: response is simply discarded/emptied in workflow state, not avoided.

### Response type mismatch hazards

Because the response message is created using `MessageType` (not `ResponseMessageType`), do not rely on `DifferentResponseMessageType/ResponseMessageType` to “reinterpret” the response. If you set those fields in JSON to make UI binding trees convenient but keep `MessageType` different, you risk:

- UI binding assumptions differing from runtime response message type
- path extraction failures at runtime

### Encoding hazards and GET inconsistency

- If `Encoding` is set to an invalid encoding name, `Encoding.GetEncoding(...)` will throw and the sender will error.
- The editor save path includes a fallback typo `"uft-8"` if the UI encoding box is empty; if this string ends up in JSON, it will cause runtime failure.
- For GET requests, response is read using a default `StreamReader(stream)` rather than the configured encoding; this can corrupt responses not encoded in UTF-8.

### Header binding has no formatting layer

Unlike Database Sender parameters, HTTP header values are not passed through `Variable.ProcessFormat`. If you need trimming, casing, truncation, or lookup mapping, you must:

- implement it upstream (transformers/variables), or
- embed it into the `Value` logic if your variable system supports formatting

### Credentials and secrets in JSON

The following are persisted as plain JSON strings:

- `Password`
- `ProxyPassword`
- potentially token-like values in `Headers` (e.g., Authorization bearer tokens)

Treat workflow JSON as sensitive. For workflows that must be portable, prefer storing secrets as server-side configuration or secret stores and pull them into variables at runtime (product-specific mechanisms).

### Logging can leak PHI/PII and tokens

The sender logs:

- full payload text (“Sent”)
- full response text (“Response”)

If you send FHIR/JSON with PHI, or if your payload includes credentials/tokens, those can end up in logs. The FHIR spec explicitly notes that PHI may appear in search parameters and therefore in HTTP logs, and that logs must be treated as sensitive. citeturn6view4 (This concern applies broadly to REST/HTTP integrations.)

### URL/query-string exposure

If you embed PHI or credentials in `Server` query strings (e.g., `...?PatientID=${PatientId}`), those values are more likely to appear in:

- infrastructure logs (reverse proxies, gateways)
- browser-like tracing
- server access logs

Prefer headers or body content when possible, and treat logs as sensitive.

### Custom headers and restricted header names

WebClient historically restricts some headers or treats them specially (e.g., Host, Content-Length). Because the sender unconditionally adds `Content-Type` and then applies custom headers, avoid duplicating `Content-Type` in `Headers` unless you have confirmed behavior in your runtime.

## External Resources appendix

Primary sources are prioritized from IntegrationSoup.com and HL7 Interfacer. Links are provided without inline commentary to match “appendix style.”

### IntegrationSoup.com

- https://www.integrationsoup.com/WhatsNewInV3.1.html citeturn6view2  
- https://www.integrationsoup.com/WhatsNewInV3.3.html citeturn6view1  
- https://www.integrationsoup.com/dicomtutorialsendtorestapi.html citeturn6view3  
- https://www.integrationsoup.com/HL7TutorialSecuringHL7MessagesWithHTTPOverSSL.html citeturn6view0  
- https://www.integrationsoup.com/HL7TutorialHTTPPortBinding.html citeturn4search7  
- https://www.integrationsoup.com/IntegrationHostAWS.html citeturn4search3  
- https://www.integrationsoup.com/IntegrationHostSSLAWS.html citeturn4search6  
- https://www.integrationsoup.com/HL7TutorialIntegrationHostWorkflowDesigner.html citeturn0search11  
- https://www.integrationsoup.com/IntegrationHostGettingStarted.html citeturn3search1  
- https://www.integrationsoup.com/HL7Tutorials.html citeturn4search4  

### HL7 Interfacer Blog

- https://hl7interfacer.blogspot.com/ citeturn5search2  
- https://hl7interfacer.blogspot.com/2016/07/mirth-certificateexception-no-name.html citeturn2search0  

### Optional authoritative protocol reference

- https://www.hl7.org/fhir/http.html citeturn6view4