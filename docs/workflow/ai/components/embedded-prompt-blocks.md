# Embedded Prompt Blocks (Non-Function Entries)

`AIPrompts.cs` includes reusable prompt blocks that are composed into system prompts but are not themselves `AiFunctionType` values.

These blocks are part of the effective prompt graph and must be considered when reproducing AI behavior outside the app.

---

## Key blocks and usage

| Block | Primary use |
|---|---|
| `IntegrationWorkflowStructureGuide` | Core guidance for creating `AiWorkflowStructure`. |
| `CreateReceiverActivities` | Receiver-setting generation guidance for workflow file assembly/import. |
| `CreateSendersActivities` | Sender-setting generation guidance for workflow file assembly/import. |
| `CreateSenderFilterInstructions` | Sender filter instruction expansion guidance. |
| `CreateRecieverVariableInstructions` | Receiver variable instruction expansion guidance. |
| `CreateRecieverResponseTransfomerInstructions` | Receiver response-transform instruction expansion guidance. |
| `CreateSenderTransformerInstructions` | Sender transformer instruction expansion guidance. |
| `SystemVariables` | Runtime variable and formatter guidance used in transformation flows. |
| `SystemVariablesCode` | Code-oriented variable/runtime guidance for code generation scenarios. |

---

## Composition patterns in current system prompts

- `CreateWorkflow` uses `IntegrationWorkflowStructureGuide`.
- `ImportWorkflow` and `CreateWorkflowFileFromWorkflowStructure` compose larger prompts that include receiver/sender activity blocks and shared guidance sections.
- instruction-focused function types use their matching instruction block plus system-variable guidance.

---

## Practical implications for external AI orchestration

If you are recreating prompt behavior in external tooling:

- include embedded blocks, not just top-level function prompt text
- preserve composition order where possible (base guidance first, then scenario-specific instructions)
- ensure variable/system blocks are included when generating instructions that reference `${...}` values

---

## Failure modes to avoid

- using only function-name summaries and omitting embedded guidance
- generating instruction text without system-variable context
- applying code-generation guidance to non-code transformer tasks
