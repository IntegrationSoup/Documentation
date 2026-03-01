# Prompt: CreateWorkflow (`AiFunctionType.CreateWorkflow`)

Builds `AiWorkflowStructure` from natural-language workflow requirements.

---

## Input intent

- source/receiver requirements
- sender actions and order
- filter and transform requirements
- optional message templates
- optional import context (for example Mirth-derived details)

---

## Output contract

- one JSON object conforming to `AiWorkflowStructure`
- receiver + sender planning objects, not final executable settings

---

## Core rules (first pass)

- one receiver only
- preserve message templates as provided
- prefer sender transformers for mapping
- use variable transformers only when needed for reuse/preprocessing/filter support
- keep connection details in `Instructions`
- use positive filter phrasing (`Continue only when...`)

---

## Next steps in pipeline

1. Validate via `ValidateWorkflowStructure`.
2. Repair via `RefineWorkflowStructure` if needed.
3. Materialize concrete settings and final workflow file.
