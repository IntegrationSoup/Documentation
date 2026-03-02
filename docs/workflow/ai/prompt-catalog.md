# Prompt Catalog

This page maps prompt scenarios in `AIPrompts.cs` to documentation pages in this folder.

---

## Recommended chains

### Build new workflow

1. [CreateWorkflow](prompts/create-workflow.md)
2. [ValidateWorkflowStructure](prompts/validate-workflow-structure.md)
3. [RefineWorkflowStructure](prompts/refine-workflow-structure.md) (if validation fails)
4. [CreateWorkflowFileFromWorkflowStructure](prompts/create-workflow-file-from-workflow-structure.md)
5. [CreateFilters](prompts/create-filters.md)
6. [CreateTransformers](prompts/create-transformers.md)
7. [CreateCodeTransformers](prompts/create-code-transformers.md) (optional)

### Import/migration flow

1. [ImportWorkflow](prompts/import-workflow.md)
2. [CreateRecieverVariableInstructions](prompts/create-receiver-variable-instructions.md)
3. [CreateSenderTransformerInstructions](prompts/create-sender-transformer-instructions.md)
4. [CreateRecieverResponseTransfomerInstructions](prompts/create-receiver-response-transformer-instructions.md) (if custom response required)
5. [CreateFilters](prompts/create-filters.md)
6. [CreateTransformers](prompts/create-transformers.md)

---

## Function prompts (`AiFunctionType`)

| Function | Purpose | Doc |
|---|---|---|
| `CreateWorkflow` | Build `AiWorkflowStructure` from natural-language requirements. | [CreateWorkflow](prompts/create-workflow.md) |
| `ImportWorkflow` | Build workflow settings list from imported/foreign description. | [ImportWorkflow](prompts/import-workflow.md) |
| `CreateWorkflowFileFromWorkflowStructure` | Build concrete workflow settings list for a full workflow file. | [CreateWorkflowFileFromWorkflowStructure](prompts/create-workflow-file-from-workflow-structure.md) |
| `CreateActivity` | Generate one activity-level definition (custom activity scenario). | [CreateActivity](prompts/create-activity.md) |
| `CreateTransformers` | Generate structured transformer actions. | [CreateTransformers](prompts/create-transformers.md) |
| `CreateCodeTransformers` | Generate C# code for code transformer steps. | [CreateCodeTransformers](prompts/create-code-transformers.md) |
| `CreateFilters` | Generate structured message filter objects. | [CreateFilters](prompts/create-filters.md) |
| `CreateRecieverVariableInstructions` | Expand receiver variable-transform instruction text. | [CreateRecieverVariableInstructions](prompts/create-receiver-variable-instructions.md) |
| `CreateRecieverResponseTransfomerInstructions` | Expand receiver response-transform instruction text. | [CreateRecieverResponseTransfomerInstructions](prompts/create-receiver-response-transformer-instructions.md) |
| `CreateSenderTransformerInstructions` | Expand sender transformer instruction text. | [CreateSenderTransformerInstructions](prompts/create-sender-transformer-instructions.md) |
| `ValidateWorkflowStructure` | Validate faithfulness of current structure against user request. | [ValidateWorkflowStructure](prompts/validate-workflow-structure.md) |
| `RefineWorkflowStructure` | Repair current structure based on validator output. | [RefineWorkflowStructure](prompts/refine-workflow-structure.md) |

---

## Component prompt families

| Family | Purpose | Doc |
|---|---|---|
| `AIPathPromptType` | Path syntax and source-selection rules across message types. | [Path Prompts](components/path-prompts.md) |
| `AITransformerPromptType` | Transformer vocabulary and conversion guidance. | [Transformer Prompts](components/transformer-prompts.md) |
| `AIFilterPromptType` | Filter semantics and filter-object guidance. | [Filter Prompts](components/filter-prompts.md) |
| `AICodePromptType` | Code generation rules for code transformers. | [Code Prompts](components/code-prompts.md) |
| Receiver/sender type/setting prompts | Determine concrete type, then generate serialized properties. | [Receiver/Sender Prompt Blocks](components/receiver-sender-setting-prompts.md) |
| Embedded prompt blocks | Reusable prompt text blocks composed into larger system prompts. | [Embedded Prompt Blocks](components/embedded-prompt-blocks.md) |
| Prompt persistence/override | Keying and prompt types (`System`, `User`, `Import`, `Instruction`). | [Prompt Storage and Overrides](components/prompt-storage-and-overrides.md) |

---

## Notes

- `ValidateWorkflowStructure` and `RefineWorkflowStructure` prompt bodies come from dedicated prompt classes in `Dialogs/AI/Prompts`, not inline constants.
- `AIPrompts.GetSystemPrompt(...)` currently returns coded defaults directly.
