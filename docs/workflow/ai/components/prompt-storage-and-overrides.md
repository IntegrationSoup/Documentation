# Prompt Storage and Overrides

Prompts are keyed and persisted by function and prompt type.

---

## Prompt type dimensions (`AiPromptType`)

- `System`
- `User`
- `Import`
- `Instruction`

---

## Keying model

- Function-scoped key:
`AI_{AiFunctionType}_{AiPromptType}`

- Activity-scoped key:
`AI_{WorkflowId}_{ActivityId}_{AiPromptType}`

---

## API methods

- `GetPrompt(AiFunctionType, AiPromptType, defaultValue)`
- `SetPrompt(AiFunctionType, AiPromptType, value)`
- `GetImportedPrompt(workflowId, activityId, defaultValue)`
- `SetImportedPrompt(workflowId, activityId, value)`
- `GetInstructionPrompt(workflowId, activityId, defaultValue)`
- `SetInstructionPrompt(workflowId, activityId, value)`

---

## Important current behavior

`GetSystemPrompt(AiFunctionType)` currently returns coded defaults directly.

Practical impact:
- system prompt overrides are not currently used by that method path
- function-level user/import/instruction prompts are still stored and retrievable
