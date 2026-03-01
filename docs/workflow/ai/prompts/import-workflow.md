# Prompt: ImportWorkflow (`AiFunctionType.ImportWorkflow`)

Generates a workflow settings list from imported/foreign workflow descriptions.

---

## Input intent

- imported source behavior and configuration
- activity sequence and data flow requirements
- conversion hints (for example Mirth)

---

## Output contract

- JSON list of concrete `ISetting` activity objects suitable for workflow-file assembly
- one receiver first, then sender activities

---

## Embedded guidance in this prompt

- receiver and sender class selection mapping
- full `$type` naming guidance (fully qualified)
- placeholder GUID strategy
- incoming/secondary message reference syntax
- variable formatter usage hints

---

## Typical usage

- migration/import scenarios where a source workflow already exists and must be represented in Integration Soup settings format.
