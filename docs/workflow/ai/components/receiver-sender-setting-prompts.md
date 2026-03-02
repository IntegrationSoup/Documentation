# Receiver/Sender JSON Generation Guide

This page defines practical rules for generating receiver/sender setting JSON that can be assembled into a valid `WorkflowFile`.

The rules are derived from the same behavior used by the AI workflow tooling, but written as product-facing generation guidance.

---

## Scope

- Generate activity setting objects only.
- One receiver per workflow, followed by zero or more senders.
- Filter and transformer objects are generated in later steps and linked by GUID references.

Use this with:

- [WorkflowFile](../api/workflowfile.md)
- [Transformer Setting](../reference/transformer-setting.md)
- [Filter Host Setting](../reference/filter-host-setting.md)

---

## Required input before generating JSON

Collect these first:

- inbound source protocol and endpoint details
- inbound message type
- outbound actions (one sender per action)
- sender endpoint/connection details
- message templates to preserve (if supplied)
- variable/filter/transform requirements (as separate instruction text)

If any required connection detail is missing, omit that property rather than inventing values.

---

## Type selection rules

Select exactly one receiver type and one type per sender action.

### Receiver mapping

| Integration intent | Use setting type | Activity doc |
|---|---|---|
| TCP / MLLP inbound | `MLLPReceiverSetting` | [MLLP Receiver](../receiver-activities/mllp-receiver.md) |
| HTTP / REST inbound | `HttpReceiverSetting` | [HTTP Receiver](../receiver-activities/http-receiver.md) |
| SOAP / WCF inbound | `WebServiceReceiverSetting` | [Web Service Receiver](../receiver-activities/web-service-receiver.md) |
| Directory/file polling | `DirectoryScanReceiverSetting` | [Directory Scan Receiver](../receiver-activities/directory-scan-receiver.md) |
| Database polling | `DatabaseReceiverSetting` | [Database Reader](../receiver-activities/database-reader.md) |
| Scheduled trigger | `TimerReceiverSetting` | [Timer Receiver](../receiver-activities/timer-receiver.md) |
| DICOM inbound | `DicomReceiverSetting` | [DICOM Receiver](../receiver-activities/dicom-receiver.md) |

### Sender mapping

| Integration intent | Use setting type | Activity doc |
|---|---|---|
| TCP / MLLP outbound | `MLLPSenderSetting` | [MLLP Sender](../sender-activities/mllp-sender.md) |
| HTTP / REST outbound | `HttpSenderSetting` | [HTTP Sender](../sender-activities/http-sender.md) |
| SOAP / WCF outbound | `WebServiceSenderSetting` | [Web Service Sender](../sender-activities/web-service-sender.md) |
| Write to file | `FileWriterSenderSetting` | [File Writer](../sender-activities/file-writer.md) |
| SQL query/command sender | `DatabaseSenderSetting` | [Database Query](../sender-activities/database-query.md) |
| DICOM outbound | `DicomSenderSetting` | [DICOM Sender](../sender-activities/dicom-sender.md) |
| No native sender equivalent | `CodeSenderSetting` | [Code Sender](../sender-activities/code-sender.md) |

Hard rule: there is no code receiver.

---

## JSON output rules for each activity object

For each receiver/sender setting object:

- include explicit `$type` for deterministic import
- include only serialized, supported properties for that setting class
- keep `Id` unique and valid GUID text
- preserve provided message templates exactly (no edits/reformatting)
- do not embed filter/transformer object payloads inside instruction fields

Do not add internal or inferred properties that are not part of the serialized contract.

---

## Assembly rules in `WorkflowPattern`

When you assemble the final workflow settings array:

1. receiver must be first
2. sender settings follow receiver
3. any referenced GUIDs in activity links must point to objects present in the same file
4. filter/transformer host references are attached after activity setting generation

Keep top-level workflow metadata aligned with the receiver identity (see [WorkflowFile](../api/workflowfile.md)).

---

## Deterministic generation sequence

1. Choose receiver type from integration intent.
2. Generate receiver setting JSON (serialized properties only).
3. Choose sender type for each outbound action.
4. Generate one sender setting JSON object per action.
5. Build `WorkflowPattern` with receiver first, then senders.
6. Generate and attach filters/transformers/variable transformers by ID references.
7. Run final JSON validation checklist before import.

---

## Minimal shape example (activity settings only)

```json
[
  {
    "$type": "HL7Soup.Functions.Settings.Receivers.MLLPReceiverSetting, HL7SoupWorkflow",
    "Id": "11111111-1111-1111-1111-111111111111",
    "Name": "Inbound MLLP",
    "MessageType": 1
  },
  {
    "$type": "HL7Soup.Functions.Settings.Senders.HttpSenderSetting, HL7SoupWorkflow",
    "Id": "22222222-2222-2222-2222-222222222222",
    "Name": "Forward To API",
    "MessageType": 11
  }
]
```

Use this as shape guidance only. Real payloads must include each class’s required connection/behavior fields.

---

## Validation checklist (before import)

- exactly one receiver exists
- all sender types match the intended outbound actions
- all `Id` values are unique GUIDs
- every cross-reference ID resolves to an existing object
- enum fields use expected serialized representation
- no unsupported or non-serialized fields were added
- message templates are unchanged from provided source content

---

## Common failure outcomes

- selecting multiple receivers in one workflow
- choosing an activity type that does not match protocol intent
- placing mapping/filter logic into generic connection `Instructions`
- losing template fidelity by rewriting user/import-provided payload templates
- generating structurally valid JSON that is not operationally complete due to missing required connection fields
