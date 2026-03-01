# AI Mega Guide (Workflow Authoring)

This is the entry point for AI agents that need to generate Integration Soup workflows end-to-end.

Goal:
- produce valid, importable `*.hl7Workflow` JSON
- support one receiver plus multiple sender activities
- include filters, transformers, and code where required

---

## End-to-end flow

1. Generate `AiWorkflowStructure` from user intent.
2. Validate structure faithfulness.
3. Refine structure until faithfulness passes or iteration limit is reached.
4. Generate concrete receiver/sender setting objects.
5. Generate filter objects and attach `FilterHostSetting` references.
6. Generate transformer actions and attach `TransformerSetting` references.
7. Assemble final `WorkflowFile` JSON.
8. Save as UTF-8 `*.hl7Workflow` and import.

Use [AI Workflow Structure (AiWorkflowStructure)](ai-workflow-structure.md) as the planning contract.

---

## Prompt groups to use

- Function prompts (`AiFunctionType`): scenario-level system prompts.
- Path prompts (`AIPathPromptType`): path syntax and cross-activity access guidance.
- Transformer prompts (`AITransformerPromptType`): transformer action conventions.
- Filter prompts (`AIFilterPromptType`): filter object conventions.
- Code prompts (`AICodePromptType`): code transformer rules and available API patterns.
- Receiver/sender type and setting prompts: choose concrete setting class and fill serialized properties.

---

## Prompt catalog

- [Prompt Catalog](prompt-catalog.md)
- [Function Prompts](prompts/index.md)
- [Prompt Components](components/index.md)

---

## What this first pass covers

- every `AiFunctionType` scenario has a dedicated page
- every prompt family enum has a dedicated page
- import and workflow-file creation scenarios are documented separately
- prompt storage/override mechanics are documented

Later refinement pass can add:
- richer examples for each scenario
- reusable prompt templates per message type
- strict validation checklists per activity type
