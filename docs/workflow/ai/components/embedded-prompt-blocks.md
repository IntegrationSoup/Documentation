# Embedded Prompt Blocks (Non-Function Entries)

`AIPrompts.cs` contains prompt blocks that are embedded into other prompts and are not direct `AiFunctionType` entries.

---

## Key embedded blocks

- `IntegrationWorkflowStructureGuide`
- `CreateReceiverActivities`
- `CreateSendersActivities`
- `CreateSenderFilterInstructions`
- `CreateRecieverVariableInstructions`
- `CreateRecieverResponseTransfomerInstructions`
- `CreateSenderTransformerInstructions`
- `SystemVariables`
- `SystemVariablesCode`

---

## How they are used

- Some are selected directly by `AiFunctionType` cases.
- Some are concatenated into larger system prompts (for example import/workflow-file creation).
- Some are currently present as reusable guidance but not exposed as standalone function selections.

---

## Practical implication

For complete scenario coverage, treat these blocks as part of the prompt graph even when no direct function enum maps to them.
