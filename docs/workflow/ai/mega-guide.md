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

## Quickstart generation chains

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

## Rule groups to use

Rule families used during generation:

- workflow task rules (structure, validation, refinement, assembly)
- path rules (cross-activity and message-type path syntax)
- transformer rules (mapping/variable/update/code conversion patterns)
- filter rules (receiver and sender pass criteria)
- code rules (C# generation constraints for code-based transforms)
- receiver/sender setting rules (class selection + serialized property generation)

---

## Task catalog

- [Workflow JSON Task Catalog](task-catalog.md)
- [Workflow Construction Tasks](tasks/index.md)
- [Generation Rule Components](components/index.md)

---

## Operational rules

- Keep planning (`AiWorkflowStructure`) separate from concrete setting generation.
- Generate settings first, then attach filters/transformers.
- Use path rules for every instruction that includes field access.
- For Mirth conversions, include `mirth` in selector filters to pull conversion guidance.
- Preserve message templates exactly when provided by user/import source.
