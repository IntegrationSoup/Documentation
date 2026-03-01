# Workflow Enum and Interface Reference

This page is the canonical reference for shared enum values and interface-level contracts used across workflow sender/receiver JSON.

Use this page for the full numeric mappings. Activity pages should keep local summaries focused on activity-specific behavior.

## Serialization rules

- Workflow JSON stores enum values as numeric integers.
- Use numeric values for deterministic JSON authoring and tooling.
- `MessageType` and `FromType` are different contracts and must not be mixed.

## Message and path enums

### `MessageType` and `ResponseMessageType` (activity message object type)

These values describe the message object created/used by the activity.

| Value | Name | Typical usage in workflow settings |
|---|---|---|
| `0` | `Unknown` | Placeholder/default in inherited response fields. |
| `1` | `HL7V2` (`HL7`) | HL7 v2 payloads and ACK-driven workflows. |
| `4` | `XML` | XML payload parsing and XML path access. |
| `5` | `CSV` | CSV row/message payloads. |
| `6` | `SQL` | SQL text in Database Query sender `MessageTemplate`. |
| `11` | `JSON` | JSON payload parsing and JSON path access. |
| `13` | `Text` | Plain text payloads. |
| `14` | `Binary` | Binary/base64-style payload handling. |
| `16` | `DICOM` | DICOM message workflows. |

### `FromType` (binding/value extraction interpretation)

These values describe how a binding expression should be interpreted, not what the message object type is.

| Value | Name | Meaning |
|---|---|---|
| `7` | `TextWithVariables` | Literal text with `${Variable}` expansion. |
| `8` | `HL7V2Path` | HL7 path syntax (for example `PID-5.1`). |
| `9` | `XPath` | XML/XPath-style extraction. |
| `10` | `CSVPath` | CSV path/field addressing. |
| `12` | `JSONPath` | JSON path extraction. |

## Direction and response enums

### `FromDirection` (`MessageSourceDirection`)

| Value | Name | Meaning |
|---|---|---|
| `0` | `inbound` | Read from an activity's inbound side. |
| `1` | `outbound` | Read from an activity's outbound/response side. |
| `2` | `variable` | Read from workflow/global variable text. |

### `ReponsePriority` (`ReturnResponsePriority`)

| Value | Name | Meaning |
|---|---|---|
| `0` | `UponArrival` | Return as soon as a message is accepted. |
| `1` | `AfterValidation` | Return after validation stage. |
| `2` | `AfterAllProcessing` | Return after activity processing completes. |

## Transport and connection enums

### HTTP sender `Method` (`HttpMethods`)

| Value | Name |
|---|---|
| `0` | `POST` |
| `1` | `GET` |
| `2` | `PUT` |
| `3` | `DELETE` |

### HTTP/Web Service sender `UseProxy` (`ProxySettings`)

| Value | Name | Meaning |
|---|---|---|
| `0` | `UseDefaultProxy` | Use host-default proxy behavior. |
| `1` | `ManualProxy` | Use `ProxyAddress`/credentials fields. |
| `2` | `None` | Disable proxy usage for request client. |

### MLLP sender/receiver `AuthenticationType`

| Value | Name | Meaning |
|---|---|---|
| `0` | `None` | No client-auth requirement. |
| `1` | `Basic` | Serialized; not meaningfully enforced for MLLP transport. |
| `2` | `Certificate` | Certificate-auth mode (thumbprint-driven). |

## Database enums

### `DataProvider` (`DataProviders`)

| Value | Name |
|---|---|
| `0` | `SqlClient` |
| `1` | `OracleClient` |
| `2` | `OleDb` |
| `3` | `Odbc` |
| `4` | `SqlClientOld` |
| `5` | `MySql` |
| `6` | `PostgreSql` |
| `7` | `Sqlite` |

## Directory receiver enums

### `ErrorAction` (`ErrorActions`)

| Value | Name | Meaning |
|---|---|---|
| `0` | `StopWorkflow` | Stop workflow on file error. |
| `1` | `Retry` | Retry file processing. |
| `2` | `MoveToDirectory` | Move errored file to error directory. |
| `3` | `Delete` | Delete errored file. |

### `LineSeperator` (`LineSeperators`)

| Value | Name |
|---|---|
| `0` | `Unspecified` |
| `1` | `cr` |
| `2` | `lf` |
| `3` | `crlf` |
| `4` | `crOrLf` |
| `5` | `lfExceptWithinQuotes` |
| `6` | `crExceptWithinQuotes` |

## Variable metadata enum

### `VariableType` (for serialized variable-descriptor objects)

| Value | Name |
|---|---|
| `0` | `Workflow` |
| `1` | `System` |
| `2` | `Global` |

## Integrations API interfaces (public code API)

The following interfaces are public in `HL7Soup.Integrations` and are safe to reference as interface contracts in API-oriented docs:

- `IMessage`
- `IHL7Message`
- `IMessageTypeOptions`
- `MessageTypes`

Interface-level guides:

- [IMessage in Integration Soup](../api/imessage.md)
- [IHL7Message Guide](../api/Ihl7message.md)
- [IWorkflowInstance and IActivityInstance Guide](../api/workflowinstance.md)
- [CodeContext Guide](../api/codingcontext.md)

Workflow JSON root object guide:

- [WorkflowFile in Integration Soup](../api/workflowfile.md)

## Authoring pitfalls to avoid

- Do not use `MessageType` values in `FromType` fields.
- Do not assume `ResponseMessageType` controls runtime response conversion for every sender.
- Avoid relying on textual enum names in generated JSON; numeric values are the compatibility contract.
