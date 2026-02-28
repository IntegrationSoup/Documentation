# **HTTP Sender (HttpSenderSetting)**

The **HTTP Sender** activity sends the current workflow message to an HTTP/HTTPS endpoint. In a workflow JSON file, it is configured via a serialized `HttpSenderSetting` object.

This guide documents **only the JSON fields you can set** that affect HTTP Sender behavior.

---

## JSON shape

### Minimal working shape (recommended starting point)

```json
{
  "Server": "https://api.example.com/endpoint",
  "Method": 0,
  "ContentType": "application/json",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "Headers": [],
  "Authentication": false,
  "UseAuthenticationCertificate": false,
  "UseProxy": 0,
  "Encoding": "utf-8"
}
```

### Fields (only those that affect behavior)

#### Request target and method

* **Server** (string)
  Target URL. Typically supports variable substitution (e.g., `${PatientId}`) based on your workflow’s variable system.

* **Method** (int enum: `HttpMethods`)
  HTTP verb used when sending.

* **ContentType** (string)
  Value used for the HTTP `Content-Type` header.

#### Response retention

* **WaitForResponse** (bool)
  Controls whether the response body is captured into the activity’s response message for downstream use.

  * `true`: response body becomes available to downstream activities
  * `false`: request still executes, but response body is not retained for workflow use

> Note: This is about *retention*, not “async send”. It’s still a normal request/response call, you’re just choosing whether to keep the response content.

#### Authentication (basic credentials)

* **Authentication** (bool)
  Enables HTTP credential-based authentication.

* **UserName** (string)
  Used only when `Authentication=true`.

* **Password** (string)
  Used only when `Authentication=true`.

#### Client certificate (mutual TLS)

* **UseAuthenticationCertificate** (bool)
  Enables attaching a client certificate.

* **AuthenticationCertificateThumbprint** (string)
  The certificate thumbprint to locate in the machine/user certificate store (depending on how Integration Soup is configured).

* **PreAuthenticate** (bool)
  Controls whether credentials are offered eagerly (if applicable to the configured auth mode).

#### Proxy

* **UseProxy** (int enum: `ProxySettings`)
  Chooses default proxy behavior, manual proxy, or no proxy.

* **ProxyAddress** (string)
  Used only when `UseProxy=1` (manual proxy).

* **ProxyUserName** (string)
  Optional, for manual proxy auth.

* **ProxyPassword** (string)
  Optional, for manual proxy auth.

#### Timeout and credentials mode

* **TimeoutSeconds** (int)
  Request timeout.

* **UseDefaultCredentials** (bool)
  Enables “use the service account / process identity credentials” behavior where applicable.

#### Encoding

* **Encoding** (string)
  Controls how text request bodies are encoded to bytes and how response bytes are decoded to text (when applicable). Typical values: `"utf-8"`, `"windows-1252"`.

---

## Headers

### Supported header object (what actually works)

Headers are stored as a list. For HTTP Sender, treat each item as **one HTTP header**.

**Use only these fields:**

```json
{
  "Name": "Accept",
  "Value": "application/json",
  "FromDirection": 2,
  "FromSetting": "00000000-0000-0000-0000-000000000000"
}
```

#### Header fields

* **Name** (string)
  Header name, e.g. `Authorization`, `Accept`, `X-Correlation-Id`.

* **Value** (string)
  Either a literal header value, or a binding/path depending on `FromDirection`.

* **FromDirection** (int enum: `MessageSourceDirection`)
  Defines how to interpret `Value`.

* **FromSetting** (guid string)
  Used only when binding to another activity’s message.

### What NOT to include in headers

Do **not** include formatting fields like:

* `Encoding`, `TextFormat`, `Truncation`, `TruncationLength`, `PaddingLength`, `Lookup`, `Format`

If they exist on a shared parameter object elsewhere, they are **not supported for HTTP headers** and should be omitted to avoid implying they do something.

---

## Enum values (JSON numeric mappings)

### HttpMethods

| Value | Name   |
| ----: | ------ |
|     0 | POST   |
|     1 | GET    |
|     2 | PUT    |
|     3 | DELETE |

### ProxySettings

| Value | Name            |
| ----: | --------------- |
|     0 | UseDefaultProxy |
|     1 | ManualProxy     |
|     2 | None            |

### MessageSourceDirection (for Headers)

| Value | Name     | Meaning for Headers.Value                                            |
| ----: | -------- | -------------------------------------------------------------------- |
|     0 | inbound  | `Value` is a path into another activity’s *inbound/received* message |
|     1 | outbound | `Value` is a path into another activity’s *outbound/sent* message    |
|     2 | variable | `Value` is literal text with variable substitution (`${...}`)        |

