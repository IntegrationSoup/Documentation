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

## Quickstart prompt chains

### A. New workflow from requirements

1. `CreateWorkflow`
2. `ValidateWorkflowStructure`
3. `RefineWorkflowStructure` (if needed)
4. `CreateWorkflowFileFromWorkflowStructure`
5. `CreateFilters`
6. `CreateTransformers`
7. `CreateCodeTransformers` (only if code steps are required)

### B. Import/migration workflow

1. `ImportWorkflow`
2. `CreateReceiverVariableInstructions` (if extraction text is weak or missing)
3. `CreateSenderTransformerInstructions` (if sender mapping text is weak or missing)
4. `CreateRecieverResponseTransfomerInstructions` (if custom receiver response behavior is needed)
5. `CreateFilters`
6. `CreateTransformers` and `CreateCodeTransformers` as required

### C. Add one activity to existing workflow

1. `CreateActivity`
2. `CreateFilters` (activity-specific)
3. `CreateTransformers`
4. `CreateCodeTransformers` (optional)

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

## Operational rules

- Keep planning (`AiWorkflowStructure`) separate from concrete setting generation.
- Generate settings first, then attach filters/transformers.
- Use path prompt components for every instruction that includes field access.
- For Mirth conversions, include `mirth` in selector filters to pull conversion guidance.
- Preserve message templates exactly when provided by user/import source.
