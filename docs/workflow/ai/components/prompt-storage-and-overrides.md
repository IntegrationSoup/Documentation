# Prompt Storage and Overrides

Prompt values are persisted under deterministic keys and can be set at function scope or activity scope.

This controls how custom prompts are stored and retrieved across AI operations.

---

## Prompt type dimensions (`AiPromptType`)

| Prompt type | Scope and intent |
|---|---|
| `System` | Base system-level behavior for a function type. |
| `User` | User-specific extension/override content for a function type. |
| `Import` | Imported-definition context for a specific workflow/activity pair. |
| `Instruction` | User instruction context for a specific workflow/activity pair. |

---

## Keying model

Function-scoped key:

```text
AI_{AiFunctionType}_{AiPromptType}
```

Activity-scoped key:

```text
AI_{WorkflowId}_{ActivityId}_{AiPromptType}
```

---

## API surface

- `GetPrompt(AiFunctionType, AiPromptType, defaultValue)`
- `SetPrompt(AiFunctionType, AiPromptType, value)`
- `GetImportedPrompt(workflowId, activityId, defaultValue)`
- `SetImportedPrompt(workflowId, activityId, value)`
- `GetInstructionPrompt(workflowId, activityId, defaultValue)`
- `SetInstructionPrompt(workflowId, activityId, value)`

All stored values are trimmed before persistence/retrieval usage.

---

## Important current behavior

`GetSystemPrompt(AiFunctionType)` currently routes to coded defaults (`GetDefaultSystemPrompt`) directly.

Practical implications:

- persisted `System` overrides are not used by that call path
- user/import/instruction prompt values are still stored and available through their APIs
- if you need custom system prompt behavior, call the generic prompt retrieval path or update system prompt resolution logic

---

## Operational guidance

When building external AI orchestration:

1. treat coded defaults as baseline source of truth
2. layer user/import/instruction prompts explicitly
3. log effective prompt composition per run for reproducibility
