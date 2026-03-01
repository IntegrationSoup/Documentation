# Prompt: RefineWorkflowStructure (`AiFunctionType.RefineWorkflowStructure`)

Repairs `AiWorkflowStructure` JSON according to validator issues while preserving user intent.

---

## Prompt source

- `Dialogs/AI/Prompts/RefineWorkflowStructurePrompt.cs`

---

## Input intent

- original user request
- current structure JSON
- validation issues and required fixes

---

## Output contract

- corrected `AiWorkflowStructure` JSON only

---

## Core expectation

- apply minimal changes required to restore faithfulness
- keep templates intact
- enforce schema and scenario constraints
