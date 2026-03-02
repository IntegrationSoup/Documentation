# Task: Create Sender Transformer Instructions (`AiFunctionType.CreateSenderTransformerInstructions`)

Expands sender transformation requirements into explicit instruction text.

---

## Use when

- sender message/parameter shaping is required
- instructions need to be detailed before action-object generation

---

## Output contract

- plain instruction text for `AiSenderActivity.Transformers[i].Instruction`

---

## Instruction input template (copy/paste)

```text
Create sender transformer instruction text.

Sender context:
- Sender name:
- Sender type:
- Sender message type:
- Sender template (exact if provided):

Available sources:
- Receiver inbound
- Other sender outputs (by name)
- Variables

Transformation requirements:
- ...

Constraints:
- use explicit operation terms: Map, Update, Set Variables, Format, Code
- include exact source/destination paths
- keep templates unchanged

Return only instruction text.
```

---

## Example 1 (HL7 -> JSON sender)

## Input

```text
HTTP sender needs JSON body with externalId, fullName and dob from HL7 PID fields.
```

## Output

```text
From Receiver:
Map PID-3.1 to externalId
Map PID-5.1 to lastName
Map PID-5.2 to firstName
Map PID-7.1 with Format.Date(yyyy-MM-dd) to dob
Format:
  Combine lastName and firstName into fullName using '${lastName}, ${firstName}'
```

## Example 2 (CSV -> SQL sender)

## Input

```text
Database sender query has @OrderId, @PatientId, @TestCode from CSV columns 0,1,2.
```

## Output

```text
From Receiver:
Map [0] to @OrderId
Map [1] to @PatientId
Map [2] to @TestCode
```

## Example 3 (cross-activity source)

## Input

```text
File writer sender should use status returned by sender "PostToAPI".
```

## Output

```text
From 'PostToAPI':
Map status to output/status
Update output/source to 'api'
```

---

## Common failure modes

- vague instructions ("transform to format X")
- missing source activity for cross-activity reads
- embedding path placeholders directly into templates instead of mapping/variable logic
