# Filter Host (FilterHostSetting)

`FilterHostSetting` is the reusable JSON object referenced by `Filters` GUID fields in receivers and activities.

It contains:

- a list of filter conditions (`Filters`)
- an optional pre-filter transformer chain (`Transformers`)

This page describes the JSON contract and runtime behavior only.

---

## What it does at runtime

Execution order:

1. Run `Transformers` in order (if present).
2. Evaluate `Filters` as a condition expression.
3. Mark the current activity/workflow as filtered when the condition expression evaluates to false.

Important non-obvious outcome:

- Filter conditions are treated as pass criteria.
- If criteria evaluate to false, the message/activity is filtered out.

---

## JSON shape

Typical object shape:

```json
{
  "$type": "HL7Soup.Functions.Settings.Filters.FilterHostSetting, HL7SoupWorkflow",
  "Id": "c27f2d6d-f8b5-4f0f-9fb2-7c3e0f66cb3b",
  "Name": "Primary Filters",
  "Filters": [
    {
      "$type": "HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow",
      "Path": "MSH-9.2",
      "Comparer": 0,
      "Value": "A01",
      "Not": false,
      "Conjunction": 0,
      "FromSetting": "11111111-1111-1111-1111-111111111111",
      "FromType": 8,
      "FromDirection": 0
    }
  ],
  "Transformers": [],
  "Version": 3
}
```

---

## Top-level fields

| Field | Type | Required | Meaning |
|---|---|---|---|
| `Id` | GUID string | yes | Filter-setting identity referenced by other settings. |
| `Name` | string | recommended | Display name for the filter set. |
| `Filters` | array | recommended | Ordered condition/group list. |
| `Transformers` | array | optional | Transformer actions run before filter evaluation. |
| `Version` | integer | optional | Setting version metadata. |

---

## `Filters` element types

`Filters` is a polymorphic array. Common types:

- `HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow`
- `HL7Soup.MessageFilters.DateMessageFilter, HL7SoupWorkflow`
- `HL7Soup.MessageFilters.ValidMessageFilter, HL7SoupWorkflow`
- `HL7Soup.MessageFilters.FilterGroup, HL7SoupWorkflow`

### Shared fields across filter items

| Field | Meaning |
|---|---|
| `Path` | Source path/text expression to evaluate. |
| `Conjunction` | How this item combines with the next item (`0=And`, `1=Or`). |
| `Not` | Inverts the comparison result when true. |
| `FromSetting` | Source activity/receiver GUID. |
| `FromDirection` | Source side (`0=inbound`, `1=outbound`, `2=variable`). |
| `FromType` | Source interpretation mode (`TextWithVariables`, HL7 path, XPath, CSV path, JSON path). |

Optional shared-to-target fields (used by comparers that require a second operand):

| Field | Meaning |
|---|---|
| `ToPath` | Second operand path/text expression. |
| `ToSetting` | Second operand source setting GUID. |
| `ToDirection` | Second operand source direction. |
| `ToType` | Second operand interpretation type. |

### `StringMessageFilter` specific fields

| Field | Meaning |
|---|---|
| `Comparer` | String comparer enum value. |
| `Value` | Comparison value (or auxiliary comparer value). |
| `CaseSensitive` | Case-sensitive comparison toggle. |
| `IncludesRepeatFields` | Repeat-field handling hint for HL7 paths. |

`StringMessageFilterComparers` values:

- `0` = `Equals`
- `1` = `Contains`
- `2` = `StartsWith`
- `3` = `EndsWith`
- `4` = `LengthGreaterThan`
- `5` = `LengthLessThan`
- `6` = `Empty`
- `7` = `InMessage`
- `8` = `InDataTable`
- `9` = `IsTitleCase`
- `10` = `IsUpperCase`
- `11` = `IsLowerCase`
- `12` = `InList`

### `DateMessageFilter` specific fields

| Field | Meaning |
|---|---|
| `Comparer` | Date comparer enum value. |
| `Value` | Date comparison value (ISO-like date string). |

`DateMessageFilterComparers` values:

- `0` = `Equals`
- `1` = `GreaterThan`
- `2` = `LessThan`
- `3` = `GreaterThanOrEqualTo`
- `4` = `LessThanOrEqualTo`
- `5` = `Empty`
- `6` = `InMessage`
- `7` = `InvalidDate`

### `ValidMessageFilter` specific fields

| Field | Meaning |
|---|---|
| `Comparer` | Message validity comparer enum value. |

`ValidMessageFilterComparers` values:

- `0` = `Valid`
- `1` = `Invalid`

### `FilterGroup`

Group boundary marker used to structure multi-condition expressions with conjunction transitions.

Important authoring constraints:

- Do not place `FilterGroup` as first or last item.
- Do not place two `FilterGroup` items consecutively.

---

## `Transformers` field

`Transformers` is the same transformer-action array contract used by `TransformerSetting`.

See [Transformer Setting (TransformerSetting)](./transformer-setting.md) for the full action schema.

---

## Non-obvious outcomes

- Empty `Filters` list means no filtering (message passes).
- `FilterGroup` misuse (first/last/double group) can create invalid or brittle filter behavior.
- `InDataTable` string comparer requires correct target data-table binding; incorrect usage can error.
- Filter transformers run before conditions and can modify variables/message data that conditions consume.
- `FromType` and `FromDirection` must match the source kind; mismatches produce silent no-value comparisons or failed logic.

---

## Minimal example

```json
{
  "$type": "HL7Soup.Functions.Settings.Filters.FilterHostSetting, HL7SoupWorkflow",
  "Id": "aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa",
  "Name": "ADT A01 Only",
  "Filters": [
    {
      "$type": "HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow",
      "Path": "MSH-9.2",
      "Comparer": 0,
      "Value": "A01",
      "Conjunction": 0,
      "Not": false,
      "FromSetting": "bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb",
      "FromType": 8,
      "FromDirection": 0
    }
  ],
  "Transformers": []
}
```
