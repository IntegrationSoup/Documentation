# MessageTypeOptions JSON Reference

`MessageTypeOptions` is a polymorphic JSON object used by settings that support additional parsing/format behavior for a chosen `MessageType`.

This page defines the serialized option object shapes and practical runtime impact.

---

## How to use in JSON

`MessageTypeOptions` must include `$type` to select the concrete option contract.

Examples:

```json
{
  "MessageType": 5,
  "MessageTypeOptions": {
    "$type": "HL7Soup.Workflow.MessageTypeOptions.CSVMessageTypeOption, HL7SoupWorkflow",
    "HasHeader": true,
    "Delimiter": ","
  }
}
```

```json
{
  "MessageType": 13,
  "MessageTypeOptions": {
    "$type": "HL7Soup.Workflow.MessageTypeOptions.TextMessageTypeOption, HL7SoupWorkflow",
    "MessageDivisionType": 1
  }
}
```

```json
{
  "MessageType": 16,
  "MessageTypeOptions": {
    "$type": "HL7Soup.Workflow.MessageTypeOptions.DicomMessageTypeOptions, HL7SoupWorkflow",
    "IncludeCommonFieldsNode": true,
    "IncludeReportNode": true,
    "IncludeTagsNode": true
  }
}
```

---

## CSV options (`CSVMessageTypeOption`)

`$type`: `HL7Soup.Workflow.MessageTypeOptions.CSVMessageTypeOption, HL7SoupWorkflow`

### Fields

| Field | Type | Meaning |
|---|---|---|
| `HasHeader` | boolean | Header row indicator for CSV ingestion logic. |
| `Header` | string | Header text used by file-writing header logic. |
| `HasFooter` | boolean | Footer indicator metadata. |
| `Footer` | string | Footer text metadata. |
| `Delimiter` | string | CSV delimiter (default `","`). |

### Runtime impact

- CSV parsing uses `Delimiter`.
- Directory-scan CSV ingestion uses `HasHeader` to skip first row.
- File writer can emit `Header` for new files.

### Non-obvious outcomes

- `HasFooter` and `Footer` are serialized but not used by core runtime ingestion/writing paths.
- Writer header emission is driven by non-empty `Header` in practice.

---

## Text options (`TextMessageTypeOption`)

`$type`: `HL7Soup.Workflow.MessageTypeOptions.TextMessageTypeOption, HL7SoupWorkflow`

### Fields

| Field | Type | Meaning |
|---|---|---|
| `HasHeader` | boolean | Header presence metadata. |
| `Header` | string | Header text used by file-writing header logic. |
| `HasFooter` | boolean | Footer presence metadata. |
| `Footer` | string | Footer text metadata. |
| `MessageDivisionType` | integer enum | Text message splitting mode. |
| `Delimiter` | string | Split delimiter (for split-by-character mode). |

`MessageDivisionType` values:

- `0` = `LinePerMessage`
- `1` = `DocumentPerMessage`
- `2` = `SplitByCharacters`

### Runtime impact

- `DocumentPerMessage` is honored: entire file becomes one message.
- Default line-based handling is used for `LinePerMessage`.

### Non-obvious outcomes

- `SplitByCharacters` and `Delimiter` serialize but are currently limited in runtime effect in directory-scan loading path.
- `HasFooter` and `Footer` are serialized but not actively used by core runtime parsing/writing behavior.

---

## DICOM options (`DicomMessageTypeOptions`)

`$type`: `HL7Soup.Workflow.MessageTypeOptions.DicomMessageTypeOptions, HL7SoupWorkflow`

### Fields

| Field | Type | Default | Meaning |
|---|---|---|---|
| `IncludeCommonFieldsNode` | boolean | `true` | Include promoted common DICOM fields in output JSON. |
| `IncludeReportNode` | boolean | `true` | Include structured report node when SR content exists. |
| `IncludeTagsNode` | boolean | `true` | Include full DICOM tag tree in output JSON. |

### Runtime impact

- Shapes the JSON generated from inbound DICOM during DICOM message conversion.

---

## Authoring guidance

1. Always include `$type` when setting `MessageTypeOptions`.
2. Use only option type matching the selected `MessageType`.
3. Keep options minimal; omit fields that have no meaningful runtime effect for your path.
4. Prefer explicit `Delimiter` for CSV even when comma is expected.

---

## Related docs

- [Directory Scan Receiver](../receiver-activities/directory-scan-receiver.md)
- [File Writer](../sender-activities/file-writer.md)
- [DICOM Receiver](../receiver-activities/dicom-receiver.md)
- [Workflow Enum and Interface Reference](./workflow-enums-and-interfaces.md)
