# WorkflowFile in Integration Soup
**Definitive JSON Root Contract**

`WorkflowFile` is the top-level JSON object for a workflow export/import payload.

This page documents the JSON contract only: what properties exist, what they mean, and how they affect workflow behavior.

For activity-level fields inside `WorkflowPattern`, use the receiver/sender activity docs.

For shared enum values, use [Workflow Enum and Interface Reference](../reference/workflow-enums-and-interfaces.md).

---

## JSON shape

Typical structure:

```json
{
  "Comments": "Imported from integration host",
  "Modified": "2026-03-02T01:10:00Z",
  "ImportedDate": "2026-03-02T01:12:05Z",
  "Name": "Inbound ADT Workflow",
  "WorkflowId": "6d5f4d5d-95d4-4d2d-8a67-7c9a4dcb9f77",
  "WorkflowPattern": [
    {
      "$type": "HL7Soup.Functions.Settings.Receivers.MLLPReceiverSetting, HL7SoupWorkflow",
      "Id": "6d5f4d5d-95d4-4d2d-8a67-7c9a4dcb9f77",
      "Name": "Inbound MLLP",
      "WorkflowPatternName": "Inbound ADT Workflow"
    },
    {
      "$type": "HL7Soup.Functions.Settings.Senders.HttpSenderSetting, HL7SoupWorkflow",
      "Id": "3b10eb77-4f12-4d1f-bf2a-0620c7e19fc1",
      "Name": "Forward to API"
    }
  ]
}
```

---

## Top-level properties

| Property | Type | Required | Meaning | Runtime impact |
|---|---|---|---|---|
| `Comments` | string | optional | Free-text notes for this saved file/version. | Metadata only; not used to process messages. |
| `Modified` | datetime string | recommended | UTC timestamp for when this file version was created/saved. | Metadata only; not used to process messages. |
| `ImportedDate` | datetime string | optional | UTC timestamp for when this file was imported into a host. | Metadata only; not used for routing/transform logic. |
| `Name` | string | recommended | Friendly workflow file name. | Metadata only; not the execution contract. |
| `WorkflowId` | string (GUID text) | recommended | Workflow identifier captured in the file wrapper. | Metadata/identity helper; activity IDs and links still drive execution. |
| `WorkflowPattern` | array of setting objects | required | Full workflow graph as serialized settings objects. | Core execution contract. |

---

## `WorkflowPattern` contract

`WorkflowPattern` is where executable behavior lives.

Each element is a concrete setting object and should include:

- `$type`: fully qualified type name for deterministic deserialization.
- The setting’s serialized public fields (for example `Id`, `Name`, `MessageType`, `Activities`, etc.).

### Practical rules

1. Keep setting `Id` values unique across the array.
2. Keep GUID references valid:
   - `Activities` should reference existing activity IDs.
   - `Filters`, `Transformers`, `VariableTransformers` should reference existing setting IDs where applicable.
3. Keep the receiver/root setting first in the list.
4. Keep `WorkflowId` aligned with the root receiver `Id` for consistency.
5. Keep top-level `Name` aligned with receiver `WorkflowPatternName` to avoid operator confusion.

---

## Serialization behavior that affects JSON authoring

- Enum fields are serialized as integers.
- Default values can be omitted in exported JSON.
- `WorkflowPattern` uses polymorphic setting objects, so `$type` matters for reliable imports.
- Cross-runtime type binding is tolerant of some legacy assembly-name differences, but explicit full type names are still the safest JSON contract.

---

## Non-obvious outcomes

- `Name`, `Comments`, `Modified`, `ImportedDate`, and `WorkflowId` are primarily file metadata; changing them does not directly change message processing behavior.
- Processing behavior comes from `WorkflowPattern` objects and their GUID links.
- A file can deserialize even with metadata mismatches, but operational clarity degrades quickly if `Name`, `WorkflowId`, and root receiver metadata are inconsistent.
- Empty or incomplete `WorkflowPattern` may still parse as JSON but is not a usable workflow definition.

---

## Authoring checklist (AI/dev JSON generation)

1. Start from a valid receiver setting object as the first `WorkflowPattern` entry.
2. Add sender/filter/transformer/settings objects referenced by GUID.
3. Verify every referenced GUID exists exactly once in the file.
4. Keep enum values numeric, not textual.
5. Include explicit `$type` for every setting object.
6. Set `WorkflowId` to the root receiver `Id`.
7. Keep timestamps UTC (`...Z`) if provided.

---

## Related docs

- [Workflow Enum and Interface Reference](../reference/workflow-enums-and-interfaces.md)
- [HTTP Receiver](../receiver-activities/http-receiver.md)
- [MLLP Receiver](../receiver-activities/mllp-receiver.md)
- [Directory Scan Receiver](../receiver-activities/directory-scan-receiver.md)
- [HTTP Sender](../sender-activities/http-sender.md)
- [Web Service Sender](../sender-activities/web-service-sender.md)
