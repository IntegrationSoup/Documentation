# Prompt: CreateSenderTransformerInstructions (`AiFunctionType.CreateSenderTransformerInstructions`)

Expands sender transformer instruction text into detailed, executable mapping/transformation plans.

---

## Input intent

- sender-specific transformation requirements
- sender message type/template
- workflow context and previously defined variables

---

## Output contract

- instruction text for `AiSenderActivity.Transformers[i].Instruction`

---

## Core expectation

- explicit operation vocabulary (`Map`, `Set Variables`, `Update`, `Format`, `Code`, etc.)
- complete field-level mapping instructions
- source-context clarity for cross-activity values
