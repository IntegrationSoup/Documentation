# Task: Validate Workflow Structure (`AiFunctionType.ValidateWorkflowStructure`)

Validates faithfulness of current `AiWorkflowStructure` against user intent.

## Use when

- after `CreateWorkflow`
- after each repair iteration

---

## Output contract

`AiWorkflowStructureValidationResult` shape:

```json
{
  "IsFaithful": true,
  "Issues": [],
  "SuggestedChanges": [],
  "Questions": [],
  "MaxQuestions": 3,
  "QuestionsWereTruncated": false,
  "TruncationNote": ""
}
```

---

## Instruction input template (copy/paste)

```text
Validate this AiWorkflowStructure against the original user request.

Original user request:
...

Current AiWorkflowStructure JSON:
...

Return only AiWorkflowStructureValidationResult JSON.
```

---

## Example (fail result with required fixes)

```json
{
  "IsFaithful": false,
  "Issues": [
    "Receiver says HTTP but requirement says TCP.",
    "Sender 2 missing ADT filter requirement."
  ],
  "SuggestedChanges": [
    "Set ReceiverActivity.MessageSource to TCP and include port in instructions.",
    "Add sender filter: Continue only when MSH-9.1 equals 'ADT'."
  ],
  "Questions": [],
  "MaxQuestions": 3,
  "QuestionsWereTruncated": false,
  "TruncationNote": ""
}
```

---

## Clarification behavior

Validator can return required user questions when fidelity cannot be determined safely.  
These answers are folded back into the next validation/refinement iteration.