### MessageTypes (from your enum)

Numeric values are by enum order starting at 0:

| Value | Name              |
| ----: | ----------------- |
|     0 | Unknown           |
|     1 | HL7V2             |
|     2 | HL7V3             |
|     3 | FHIR              |
|     4 | XML               |
|     5 | CSV               |
|     6 | SQL               |
|     7 | TextWithVariables |
|     8 | HL7V2Path         |
|     9 | XPath             |
|    10 | CSVPath           |
|    11 | JSON              |
|    12 | JSONPath          |
|    13 | Text              |
|    14 | Binary            |
|    15 | MessageStructure  |
|    16 | DICOM             |

> In HTTP Sender workflows, `MessageType` is typically one of: `11 (JSON)`, `4 (XML)`, `13 (Text)`, or `14 (Binary)`.

---

## Practical use cases (JSON examples)

### 1) POST JSON to an API with a bearer token

```json
{
  "Server": "https://api.example.com/patients",
  "Method": 0,
  "ContentType": "application/json",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "Encoding": "utf-8",
  "Headers": [
    {
      "Name": "Authorization",
      "Value": "Bearer ${AccessToken}",
      "FromDirection": 2,
      "FromSetting": "00000000-0000-0000-0000-000000000000"
    },
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromSetting": "00000000-0000-0000-0000-000000000000"
    }
  ]
}
```

### 2) GET JSON from an endpoint (response retained)

```json
{
  "Server": "https://api.example.com/patients/${PatientId}",
  "Method": 1,
  "ContentType": "application/json",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "Headers": [
    {
      "Name": "Accept",
      "Value": "application/json",
      "FromDirection": 2,
      "FromSetting": "00000000-0000-0000-0000-000000000000"
    }
  ]
}
```

### 3) Fire-and-forget style call (don’t retain body)

Use this when you only care that the endpoint was called (or the endpoint returns irrelevant content).

```json
{
  "Server": "https://api.example.com/audit",
  "Method": 0,
  "ContentType": "application/json",
  "WaitForResponse": false,
  "TimeoutSeconds": 10,
  "Headers": []
}
```

### 4) Basic auth (username/password)

```json
{
  "Server": "https://legacy.example.com/hl7",
  "Method": 0,
  "ContentType": "text/plain",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "Authentication": true,
  "UserName": "apiuser",
  "Password": "apipassword",
  "Headers": []
}
```

### 5) mTLS client certificate (thumbprint)

```json
{
  "Server": "https://partner.example.com/ingest",
  "Method": 0,
  "ContentType": "application/json",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "UseAuthenticationCertificate": true,
  "AuthenticationCertificateThumbprint": "0123456789ABCDEF0123456789ABCDEF01234567",
  "Headers": []
}
```

### 6) Manual proxy (with proxy credentials)

```json
{
  "Server": "https://api.example.com/submit",
  "Method": 0,
  "ContentType": "application/json",
  "WaitForResponse": true,
  "TimeoutSeconds": 30,
  "UseProxy": 1,
  "ProxyAddress": "http://proxy.company.local:8080",
  "ProxyUserName": "DOMAIN\\proxyuser",
  "ProxyPassword": "proxypass",
  "Headers": []
}
```

---

## Non-obvious outcomes and pitfalls (without internal details)

* **`WaitForResponse=false` does not mean “async”.** It means “don’t keep the response body for downstream workflow use.”
* **`Encoding` matters when you send or receive text content** (especially with non-UTF8 systems). If your endpoint expects `"windows-1252"` or similar, set it explicitly.
* **Header binding formatting is not supported.** Keep header values as literal strings, variable substitutions, or valid paths based on `FromDirection`.
* **If you need to treat a response as Binary**, you should configure the workflow message typing accordingly (commonly `MessageType=14` at the sender level in Integration Soup patterns).

---

## External Resources

* [HL7 Tutorials](https://www.integrationsoup.com/hl7tutorials.html)
* [Integration Host Workflow Designer Tutorial](https://www.integrationsoup.com/hl7tutorialintegrationhostworkflowdesigner.html)
* [Securing HL7 messages with HTTPS over SSL/TLS](https://www.integrationsoup.com/hl7tutorialsecuringhl7messageswithhttpoverssl.html)
* [Sending DICOM Tags to a Web API or REST Service](https://www.integrationsoup.com/dicomtutorialsendtorestapi.html)
* [HL7 Interfacer Blog](https://hl7interfacer.blogspot.com/)

