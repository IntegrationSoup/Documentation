# AI Workflow Structure (AiWorkflowStructure)
**Definitive JSON Contract + Runtime API Notes**

`AiWorkflowStructure` is the AI planning contract used before a real `WorkflowFile` is built.

It is an intermediate model for:
- interpreting user intent
- describing receiver/sender behavior
- producing filter/transformer instructions
- then materializing concrete receiver/sender/filter/transformer settings

It is not the executable workflow JSON format.  
For executable workflow JSON, use [WorkflowFile](../api/workflowfile.md).

---

## Where it fits in the pipeline

```mermaid
flowchart LR
    A[User Requirements] --> B[GetAIWorkflowStructureFromAiApi]
    B --> C[AiWorkflowStructure JSON]
    C --> D[Validate + Refine]
    D --> E[Create Receiver/Sender Settings]
    E --> F[Create Filters + Transformer Actions]
    F --> G[WorkflowFile JSON]
```

---

## JSON contract (object shape)

Top-level object:

```json
{
  "ReceiverActivity": {
    "MessageSource": "TCP",
    "MessageType": "HL7",
    "ImportData": "",
    "Instructions": "",
    "PreFilter": {
      "Instruction": "",
      "ImportData": "",
      "Comment": "",
      "CodeRequired": false
    },
    "Filters": [
      {
        "Instruction": "",
        "ImportData": ""
      }
    ],
    "VariableTransformers": [
      {
        "Instruction": "",
        "ImportData": "",
        "Comment": "",
        "CodeRequired": false
      }
    ],
    "MessageTemplate": "",
    "ReturnedMessageTransformers": [
      {
        "Instruction": "",
        "ImportData": "",
        "Comment": "",
        "CodeRequired": false
      }
    ],
    "ReturnedMessageTemplate": "",
    "Id": "3f1a6d88-2d62-4f87-bcd3-60ab35717dc1"
  },
  "SenderActivities": [
    {
      "Id": "c0609ca2-1f11-4b17-b0db-cc15fb8cf24f",
      "SenderAction": "HTTP",
      "Name": "Post to API",
      "MessageType": "JSON",
      "ImportData": "",
      "Instructions": "",
      "PreFilter": {
        "Instruction": "",
        "ImportData": "",
        "Comment": "",
        "CodeRequired": false
      },
      "Filters": [
        {
          "Instruction": "",
          "ImportData": ""
        }
      ],
      "Transformers": [
        {
          "Instruction": "",
          "ImportData": "",
          "Comment": "",
          "CodeRequired": false
        }
      ],
      "MessageTemplate": "",
      "ReturnedMessageTemplate": ""
    }
  ],
  "GlobalVariables": [
    "ApiBaseUrl"
  ]
}
```

Runtime-only property (not part of the schema-driven AI response contract):

```json
{
  "ImportedFrom": "Mirth"
}
```

---

## Field definitions

## `AiWorkflowStructure`

| Property | Type | Meaning |
|---|---|---|
| `ReceiverActivity` | object | Required planning description of the source/receiver stage. |
| `SenderActivities` | array | Ordered list of sender stage plans. |
| `GlobalVariables` | array of string | Names of global variables referenced by the design/import context. |
| `ImportedFrom` | string | Runtime metadata for import context (for example `Mirth`), used for conversion hints. |

## `AiReceiverActivity`

| Property | Type | Meaning |
|---|---|---|
| `MessageSource` | string | Logical source family. |
| `MessageType` | string | Logical payload type. |
| `ImportData` | string | Raw imported source config text (verbatim). |
| `Instructions` | string | Human-language receiver requirements/config. |
| `PreFilter` | `AiTransformerSet` | Variable/setup instruction block intended before filters. |
| `Filters` | array of `AiFilterSet` | Receiver filter rule instruction groups. |
| `VariableTransformers` | array of `AiTransformerSet` | Variable creation/update instruction groups. |
| `MessageTemplate` | string | Inbound sample/template used for path and mapping context. |
| `ReturnedMessageTransformers` | array of `AiTransformerSet` | Final response-transform instruction groups. |
| `ReturnedMessageTemplate` | string | Response template intent (for return path). |
| `Id` | string (GUID) | Activity identifier hint; auto-generated if invalid/missing. |

## `AiSenderActivity`

| Property | Type | Meaning |
|---|---|---|
| `Id` | string (GUID) | Sender activity identifier hint; auto-generated if invalid/missing. |
| `SenderAction` | string | Intended sender family/action type. |
| `Name` | string | Friendly sender name. |
| `MessageType` | string | Sender payload type. |
| `ImportData` | string | Raw imported sender config text (verbatim). |
| `Instructions` | string | Human-language sender requirements/config. |
| `PreFilter` | `AiTransformerSet` | Variable/setup instruction block intended before sender filters. |
| `Filters` | array of `AiFilterSet` | Sender filter rule instruction groups. |
| `Transformers` | array of `AiTransformerSet` | Sender transform/mapping instruction groups. |
| `MessageTemplate` | string | Outbound message template intent. |
| `ReturnedMessageTemplate` | string | Sender response template intent. |

