# Instruction Sources and Precedence

Instruction text sources are persisted under deterministic keys and can be set at function scope or activity scope.

This controls how system/user/import/instruction text is stored and retrieved across AI operations.

---

## Instruction source dimensions

| Source type | Scope and intent |
|---|---|
| `System` | Base system-level behavior for a function type. |
| `User` | User-specific extension/override content for a function type. |
| `Import` | Imported-definition context for a specific workflow/activity pair. |
| `Instruction` | User instruction context for a specific workflow/activity pair. |

---

## Keying model

Function-scoped key:

```text
AI_{FunctionType}_{SourceType}
```

Activity-scoped key:

```text
AI_{WorkflowId}_{ActivityId}_{SourceType}
```

---

## Read/write behavior

- function-scoped source text can be read or updated by function type + source type
- activity-scoped import/instruction text can be read or updated by workflow/activity ids
- imported text and user instruction text are tracked separately

All stored values are trimmed before persistence/retrieval usage.

---

## Important current behavior

Current system-source resolution routes to coded defaults directly.

Practical implications:

- persisted `System` overrides are not used by that default call path
- user/import/instruction values are still stored and available through source-specific retrieval paths
- if you need custom system behavior, use generic source retrieval or change default source resolution logic

---

## Operational guidance

When building external AI orchestration:

1. treat coded defaults as baseline source of truth
2. layer user/import/instruction sources explicitly
3. log effective composition per run for reproducibility
