# Prompt: CreateRecieverVariableInstructions (`AiFunctionType.CreateRecieverVariableInstructions`)

Turns receiver variable requirements into explicit variable-step instructions.

---

## Use when

- you need clean variable instructions before action-object generation
- receiver stage needs reusable/preprocessed values for later senders/filters

---

## Output contract

- plain instruction text for `AiReceiverActivity.VariableTransformers[i].Instruction`
- no JSON wrapper

---

## Prompt template (copy/paste)

```text
Create receiver variable-transformer instruction text.

Message type:
- ...

Receiver input sample/template:
- ...

Required variable outcomes:
- ...

Constraints:
- variable setting only
- no destination mapping
- use explicit lines like ${VariableName} from SourcePath

Return only instruction text.
```

---

## Example 1 (HL7)

## Input

```text
Extract message code and patient demographics for downstream sender filters/mapping.
```

## Output

```text
Set Variables:
  ${MessageCode} from MSH-9.1
  ${MessageTrigger} from MSH-9.2
  ${PatientID} from PID-3.1
  ${LastName} from PID-5.1
  ${FirstName} from PID-5.2
  ${DOB} from PID-7.1 with Format.Date(yyyy-MM-dd)
```

## Example 2 (JSON)

## Input

```text
Extract patient and encounter identifiers from inbound JSON.
```

## Output

```text
Set Variables:
  ${PatientID} from patient/id
  ${EncounterID} from encounter/id
  ${FacilityCode} from encounter/facility/code
```

## Example 3 (CSV)

## Input

```text
Columns: [0]=OrderId, [1]=PatientId, [2]=TestCode.
```

## Output

```text
Set Variables:
  ${OrderID} from [0]
  ${PatientID} from [1]
  ${TestCode} from [2]
```

---

## Common failure modes

- including map/update instructions in this phase
- ambiguous variable names
- missing source paths