## `AiFilterSet`

| Property | Type | Meaning |
|---|---|---|
| `Instruction` | string | Filter intent text. |
| `ImportData` | string | Raw imported filter config text. |

## `AiTransformerSet`

| Property | Type | Meaning |
|---|---|---|
| `Instruction` | string | Transformation intent text. |
| `ImportData` | string | Raw imported transform config text. |
| `Comment` | string | Optional user-facing heading/summary. |
| `CodeRequired` | boolean | Indicates this set should be treated as code-oriented. |

---

## Pseudo-enum value conventions

These are string conventions used by generation and validation, not strongly typed C# enums in this contract.

`ReceiverActivity.MessageSource`:
- `TCP`
- `HTTP`
- `SOAP`
- `Database`
- `Timer`
- `File`

`ReceiverActivity.MessageType` and `SenderActivities[].MessageType`:
- `HL7`
- `XML`
- `CSV`
- `SQL`
- `JSON`
- `Binary`

`SenderActivities[].SenderAction` canonical set used by repair/validation flow:
- `TCP`
- `Database`
- `File`
- `HTTP`
- `SOAP`
- `Dicom`
- `Code`

---

## API surface

Primary API call returns this structure from:

- user requirements text
- system rule text
- model identifier

Companion validation call uses the same inputs and returns a validation result object used for iterative correction.

Key behavior:
- The structure API is schema-driven.
- The validation API can request repairs and clarification loops.
- The final result is deserialized into `AiWorkflowStructure`, then converted to concrete settings and `WorkflowFile`.

---

## Non-obvious runtime outcomes

- `ImportedFrom` is intentionally excluded from the schema used by `GetAIWorkflowStructureFromAiApi`; treat it as runtime/import context metadata.
- `GlobalVariables` is captured in this structure, but this stage does not directly create global variable definitions in host storage.
- IDs are normalized with GUID generation when missing/invalid (`EnsureIdIsValid`), so caller-provided IDs are hints, not guaranteed final IDs.
- `PreFilter` participates in planning context, but there is no direct one-to-one materialization step that creates a dedicated pre-filter setting object from this field.
- Schema generation for this call suppresses properties named `Filters` and `Transformers`; those fields may still exist in JSON, but they are not strongly enforced by the schema in this API step.
- Receiver/sender transformer description enrichment currently updates the first set (`[0]`) in the dedicated description-refinement pass; additional sets are not rewritten in that pass.
- Sender response template propagation is not force-applied in the same way as receiver template assignment; rely on sender-setting generation and transformer instructions for response behavior.

---

## Authoring guidance for AI agents

1. Treat this as a planning contract, not as final executable workflow JSON.
2. Keep `MessageSource`, `MessageType`, and `SenderAction` canonical to reduce repair iterations.
3. Put connection/config requirements in `Instructions`; keep field-level mapping logic in transformer `Instruction` blocks.
4. Include message templates when pathing/mapping precision matters.
5. Use stable activity names and IDs to improve downstream setting and transformer generation.
6. After structure generation, always run validation/refinement before generating concrete settings.

---

## AI-Driven Workflow File Authoring (Multi-Activity)

This section is the practical recipe an AI can follow to build an importable workflow file.

Use this when the target output is a `.hl7Workflow` file (JSON payload) with one receiver and multiple sender activities.

## Recommended generation strategy

1. Build `AiWorkflowStructure` first.
2. Validate and refine it.
3. Materialize concrete receiver/sender settings.
4. Materialize filter and transformer settings.
5. Assemble final `WorkflowFile` JSON.
6. Save JSON as `*.hl7Workflow` and import.

This matches the staged behavior in the AI flow and avoids most structural errors.

## Hard generation rules

1. Exactly one receiver per workflow.
2. Receiver runs first; senders run in order.
3. Filters are opt-in: receiver filter false stops the workflow; sender filter false skips that sender only.
4. Message templates are immutable: do not rewrite user templates; if reusing a full message from another activity, leave template empty and state the binding in `Instructions`.
5. Keep connection/config in `Instructions`; put map/update/filter logic in transformer/filter instruction blocks.
6. Use `VariableTransformers` only when variables are explicitly needed (reuse, preprocessing, filter support).
7. For HL7 over TCP/MLLP, default response behavior is auto-generated unless a custom response is explicitly required.
8. Do not assume sender responses automatically become the current message for later steps; later steps must explicitly pull from source activity.

## Activity-type mapping conventions (planning layer)

From `AiWorkflowStructure` intent to activity class family:

- Receiver `MessageSource`:
`TCP` -> MLLP receiver  
`HTTP` -> HTTP receiver  
`SOAP` -> WebService receiver  
`Database` -> Database receiver  
`Timer` -> Timer receiver  
`File` -> Directory scan receiver

- Sender `SenderAction`:
`TCP` -> MLLP sender  
`HTTP` -> HTTP sender  
`SOAP` -> WebService sender  
`Database` -> Database sender  
`File` -> File writer sender  
`Dicom` -> DICOM sender  
`Code` -> Code sender

