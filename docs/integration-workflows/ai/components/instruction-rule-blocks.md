# Instruction Rule Building Blocks

The AI workflow rule source includes reusable rule blocks that are composed into task behavior but are not direct task entries.

These blocks are part of effective generation behavior and should be included when reproducing workflow construction outside the app.

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

## Composition patterns in current task behavior

- `CreateWorkflow` uses `IntegrationWorkflowStructureGuide`.
- `ImportWorkflow` and `CreateWorkflowFileFromWorkflowStructure` compose larger rule sets that include receiver/sender activity blocks and shared guidance sections.
- instruction-focused function types use their matching instruction block plus system-variable guidance.

---

## Practical implications for external AI orchestration

If you are recreating generation behavior in external tooling:

- include embedded blocks, not just top-level task text
- preserve composition order where possible (base guidance first, then scenario-specific instructions)
- ensure variable/system blocks are included when generating instructions that reference `${...}` values

---

## Failure modes to avoid

- using only function-name summaries and omitting embedded guidance
- generating instruction text without system-variable context
- applying code-generation guidance to non-code transformer tasks
