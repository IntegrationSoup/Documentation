# Path Prompts (`AIPathPromptType`)

Path prompts define how an AI should reference source and destination values in filters, variable extraction, and transformer instructions.

Use these whenever generated instructions include data access paths.

---

## Enum values

| Value | Purpose |
|---|---|
| `Paths` | Base cross-activity and general path rules. |
| `HL7Paths` | HL7 path syntax guidance. |
| `XMLPaths` | XML path syntax guidance. |
| `JSONPaths` | JSON path syntax guidance. |
| `CSVPaths` | CSV column path guidance. |
| `SQLPaths` | SQL result-column path guidance. |
| `MirthPaths` | General Mirth-to-HL7 Soup conversion guidance. |
| `MirthHL7Paths` | Mirth HL7 path conversion rules. |
| `MirthXMLPaths` | Mirth XML path conversion rules. |
| `MirthJSONPaths` | Mirth JSON path conversion rules. |
| `MirthCSVPaths` | Mirth CSV path conversion rules. |
| `MirthSQLPaths` | Mirth SQL path conversion rules. |
| `AllPaths` | Concatenates non-Mirth path blocks. |
| `AllMirth` | Concatenates all Mirth blocks. |
| `AllHL7Paths` | `HL7Paths` + `MirthHL7Paths`. |
| `AllXMLPaths` | `XMLPaths` + `MirthXMLPaths`. |
| `AllJSONPaths` | `JSONPaths` + `MirthJSONPaths`. |
| `AllCSVPaths` | `CSVPaths` + `MirthCSVPaths`. |

---

## Selector behavior (`GetPathPrompt(string filter)`)

`GetPathPrompt(string)` is token-driven:

- always includes `Paths`
- adds `HL7Paths` when filter contains `hl7`
- adds `XMLPaths` when filter contains `xml`
- adds `JSONPaths` when filter contains `json`
- adds `CSVPaths` when filter contains `csv`
- adds `MirthPaths` when filter contains `mirth`
- adds `MirthHL7Paths`/`MirthXMLPaths`/`MirthJSONPaths`/`MirthCSVPaths` only when both `mirth` and the matching format token are present

### Non-obvious outcome

- `GetPathPrompt(string)` does not check for `sql`, so `SQLPaths` and `MirthSQLPaths` are not auto-included by the string selector.
- If SQL-specific guidance is required, include it explicitly via `GetPathPrompt(AIPathPromptType.SQLPaths)` (and `MirthSQLPaths` for migrations).

---

## Composition recipes

### Native workflow design (HL7 receiver -> JSON sender)

- Filter text: `hl7 json`
- Include returned prompt in:
  - receiver variable instruction generation
  - sender transformer instruction generation
  - filter instruction generation

### Mirth migration (HL7 channel)

- Filter text: `mirth hl7`
- This includes:
  - baseline path rules
  - HL7 syntax guidance
  - Mirth global conversion guidance
  - Mirth HL7 conversion specifics

### SQL sender/receiver scenario

- Filter text alone is not enough.
- Append `SQLPaths` guidance explicitly using enum-based selection.

---

## Instruction quality checks

Generated instruction text should satisfy all of the following:

- path expressions are concrete, not descriptive prose
- cross-activity reads include quoted activity name/id prefix (`'Sender Name' PID-3.1`)
- variable references use `${VariableName}` shape where appropriate
- mappings update only the current activity message or workflow variables

---

## Minimal examples

Good:

```text
Set ${PatientId} from PID-3.1
Map the value from 'Normalize Name' patient/identifiers[1]/id to externalId
Continue only when PID-8.1 equals 'M'
```

Bad:

```text
Set patient id from incoming message
Map from previous sender name field
Only include male patients
```
