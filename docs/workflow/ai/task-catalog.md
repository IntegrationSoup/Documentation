# Workflow JSON Task Catalog

This catalog maps workflow construction tasks to the pages that define required inputs, output JSON shape, and failure checks.

---

## Recommended chains

### Build new workflow

1. [Create Workflow Structure](tasks/create-workflow.md)
2. [Validate Workflow Structure](tasks/validate-workflow-structure.md)
3. [Refine Workflow Structure](tasks/refine-workflow-structure.md) if validation fails
4. [Create Workflow Settings List](tasks/create-workflow-file-from-workflow-structure.md)
5. [Create Message Filters](tasks/create-filters.md)
6. [Create Transformer Actions](tasks/create-transformers.md)
7. [Create Code Transformations](tasks/create-code-transformers.md) when non-declarative logic is required

### Import/migration flow

1. [Import Workflow Definition](tasks/import-workflow.md)
2. [Create Receiver Variable Instructions](tasks/create-receiver-variable-instructions.md)
3. [Create Sender Transformer Instructions](tasks/create-sender-transformer-instructions.md)
4. [Create Receiver Response Instructions](tasks/create-receiver-response-transformer-instructions.md) when custom response behavior is required
5. [Create Message Filters](tasks/create-filters.md)
6. [Create Transformer Actions](tasks/create-transformers.md)

---

## Task pages

| Internal task id | Output | Doc |
|---|---|---|
| `CreateWorkflow` | `AiWorkflowStructure` JSON | [Create Workflow Structure](tasks/create-workflow.md) |
| `ImportWorkflow` | receiver/sender setting list from imported source description | [Import Workflow Definition](tasks/import-workflow.md) |
| `CreateWorkflowFileFromWorkflowStructure` | concrete workflow settings list | [Create Workflow Settings List](tasks/create-workflow-file-from-workflow-structure.md) |
| `CreateActivity` | single activity definition | [Create Activity Definition](tasks/create-activity.md) |
| `CreateTransformers` | transformer action objects | [Create Transformer Actions](tasks/create-transformers.md) |
| `CreateCodeTransformers` | C# for code transformer steps | [Create Code Transformations](tasks/create-code-transformers.md) |
| `CreateFilters` | filter objects | [Create Message Filters](tasks/create-filters.md) |
| `CreateRecieverVariableInstructions` | receiver variable extraction instructions | [Create Receiver Variable Instructions](tasks/create-receiver-variable-instructions.md) |
| `CreateRecieverResponseTransfomerInstructions` | receiver response transformation instructions | [Create Receiver Response Instructions](tasks/create-receiver-response-transformer-instructions.md) |
| `CreateSenderTransformerInstructions` | sender transformation instructions | [Create Sender Transformer Instructions](tasks/create-sender-transformer-instructions.md) |
| `ValidateWorkflowStructure` | validation result JSON | [Validate Workflow Structure](tasks/validate-workflow-structure.md) |
| `RefineWorkflowStructure` | corrected workflow structure JSON | [Refine Workflow Structure](tasks/refine-workflow-structure.md) |

---

## Rule component pages

| Rule family | Purpose | Doc |
|---|---|---|
| Path and source reference rules | Correct path syntax and cross-activity reads by message type | [Path and Source Rules](components/path-rules.md) |
| Transformer generation rules | Transformer action vocabulary and conversion patterns | [Transformer Rules](components/transformer-rules.md) |
| Filter generation rules | Receiver/sender pass criteria semantics | [Filter Rules](components/filter-rules.md) |
| Code generation rules | C# constraints and runtime API usage | [Code Rules](components/code-rules.md) |
| Receiver/sender JSON generation rules | Type selection and serialized property generation | [Receiver/Sender JSON Generation Guide](components/receiver-sender-json-generation.md) |
| Instruction building blocks | Shared rule blocks used across tasks | [Instruction Rule Building Blocks](components/instruction-rule-blocks.md) |
| Instruction source precedence | How system/user/import/instruction text sources are keyed and resolved | [Instruction Sources and Precedence](components/instruction-sources-and-precedence.md) |
