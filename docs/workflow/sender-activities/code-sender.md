# **Code Sender (CodeSenderSetting)**

## What this setting controls

`CodeSenderSetting` runs C# script code inside workflow execution.

It controls:

- the script source code
- whether a response message object is pre-created
- response template/type defaults used for that pre-created response
- variable-name declarations used for designer/binding discoverability

This page documents serialized JSON fields and runtime behavior.

## Runtime model

```mermaid
flowchart TD
    A[Prepare activity] --> B[Compile Code into script delegate]
    B --> C{UseResponse}
    C -- false --> D[Run script with workflowInstance + activityInstance]
    C -- true --> E[Create initial response message object]
    E --> D
    D --> F[Script reads/updates messages and variables]
    F --> G[Response (if present) becomes activity response]
```

Important non-obvious behavior:

- script compilation happens during prepare, not first message send.
- compile failures block execution before normal message processing.
- `VariableNames` does not enforce runtime behavior; it is metadata.
- `ResponseMessageType` materially changes response object initialization when `UseResponse = true`.

## JSON shape

Typical serialized shape:

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.CodeSenderSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Run Custom Logic",
  "Version": 3,
  "MessageType": 1,
  "MessageTypeOptions": null,
  "MessageTemplate": "${11111111-1111-1111-1111-111111111111 inbound}",
  "UseResponse": true,
  "ResponseMessageTemplate": "MSH|^~\\&|SRC|FAC|DST|FAC|${ReceivedDate}||ACK^A01|1|P|2.5.1\\rMSA|AA|1",
  "ResponseMessageType": 1,
  "DifferentResponseMessageType": false,
  "Code": "workflowInstance.SetVariable(\"MyVariable\", \"42\");",
  "VariableNames": [
    "MyVariable"
  ],
  "Filters": "00000000-0000-0000-0000-000000000000",
  "Transformers": "00000000-0000-0000-0000-000000000000",
  "Disabled": false
}
```

## Script fields

### `Code`

C# script source compiled and executed by Roslyn scripting engine.

Runtime context (`globals`) provides:

- `workflowInstance`
- `activityInstance`

Additional script conveniences are available through `CodeContext` methods/properties exposed by that globals type.

Runtime outcomes:

- compile errors fail prepare with compile-oriented error text.
- runtime script exceptions fail current workflow instance and return script stack trace context.
- common HL7Soup and .NET data access references/imports are preloaded.

### `VariableNames`

List of variable names this setting declares as potential outputs.

Important outcomes:

- binding tree/discoverability metadata.
- not runtime-enforced.
- missing names here can make script-created variables harder to discover in UI-driven binding.

## Message and response fields

### `MessageType`

Editor allows:

- `1` = `HL7`
- `4` = `XML`
- `5` = `CSV`
- `11` = `JSON`
- `13` = `Text`
- `14` = `Binary`
- `16` = `DICOM`

### `MessageTypeOptions`

Serialized via shared sender infrastructure; used for message creation paths where relevant.

### `MessageTemplate`

Initial activity message source before script runs.

### `UseResponse`

Controls whether runtime pre-creates `activityInstance.ResponseMessage` before script execution.

### `ResponseMessageTemplate`

Template used when pre-creating response object.

Important runtime outcome:

- this template is not automatically variable-processed before creation in this sender path.

### `ResponseMessageType`

Controls pre-created response type when `UseResponse = true`.

Initialization behavior:

- if explicit non-unknown value: use that type.
- if unknown and template is blank: fallback to activity `MessageType`.
- if unknown and template is non-blank: infer type from template text.

### `DifferentResponseMessageType`

Serialized inherited field; can appear in JSON.

Practical outcome:

- this sender’s response-object initialization logic is driven by `UseResponse`, `ResponseMessageType`, and `ResponseMessageTemplate`.

## Workflow linkage fields

### `Filters`

GUID of sender filters.

### `Transformers`

GUID of sender transformers.

### `Disabled`

If `true`, activity is disabled.

### `Id`

Activity GUID.

### `Name`

User-facing activity name.

## UI behavior that affects JSON authors

- dialog can auto-extract `VariableNames` by scanning script text for `SetVariable("...")` patterns.
- this extraction is literal/pattern-based; dynamic or differently formatted variable writes can be missed.
- response-type advanced fields are not deeply surfaced in UI flow; manual JSON `ResponseMessageType` can be reset to defaults on round-trip save if not re-authored through supported controls.

## Defaults

New `CodeSenderSetting` defaults:

- `UseResponse = false`
- `VariableNames = []`
- `Code` starts with sample script template

## Pitfalls and hidden outcomes

- compile-time failures happen before message processing and can stop activity startup.
- `VariableNames` does not constrain what script can set.
- `UseResponse = true` does not guarantee useful response content unless script updates it appropriately.
- leaving `ResponseMessageType` as unknown makes response type inference sensitive to template content.
- script can compile but still fail at runtime due type-casting assumptions.

## Examples

### Variable-only script with no pre-created response

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.CodeSenderSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "Set Variables",
  "MessageType": 13,
  "MessageTemplate": "",
  "UseResponse": false,
  "Code": "workflowInstance.SetVariable(\"PatientKey\", \"12345\");",
  "VariableNames": [
    "PatientKey"
  ]
}
```

### HL7 ACK builder with explicit response type

```json
{
  "$type": "HL7Soup.Functions.Settings.Senders.CodeSenderSetting, HL7SoupWorkflow",
  "Id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
  "Name": "Build ACK",
  "MessageType": 1,
  "MessageTemplate": "${11111111-1111-1111-1111-111111111111 inbound}",
  "UseResponse": true,
  "ResponseMessageType": 1,
  "ResponseMessageTemplate": "MSH|^~\\&|SRC|FAC|DST|FAC|${ReceivedDate}||ACK^A01|1|P|2.5.1\\rMSA|AA|1",
  "Code": "var msg = (IHL7Message)activityInstance.ResponseMessage; msg.SetValueAtPath(\"MSA-1\", \"AA\");",
  "VariableNames": []
}
```

## Useful public references

- [Integration Soup](https://www.integrationsoup.com/)
- [Using Variables in HL7 Soup](https://www.integrationsoup.com/hl7tutorialusingvariables.html)
- [Using Transformers](https://www.integrationsoup.com/hl7tutorialusingtransformers.html)
