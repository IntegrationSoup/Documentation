# Prompt: ValidateWorkflowStructure (`AiFunctionType.ValidateWorkflowStructure`)

Validates whether current `AiWorkflowStructure` faithfully implements the original user request.

---

## Prompt source

- `Dialogs/AI/Prompts/ValidateWorkflowStructurePrompt.cs`

---

## Input intent

- original user request
- current `AiWorkflowStructure` JSON
- original workflow-generation context

---

## Output contract

- structured validation result (`isFaithful`, issues, suggested changes, optional clarification questions)

---

## Usage note

This prompt drives the iterative repair loop and can trigger clarification questions before refinement.
