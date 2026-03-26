# Variable Creator JSON Reference

`IVariableCreator` is a shared JSON object contract used in multiple workflow settings.

You see this shape in places like:

- HTTP receiver `QueryStringParameters` values
- HTTP receiver `UrlSections` entries
- variable-creation transformer metadata

This page defines the JSON object shape and behavioral implications.

---

## Core object shape

Minimal interface-level shape:

```json
{
  "VariableName": "patientId",
  "SampleVariableValue": "12345",
  "SampleValueIsDefaultValue": false
}
```

Extended concrete shape (when `VariableType` is present):

```json
{
  "VariableName": "patientId",
  "SampleVariableValue": "12345",
  "SampleValueIsDefaultValue": false,
  "VariableType": 0
}
```

---

## Fields

| Field | Type | Required | Meaning |
|---|---|---|---|
| `VariableName` | string | yes | Variable key name used in workflow. |
| `SampleVariableValue` | string | optional | Example/default-like value used for binding context and optional initialization behavior. |
| `SampleValueIsDefaultValue` | boolean | optional | If true, consumers that support initialization may pre-seed the variable using `SampleVariableValue`. |
| `VariableType` | integer enum | optional | Variable category metadata when concrete `VariableCreator` shape is serialized. |

`VariableType` values:

- `0` = `Workflow`
- `1` = `System`
- `2` = `Global`

---

## Behavior notes by common usage

### HTTP receiver query parameters / URL sections

In these contexts, `SampleValueIsDefaultValue` is operational:

- default value can be initialized before inbound request values are applied
- missing/empty inbound values may leave the initialized default in place

### Transformer variable metadata

In transformer contexts, `SampleVariableValue` and `SampleValueIsDefaultValue` are mostly metadata/binding aids.

Runtime value assignment usually comes from transformer source evaluation, not from sample initialization.

---

## Non-obvious outcomes

- `VariableName` is the actual runtime key; keep names stable and consistent with `${VariableName}` usage.
- `VariableType` is not part of the core `IVariableCreator` interface but can still appear in serialized objects that use concrete `VariableCreator`.
- `SampleVariableValue` is often treated as design-time context unless the host setting explicitly uses initialization logic.

---

## Recommended authoring rules

1. Keep `VariableName` explicit, stable, and unique within the same logical variable scope.
2. Use literal sample values only; do not embed paths as sample values.
3. Set `SampleValueIsDefaultValue = true` only when a real default-initialization behavior is intended in that specific setting.
4. Use `VariableType = 0` unless you explicitly need `System` or `Global` category metadata in that context.

---

## Examples

### Query string parameter variable descriptor

```json
{
  "VariableName": "siteId",
  "SampleVariableValue": "main",
  "SampleValueIsDefaultValue": true,
  "VariableType": 0
}
```

### URL section variable descriptor

```json
{
  "VariableName": "patientId",
  "SampleVariableValue": "12345",
  "SampleValueIsDefaultValue": false,
  "VariableType": 0
}
```

---

## Related docs

- [HTTP Receiver](../receiver-activities/http-receiver.md)
- [Transformer Setting (TransformerSetting)](./transformer-setting.md)
- [Workflow Enum and Interface Reference](./workflow-enums-and-interfaces.md)
