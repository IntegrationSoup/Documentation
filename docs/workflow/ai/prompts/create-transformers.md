# Prompt: CreateTransformers (`AiFunctionType.CreateTransformers`)

Generates typed transformer action objects from instruction text.

---

## Use when

- you already have transformer instruction text
- you need executable transformer action JSON

---

## Output contract

- JSON array of typed transformer action objects
- each action has concrete `$type` and required fields
- output is suitable for `TransformerSetting.Transformers`

---

## Prompt template (copy/paste)

```text
Create transformer action objects for this activity.

Context:
- Root activity ID:
- Current target activity ID:
- Source message type:
- Available activities:

Transformer instructions:
"""
...
"""

Return only JSON array of transformer actions.
```

---

## Example 1 (HL7 -> HL7 map)

## Input instruction

```text
From Receiver:
Map PID-3.1 to PID-2.1
```

## Output (shape)

```json
[
  {
    "$type": "HL7Soup.Functions.Settings.CreateMappingTransformerAction, HL7SoupWorkflow",
    "FromPath": "PID-3.1",
    "FromSetting": "11111111-1111-1111-1111-111111111111",
    "FromDirection": 0,
    "FromType": 8,
    "ToPath": "PID-2.1",
    "ToSetting": "22222222-2222-2222-2222-222222222222",
    "ToDirection": 0,
    "ToType": 8,
    "AllowMessageStructureToChange": true
  }
]
```

## Example 2 (JSON -> variable)

## Input instruction

```text
Set Variables:
${PatientId} from patient/id
```

## Output (shape)

```json
[
  {
    "$type": "HL7Soup.Functions.Settings.CreateVariableTransformerAction, HL7SoupWorkflow",
    "VariableName": "PatientId",
    "FromPath": "patient/id",
    "FromSetting": "11111111-1111-1111-1111-111111111111",
    "FromDirection": 0,
    "FromType": 12
  }
]
```

---

## Message-type path hints

- HL7: `PID-3.1`, `OBX[2]-5.1`
- XML: `Patient/Identifiers[1]/ID`
- JSON: `patient/identifiers[1]/id`
- CSV: `[0]`, `[1]`, ...

---

## Common failure modes

- wrong `FromType`/`ToType` for path syntax
- mapping to another activity message directly (instead of current target)
- missing `ToSetting` or `FromSetting` where required
- returning instruction prose instead of typed action objects

---

## Related

- [CreateSenderTransformerInstructions](create-sender-transformer-instructions.md)
- [CreateRecieverVariableInstructions](create-receiver-variable-instructions.md)
- [Transformer Prompts](../components/transformer-prompts.md)