For final workflow JSON, use fully-qualified `$type` values from exported workflow objects, not short names.

## Deterministic assembly algorithm for `WorkflowFile`

1. Create one receiver setting object as `WorkflowPattern[0]`.
2. Create N sender setting objects and append them to `WorkflowPattern`.
3. Populate receiver `Activities` with sender IDs in execution order.
4. For each activity needing filters, create `FilterHostSetting`, assign its `Id` into activity `Filters`, and append the filter host object to `WorkflowPattern`.
5. For each activity needing transformers, create `TransformerSetting`, assign its `Id` into activity `Transformers` (or receiver `VariableTransformers`), and append the transformer setting object to `WorkflowPattern`.
6. Set `WorkflowId` equal to root receiver `Id`.
7. Ensure all GUID references resolve to existing objects.

## Multi-activity `WorkflowFile` skeleton

```json
{
  "Comments": "Generated by AI",
  "Modified": "2026-03-02T00:00:00Z",
  "Name": "Example Multi-Activity Workflow",
  "WorkflowId": "11111111-1111-1111-1111-111111111111",
  "WorkflowPattern": [
    {
      "$type": "HL7Soup.Functions.Settings.Receivers.MLLPReceiverSetting, HL7SoupWorkflow",
      "Id": "11111111-1111-1111-1111-111111111111",
      "Name": "Inbound HL7",
      "MessageType": 9,
      "Activities": [
        "22222222-2222-2222-2222-222222222222",
        "33333333-3333-3333-3333-333333333333"
      ],
      "Filters": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      "VariableTransformers": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb"
    },
    {
      "$type": "HL7Soup.Functions.Settings.Senders.HttpSenderSetting, HL7SoupWorkflow",
      "Id": "22222222-2222-2222-2222-222222222222",
      "Name": "Post to API",
      "MessageType": 12,
      "Transformers": "cccccccc-cccc-cccc-cccc-cccccccccccc"
    },
    {
      "$type": "HL7Soup.Functions.Settings.Senders.DatabaseSenderSetting, HL7SoupWorkflow",
      "Id": "33333333-3333-3333-3333-333333333333",
      "Name": "Write Audit",
      "MessageType": 13,
      "Filters": "dddddddd-dddd-dddd-dddd-dddddddddddd",
      "Transformers": "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee"
    },
    {
      "$type": "HL7Soup.Functions.Settings.Filters.FilterHostSetting, HL7SoupWorkflow",
      "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
      "Filters": []
    },
    {
      "$type": "HL7Soup.Functions.Settings.TransformerSetting, HL7SoupWorkflow",
      "Id": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
      "Transformers": []
    },
    {
      "$type": "HL7Soup.Functions.Settings.TransformerSetting, HL7SoupWorkflow",
      "Id": "cccccccc-cccc-cccc-cccc-cccccccccccc",
      "Transformers": []
    },
    {
      "$type": "HL7Soup.Functions.Settings.Filters.FilterHostSetting, HL7SoupWorkflow",
      "Id": "dddddddd-dddd-dddd-dddd-dddddddddddd",
      "Filters": []
    },
    {
      "$type": "HL7Soup.Functions.Settings.TransformerSetting, HL7SoupWorkflow",
      "Id": "eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee",
      "Transformers": []
    }
  ]
}
```

Use this as a structure template, then fill sender/receiver-specific properties using the activity docs.

## Pre-import validation checklist

1. `WorkflowPattern[0]` is a receiver setting.
2. Receiver `Activities` contains all sender IDs in intended order.
3. Every GUID reference points to exactly one object in `WorkflowPattern`.
4. Every activity `MessageType` matches its template format.
5. Filter hosts contain only filter objects.
6. Transformer settings contain only transformer actions.
7. `WorkflowId` equals receiver `Id`.
8. JSON is UTF-8 and saved as `*.hl7Workflow`.

## Instruction template for external AI generation

Use this structure for high-faithfulness results:

```text
Create an Integration Soup workflow with:
1) Source:
- Receiver type:
- Connection details:
- Inbound message type:
- Inbound template (exact, do not modify):
2) Senders (in execution order):
- Sender 1 type + connection details + output type + template (exact)
- Sender 2 type + connection details + output type + template (exact)
3) Mapping/filter requirements:
- Exact field mappings:
- Exact filter conditions:
4) Response behavior:
- Auto-generate or custom response:
5) Constraints:
- One receiver only
- Keep templates unchanged
- Place mapping in transformers, not in connection instructions
Output:
- Final WorkflowFile JSON ready for .hl7Workflow import
```

---

## Related docs

- [AI Workflow Docs Index](./index.md)
- [WorkflowFile](../api/workflowfile.md)
- [CodeContext](../api/codingcontext.md)
- [Paths For AI](../reference/pathsforai.md)
- [Filter Host (FilterHostSetting)](../reference/filter-host-setting.md)
- [Transformer Setting (TransformerSetting)](../reference/transformer-setting.md)
- [Variable Creator JSON Reference](../reference/variable-creator.md)
