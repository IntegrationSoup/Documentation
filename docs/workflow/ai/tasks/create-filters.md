# Task: Create Message Filters (`AiFunctionType.CreateFilters`)

Generates typed message filter objects from filter instruction text.

---

## Use when

- you have filter instructions and activity/source context
- you need filter objects for `FilterHostSetting.Filters`

---

## Output contract

- JSON array of filter objects only
- compatible with `HL7Soup.MessageFilters.*` types

---

## Instruction input template (copy/paste)

```text
Create filter objects for this activity.

Context:
- Root activity ID:
- Target activity ID:
- Source message type:

Filter instructions:
"""
...
"""

Return only JSON array of message filters.
```

---

## Example 1 (HL7 receiver filter)

## Input instruction

```text
Continue only when MSH-9.1 equals ADT and PID-3.1 is not empty.
```

## Output (shape)

```json
[
  {
    "$type": "HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow",
    "Path": "MSH-9.1",
    "Comparer": 0,
    "Value": "ADT",
    "Conjunction": 0,
    "FromSetting": "11111111-1111-1111-1111-111111111111",
    "FromType": 8,
    "FromDirection": 0
  },
  {
    "$type": "HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow",
    "Path": "PID-3.1",
    "Comparer": 6,
    "Not": true,
    "Conjunction": 0,
    "FromSetting": "11111111-1111-1111-1111-111111111111",
    "FromType": 8,
    "FromDirection": 0
  }
]
```

## Example 2 (JSON sender filter)

## Input instruction

```text
Execute only when patient/status equals Active.
```

## Output (shape)

```json
[
  {
    "$type": "HL7Soup.MessageFilters.StringMessageFilter, HL7SoupWorkflow",
    "Path": "patient/status",
    "Comparer": 0,
    "Value": "Active",
    "Conjunction": 0,
    "FromSetting": "22222222-2222-2222-2222-222222222222",
    "FromType": 12,
    "FromDirection": 0
  }
]
```

---

## Common failure modes

- using negative phrasing ("filter out ...") instead of pass criteria
- wrong `FromType` for path syntax
- returning non-array JSON

---

## Related

- [Filter Rules](../components/filter-rules.md)
- [Path and Source Rules](../components/path-rules.md)
