# Task: Refine Workflow Structure (`AiFunctionType.RefineWorkflowStructure`)

Repairs `AiWorkflowStructure` based on validator findings.

## Use when

- validator returns `IsFaithful = false`
- validator provides issues/suggested changes

---

## Output contract

- corrected `AiWorkflowStructure` JSON only
- no prose

---

## Instruction input template (copy/paste)

```text
Repair this AiWorkflowStructure using the validation result.

Original user request:
...

Current AiWorkflowStructure JSON:
...

Validation result:
...

Rules:
- preserve templates exactly
- apply minimal changes required
- remove unknown or invalid fields
- keep one receiver and ordered sender activities

Return only corrected AiWorkflowStructure JSON.
```

---

## Example (fixing receiver source + filter)

## Input summary

- Current structure uses `MessageSource = "HTTP"` but request requires TCP.
- ADT-only sender filter missing.

## Output changes

- `ReceiverActivity.MessageSource` changed to `TCP`
- receiver instructions updated with TCP port
- sender filter inserted: `Continue only when MSH-9.1 equals 'ADT'`

---

## Common failure modes

- over-correcting fields unrelated to reported issues
- dropping message templates during repair
- returning commentary instead of pure JSON
