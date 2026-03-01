# Prompt: CreateWorkflowFileFromWorkflowStructure (`AiFunctionType.CreateWorkflowFileFromWorkflowStructure`)

Generates concrete activity setting objects intended for final `WorkflowFile` composition.

---

## Input intent

- an already-defined structure (typically from `CreateWorkflow`)
- receiver/sender requirements and templates
- activity sequencing and cross-activity references

---

## Output contract

- JSON list of concrete `ISetting` objects
- receiver first
- sender activities following

---

## Prompt characteristics

- shares major guidance blocks with `ImportWorkflow`
- emphasizes class selection and serialized-property completeness
- includes type and GUID formatting constraints

---

## Follow-up requirement

After this step, filter and transformer host/settings objects must still be wired correctly and appended to `WorkflowPattern`.
